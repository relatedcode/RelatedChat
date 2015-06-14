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
#import "PFUser+Util.h"
#import "ProgressHUD.h"

#import "AppConstant.h"
#import "converter.h"

#import "recent.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
NSString* StartPrivateChat(PFUser *user1, PFUser *user2)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *id1 = user1.objectId;
	NSString *id2 = user2.objectId;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *groupId = ([id1 compare:id2] < 0) ? [NSString stringWithFormat:@"%@%@", id1, id2] : [NSString stringWithFormat:@"%@%@", id2, id1];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSArray *members = @[user1.objectId, user2.objectId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CreateRecentItem1(user1, groupId, members, user2[PF_USER_FULLNAME], user2);
	CreateRecentItem1(user2, groupId, members, user1[PF_USER_FULLNAME], user1);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return groupId;
}

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
	for (PFUser *user in users)
	{
		CreateRecentItem1(user, groupId, userIds, description, [PFUser currentUser]);
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return groupId;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void StartGroupChat(PFObject *group, NSMutableArray *users)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	for (PFUser *user in users)
	{
		CreateRecentItem1(user, group.objectId, group[PF_GROUP_MEMBERS], group[PF_GROUP_NAME], [PFUser currentUser]);
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void CreateRecentItem1(PFUser *user, NSString *groupId, NSArray *members, NSString *description, PFUser *profile)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Recent", FIREBASE]];
	FQuery *query = [[firebase queryOrderedByChild:@"groupId"] queryEqualToValue:groupId];
	[query observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
	{
		BOOL create = YES;
		if (snapshot.value != [NSNull null])
		{
			for (NSDictionary *recent in [snapshot.value allValues])
			{
				if ([recent[@"userId"] isEqualToString:user.objectId]) create = NO;
			}
		}
		if (create) CreateRecentItem2(user, groupId, members, description, profile);
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void CreateRecentItem2(PFUser *user, NSString *groupId, NSArray *members, NSString *description, PFUser *profile)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Recent", FIREBASE]];
	Firebase *reference = [firebase childByAutoId];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *recentId = reference.key;
	PFUser *lastUser = [PFUser currentUser];
	NSString *date = Date2String([NSDate date]);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSDictionary *recent = @{@"recentId":recentId, @"userId":user.objectId, @"groupId":groupId, @"members":members, @"description":description,
								@"lastUser":lastUser.objectId, @"lastMessage":@"", @"counter":@0, @"date":date, @"profileId":profile.objectId};
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[reference setValue:recent withCompletionBlock:^(NSError *error, Firebase *ref)
	{
		if (error != nil) NSLog(@"CreateRecentItem2 save error.");
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void UpdateRecentCounter1(NSString *groupId, NSInteger amount, NSString *lastMessage)
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
				UpdateRecentCounter2(recent, amount, lastMessage);
			}
		}
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void UpdateRecentCounter2(NSDictionary *recent, NSInteger amount, NSString *lastMessage)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFUser *user = [PFUser currentUser];
	NSString *date = Date2String([NSDate date]);
	NSInteger counter = [recent[@"counter"] integerValue];
	if ([recent[@"userId"] isEqualToString:user.objectId] == NO) counter += amount;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Recent/%@", FIREBASE, recent[@"recentId"]]];
	NSDictionary *values = @{@"lastUser":user.objectId, @"lastMessage":lastMessage, @"counter":@(counter), @"date":date};
	[firebase updateChildValues:values withCompletionBlock:^(NSError *error, Firebase *ref)
	{
		[ProgressHUD dismiss];
		if (error != nil) NSLog(@"UpdateRecentCounter2 save error.");
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void ClearRecentCounter1(NSString *groupId)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Recent", FIREBASE]];
	FQuery *query = [[firebase queryOrderedByChild:@"groupId"] queryEqualToValue:groupId];
	[query observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
	{
		if (snapshot.value != [NSNull null])
		{
			PFUser *user = [PFUser currentUser];
			for (NSDictionary *recent in [snapshot.value allValues])
			{
				if ([recent[@"userId"] isEqualToString:user.objectId])
				{
					ClearRecentCounter2(recent);
				}
			}
		}
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void ClearRecentCounter2(NSDictionary *recent)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Recent/%@", FIREBASE, recent[@"recentId"]]];
	[firebase updateChildValues:@{@"counter":@0} withCompletionBlock:^(NSError *error, Firebase *ref)
	{
		if (error != nil) NSLog(@"ClearRecentCounter2 save error.");
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void DeleteRecentItems(PFUser *user1, PFUser *user2)
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
