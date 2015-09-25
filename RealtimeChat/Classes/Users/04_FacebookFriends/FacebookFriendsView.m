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

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Parse/Parse.h>
#import "ProgressHUD.h"

#import "utilities.h"

#import "FacebookFriendsView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface FacebookFriendsView()
{
	NSMutableArray *users1;
	NSMutableArray *users2;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation FacebookFriendsView

@synthesize delegate;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Facebook Friends";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self
																						  action:@selector(actionCancel)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	users1 = [[NSMutableArray alloc] init];
	users2 = [[NSMutableArray alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self loadFacebook];
}

#pragma mark - Backend methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadFacebook
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me/friends?limit=5000" parameters:@{@"fields": @"id, name"}];
	[request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error)
	{
		if (error == nil)
		{
			NSMutableArray *fbids = [[NSMutableArray alloc] init];
			NSDictionary *userData = (NSDictionary *)result;
			NSArray *fbusers = [userData objectForKey:@"data"];
			for (NSDictionary *fbuser in fbusers)
			{
				[fbids addObject:fbuser[@"id"]];
				[users1 addObject:@{@"name":fbuser[@"name"], @"fbid":fbuser[@"id"]}];
			}
			[self loadUsers:fbids];
		}
		else [ProgressHUD showError:@"Facebook request error."];
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadUsers:(NSMutableArray *)fbids
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFQuery *query1 = [PFQuery queryWithClassName:PF_BLOCKED_CLASS_NAME];
	[query1 whereKey:PF_BLOCKED_USER1 equalTo:[PFUser currentUser]];

	PFQuery *query2 = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
	[query2 whereKey:PF_USER_OBJECTID doesNotMatchKey:PF_BLOCKED_USERID2 inQuery:query1];
	[query2 whereKey:PF_USER_FACEBOOKID containedIn:fbids];
	[query2 orderByAscending:PF_USER_FULLNAME_LOWER];
	[query2 setLimit:1000];
	[query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
	{
		if (error == nil)
		{
			[users2 removeAllObjects];
			for (PFUser *user in objects)
			{
				[users2 addObject:user];
				[self removeUser:user[PF_USER_FACEBOOKID]];
			}
			[self.tableView reloadData];
		}
		else [ProgressHUD showError:@"Network error."];
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)removeUser:(NSString *)fbid
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	for (NSDictionary *user in users1)
	{
		if ([user[@"fbid"] isEqualToString:fbid])
		{
			[users1 removeObject:user];
			break;
		}
	}
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCancel
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 2;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (section == 0) return [users2 count];
	if (section == 1) return [users1 count];
	return 0;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ((section == 0) && ([users2 count] != 0)) return @"Registered users";
	if ((section == 1) && ([users1 count] != 0)) return @"Non-registered users";
	return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
	if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (indexPath.section == 0)
	{
		PFUser *user = users2[indexPath.row];
		cell.textLabel.text = user[PF_USER_FULLNAME];
	}
	if (indexPath.section == 1)
	{
		NSDictionary *user = users1[indexPath.row];
		cell.textLabel.text = user[@"name"];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return cell;
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (indexPath.section == 0)
	{
		[self dismissViewControllerAnimated:YES completion:^{
			if (delegate != nil) [delegate didSelectFacebookUser:users2[indexPath.row]];
		}];
	}
}

@end
