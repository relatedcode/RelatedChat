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

#import "utilities.h"

#import "RecentView.h"
#import "RecentCell.h"
#import "MapsView.h"
#import "ChatView.h"
#import "SelectSingleView.h"
#import "SelectMultipleView.h"
#import "AddressBookView.h"
#import "FacebookFriendsView.h"
#import "SelectDistanceView.h"
#import "NavigationController.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface RecentView()
{
	Firebase *firebase;
	NSMutableArray *recents;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation RecentView

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	{
		[self.tabBarItem setImage:[UIImage imageNamed:@"tab_recent"]];
		self.tabBarItem.title = @"Recent";
		//-----------------------------------------------------------------------------------------------------------------------------------------
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadRecents) name:NOTIFICATION_APP_STARTED object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadRecents) name:NOTIFICATION_USER_LOGGED_IN object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actionCleanup) name:NOTIFICATION_USER_LOGGED_OUT object:nil];
	}
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Recent";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Maps" style:UIBarButtonItemStylePlain target:self
																						   action:@selector(actionMaps)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self
																						   action:@selector(actionCompose)];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.tableView registerNib:[UINib nibWithNibName:@"RecentCell" bundle:nil] forCellReuseIdentifier:@"RecentCell"];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	recents = [[NSMutableArray alloc] init];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidAppear:animated];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([PFUser currentUser] != nil)
	{

	}
	else LoginUser(self);
}

#pragma mark - Backend methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadRecents
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (([PFUser currentUser] == nil) || (firebase != nil)) return;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Recent", FIREBASE]];
	FQuery *query = [[firebase queryOrderedByChild:@"userId"] queryEqualToValue:[PFUser currentId]];
	[query observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
	{
		[recents removeAllObjects];
		if (snapshot.value != [NSNull null])
		{
			NSArray *sorted = [[snapshot.value allValues] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
			{
				NSDictionary *recent1 = (NSDictionary *)obj1;
				NSDictionary *recent2 = (NSDictionary *)obj2;
				NSDate *date1 = String2Date(recent1[@"date"]);
				NSDate *date2 = String2Date(recent2[@"date"]);
				return [date2 compare:date1];
			}];
			for (NSDictionary *recent in sorted)
			{
				[recents addObject:recent];
			}
		}
		[self.tableView reloadData];
		[self updateTabCounter];
	}];
}

#pragma mark - Helper methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)updateTabCounter
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	int total = 0;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	for (PFObject *recent in recents)
	{
		total += [recent[@"counter"] intValue];
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UITabBarItem *item = self.tabBarController.tabBar.items[0];
	item.badgeValue = (total == 0) ? nil : [NSString stringWithFormat:@"%d", total];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[UIApplication sharedApplication].applicationIconBadgeNumber = total;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PFInstallation *currentInstallation = [PFInstallation currentInstallation];
	currentInstallation.badge = total;
	[currentInstallation saveInBackground];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionMaps
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	MapsView *mapsView = [[MapsView alloc] init];
	mapsView.delegate = self;
	NavigationController *navController = [[NavigationController alloc] initWithRootViewController:mapsView];
	[self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - MapsDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didSelectMapsUser:(PFUser *)user2
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFUser *user1 = [PFUser currentUser];
	NSString *groupId = StartPrivateChat(user1, user2);
	[self actionChat:groupId];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionChat:(NSString *)groupId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	ChatView *chatView = [[ChatView alloc] initWith:groupId];
	chatView.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:chatView animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCompose
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];

	UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"Single recipient" style:UIAlertActionStyleDefault
													handler:^(UIAlertAction *action) { [self actionSelectSingle]; }];
	UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"Multiple recipients" style:UIAlertActionStyleDefault
													handler:^(UIAlertAction *action) { [self actionSelectMultiple]; }];
	UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"Address Book" style:UIAlertActionStyleDefault
													handler:^(UIAlertAction *action) { [self actionAddressBook]; }];
	UIAlertAction *action4 = [UIAlertAction actionWithTitle:@"Facebook Friends" style:UIAlertActionStyleDefault
													handler:^(UIAlertAction *action) { [self actionFacebookFriends]; }];
	UIAlertAction *action5 = [UIAlertAction actionWithTitle:@"Select by Distance" style:UIAlertActionStyleDefault
													handler:^(UIAlertAction *action) { [self actionSelectDistance]; }];
	UIAlertAction *action6 = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

	[alert addAction:action1]; [alert addAction:action2]; [alert addAction:action3];
	[alert addAction:action4]; [alert addAction:action5]; [alert addAction:action6];
	[self presentViewController:alert animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSelectSingle
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	SelectSingleView *selectSingleView = [[SelectSingleView alloc] init];
	selectSingleView.delegate = self;
	NavigationController *navController = [[NavigationController alloc] initWithRootViewController:selectSingleView];
	[self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - SelectSingleDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didSelectSingleUser:(PFUser *)user2
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFUser *user1 = [PFUser currentUser];
	NSString *groupId = StartPrivateChat(user1, user2);
	[self actionChat:groupId];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSelectMultiple
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	SelectMultipleView *selectMultipleView = [[SelectMultipleView alloc] init];
	selectMultipleView.delegate = self;
	NavigationController *navController = [[NavigationController alloc] initWithRootViewController:selectMultipleView];
	[self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - SelectMultipleDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didSelectMultipleUsers:(NSMutableArray *)users
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *groupId = StartMultipleChat(users);
	[self actionChat:groupId];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionAddressBook
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	AddressBookView *addressBookView = [[AddressBookView alloc] init];
	addressBookView.delegate = self;
	NavigationController *navController = [[NavigationController alloc] initWithRootViewController:addressBookView];
	[self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - AddressBookDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didSelectAddressBookUser:(PFUser *)user2
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFUser *user1 = [PFUser currentUser];
	NSString *groupId = StartPrivateChat(user1, user2);
	[self actionChat:groupId];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionFacebookFriends
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	FacebookFriendsView *facebookFriendsView = [[FacebookFriendsView alloc] init];
	facebookFriendsView.delegate = self;
	NavigationController *navController = [[NavigationController alloc] initWithRootViewController:facebookFriendsView];
	[self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - FacebookFriendsDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didSelectFacebookUser:(PFUser *)user2
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFUser *user1 = [PFUser currentUser];
	NSString *groupId = StartPrivateChat(user1, user2);
	[self actionChat:groupId];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSelectDistance
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	SelectDistanceView *selectDistanceView = [[SelectDistanceView alloc] init];
	selectDistanceView.delegate = self;
	NavigationController *navController = [[NavigationController alloc] initWithRootViewController:selectDistanceView];
	[self presentViewController:navController animated:YES completion:nil];
}

#pragma mark - SelectDistanceDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didSelectDistanceUser:(PFUser *)user2
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFUser *user1 = [PFUser currentUser];
	NSString *groupId = StartPrivateChat(user1, user2);
	[self actionChat:groupId];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionCleanup
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[firebase removeAllObservers];
	firebase = nil;
	[recents removeAllObjects];
	[self.tableView reloadData];
	[self updateTabCounter];
}

#pragma mark - Table view data source

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 1;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [recents count];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	RecentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecentCell" forIndexPath:indexPath];
	[cell bindData:recents[indexPath.row]];
	return cell;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSDictionary *recent = recents[indexPath.row];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[recents removeObject:recent];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self updateTabCounter];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	DeleteRecentItem(recent);
}

#pragma mark - Table view delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSDictionary *recent = recents[indexPath.row];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	RestartRecentChat(recent);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self actionChat:recent[@"groupId"]];
}

@end
