//
// Copyright (c) 2015 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Parse/Parse.h>
#import <Firebase/Firebase.h>
#import "ProgressHUD.h"

#import "AppConstant.h"
#import "PFUser+Util.h"
#import "converter.h"
#import "password.h"

#import "recent.h"

#pragma mark - Private Chat methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
NSString* StartPrivateChat(PFUser *user1, PFUser *user2)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *userId1 = user1.objectId;
	NSString *userId2 = user2.objectId;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *groupId = ([userId1 compare:userId2] < 0) ? [userId1 stringByAppendingString:userId2] : [userId2 stringByAppendingString:userId1];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSArray *members = @[userId1, userId2];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CreateRecent(userId1, groupId, members, user2[PF_USER_FULLNAME], userId2, @"private");
	CreateRecent(userId2, groupId, members, user1[PF_USER_FULLNAME], userId1, @"private");
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return groupId;
}

#pragma mark - Multiple Chat methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
NSString* StartMultipleChat(NSMutableArray *users)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *groupId = @"";
	NSString *description = @"";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[users addObject:[PFUser currentUser]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSMutableArray *userIds = [[NSMutableArray alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	for (PFUser *user in users)
	{
		[userIds addObject:user.objectId];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSArray *sorted = [userIds sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	for (NSString *userId in sorted)
	{
		groupId = [groupId stringByAppendingString:userId];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	for (PFUser *user in users)
	{
		if ([description length] != 0) description = [description stringByAppendingString:@" & "];
		description = [description stringByAppendingString:user[PF_USER_FULLNAME]];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CreateRecents(groupId, userIds, description, [PFUser currentId], @"multiple");
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return groupId;
}

#pragma mark - Group Chat methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
void StartGroupChat(PFObject *group)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	CreateRecents(group.objectId, group[PF_GROUP_MEMBERS], group[PF_GROUP_NAME], [PFUser currentId], @"group");
}

#pragma mark - Restart Recent Chat methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
void RestartRecentChat(NSDictionary *recent)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([recent[@"type"] isEqualToString:@"private"])
	{
		for (NSString *userId in recent[@"members"])
		{
			if ([userId isEqualToString:[PFUser currentId]] == NO)
				CreateRecent(userId, recent[@"groupId"], recent[@"members"], [PFUser currentName], [PFUser currentId], @"private");
		}
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([recent[@"type"] isEqualToString:@"multiple"])
	{
		CreateRecents(recent[@"groupId"], recent[@"members"], recent[@"description"], recent[@"profileId"], @"multiple");
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([recent[@"type"] isEqualToString:@"group"])
	{
		CreateRecents(recent[@"groupId"], recent[@"members"], recent[@"description"], recent[@"profileId"], @"group");
	}
}

#pragma mark - Create Recent methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
void CreateRecent(NSString *userId, NSString *groupId, NSArray *members, NSString *description, NSString *profileId, NSString *type)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Recent", FIREBASE]];
	FQuery *query = [[firebase queryOrderedByChild:@"groupId"] queryEqualToValue:groupId];
	[query observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
	{
		BOOL create = YES;
		//-----------------------------------------------------------------------------------------------------------------------------------------
		if (snapshot.value != [NSNull null])
		{
			for (NSDictionary *recent in [snapshot.value allValues])
			{
				if ([recent[@"userId"] isEqualToString:userId]) create = NO;
			}
		}
		//-----------------------------------------------------------------------------------------------------------------------------------------
		if (create) CreateRecentItem(userId, groupId, members, description, profileId, type);
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void CreateRecents(NSString *groupId, NSArray *members, NSString *description, NSString *profileId, NSString *type)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Recent", FIREBASE]];
	FQuery *query = [[firebase queryOrderedByChild:@"groupId"] queryEqualToValue:groupId];
	[query observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
	{
		NSMutableArray *userIds = [[NSMutableArray alloc] initWithArray:members];
		//-----------------------------------------------------------------------------------------------------------------------------------------
		if (snapshot.value != [NSNull null])
		{
			for (NSDictionary *recent in [snapshot.value allValues])
			{
				if ([members containsObject:recent[@"userId"]])
					[userIds removeObject:recent[@"userId"]];
			}
		}
		//-----------------------------------------------------------------------------------------------------------------------------------------
		for (NSString *userId in userIds)
		{
			CreateRecentItem(userId, groupId, members, description, profileId, type);
		}
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void CreateRecentItem(NSString *userId, NSString *groupId, NSArray *members, NSString *description, NSString *profileId, NSString *type)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Recent", FIREBASE]];
	Firebase *reference = [firebase childByAutoId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *recentId = reference.key;
	NSString *date = Date2String([NSDate date]);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSDictionary *recent = @{@"recentId":recentId, @"userId":userId, @"groupId":groupId, @"members":members, @"description":description,
								@"lastMessage":@"", @"counter":@0, @"date":date, @"profileId":profileId, @"type":type, @"password":@""};
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[reference setValue:recent withCompletionBlock:^(NSError *error, Firebase *ref)
	{
		if (error != nil) NSLog(@"CreateRecentItem save error.");
	}];
}

#pragma mark - Update Recent methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
void UpdateRecents(NSString *groupId, NSString *lastMessage)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Recent", FIREBASE]];
	FQuery *query = [[firebase queryOrderedByChild:@"groupId"] queryEqualToValue:groupId];
	[query observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
	{
		if (snapshot.value != [NSNull null])
		{
			for (NSDictionary *recent in [snapshot.value allValues])
			{
				UpdateRecentItem(recent, lastMessage);
			}
		}
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void UpdateRecentItem(NSDictionary *recent, NSString *lastMessage)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *date = Date2String([NSDate date]);
	NSInteger counter = [recent[@"counter"] integerValue];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([recent[@"userId"] isEqualToString:[PFUser currentId]] == NO) counter++;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Recent/%@", FIREBASE, recent[@"recentId"]]];
	NSDictionary *values = @{@"lastMessage":lastMessage, @"counter":@(counter), @"date":date};
	[firebase updateChildValues:values withCompletionBlock:^(NSError *error, Firebase *ref)
	{
		if (error != nil) NSLog(@"UpdateRecentItem save error.");
	}];
}

#pragma mark - Clear Recent Counter methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
void ClearRecentCounter(NSString *groupId)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Recent", FIREBASE]];
	FQuery *query = [[firebase queryOrderedByChild:@"groupId"] queryEqualToValue:groupId];
	[query observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
	{
		if (snapshot.value != [NSNull null])
		{
			for (NSDictionary *recent in [snapshot.value allValues])
			{
				if ([recent[@"userId"] isEqualToString:[PFUser currentId]])
				{
					ClearRecentCounterItem(recent);
				}
			}
		}
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void ClearRecentCounterItem(NSDictionary *recent)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Recent/%@", FIREBASE, recent[@"recentId"]]];
	[firebase updateChildValues:@{@"counter":@0} withCompletionBlock:^(NSError *error, Firebase *ref)
	{
		if (error != nil) NSLog(@"ClearRecentCounterItem save error.");
	}];
}

#pragma mark - Delete Recent methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
void DeleteRecents(PFUser *user1, PFUser *user2)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Recent", FIREBASE]];
	FQuery *query = [[firebase queryOrderedByChild:@"userId"] queryEqualToValue:user1.objectId];
	[query observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
	{
		if (snapshot.value != [NSNull null])
		{
			for (NSDictionary *recent in [snapshot.value allValues])
			{
				if ([recent[@"members"] containsObject:user2.objectId])
				{
					DeleteRecentItem(recent);
				}
			}
		}
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void DeleteRecentItem(NSDictionary *recent)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Recent/%@", FIREBASE, recent[@"recentId"]]];
	[firebase removeValueWithCompletionBlock:^(NSError *error, Firebase *ref)
	{
		if (error != nil) NSLog(@"DeleteRecentItem delete error.");
	}];
}
