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
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "ProgressHUD.h"
#import "UIImageView+WebCache.h"

#import "AppConstant.h"
#import "common.h"
#import "image.h"
#import "push.h"

#import "WelcomeView.h"
#import "LoginView.h"
#import "RegisterView.h"

@implementation WelcomeView

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Welcome";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
	[self.navigationItem setBackBarButtonItem:backButton];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionRegister:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	RegisterView *registerView = [[RegisterView alloc] init];
	[self.navigationController pushViewController:registerView animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionLogin:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	LoginView *loginView = [[LoginView alloc] init];
	[self.navigationController pushViewController:loginView animated:YES];
}

#pragma mark - Twitter login methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionTwitter:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[ProgressHUD show:@"Signing in..." Interaction:NO];
	[PFTwitterUtils logInWithBlock:^(PFUser *user, NSError *error)
	{
		if (user != nil)
		{
			if (user[PF_USER_TWITTERID] == nil)
			{
				[self processTwitter:user];
			}
			else [self userLoggedIn:user];
		}
		else [ProgressHUD showError:@"Twitter login error."];
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)processTwitter:(PFUser *)user
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PF_Twitter *twitter = [PFTwitterUtils twitter];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	user[PF_USER_FULLNAME] = twitter.screenName;
	user[PF_USER_FULLNAME_LOWER] = [twitter.screenName lowercaseString];
	user[PF_USER_TWITTERID] = twitter.userId;
	[user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error != nil)
		{
			[PFUser logOut];
			[ProgressHUD showError:error.userInfo[@"error"]];
		}
		else [self userLoggedIn:user];
	}];
}

#pragma mark - Facebook login methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (IBAction)actionFacebook:(id)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[ProgressHUD show:@"Signing in..." Interaction:NO];
	[PFFacebookUtils logInWithPermissions:@[@"public_profile", @"email", @"user_friends"] block:^(PFUser *user, NSError *error)
	{
		if (user != nil)
		{
			if (user[PF_USER_FACEBOOKID] == nil)
			{
				[self requestFacebook:user];
			}
			else [self userLoggedIn:user];
		}
		else [ProgressHUD showError:@"Facebook login error."];
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)requestFacebook:(PFUser *)user
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	FBRequest *request = [FBRequest requestForMe];
	[request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
	{
		if (error == nil)
		{
			NSDictionary *userData = (NSDictionary *)result;
			[self processFacebook:user UserData:userData];
		}
		else
		{
			[PFUser logOut];
			[ProgressHUD showError:@"Failed to fetch Facebook user data."];
		}
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)processFacebook:(PFUser *)user UserData:(NSDictionary *)userData
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *link = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", userData[@"id"]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	SDWebImageManager *manager = [SDWebImageManager sharedManager];
	[manager downloadImageWithURL:[NSURL URLWithString:link] options:0 progress:nil
	completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL)
	{
		if (image != nil)
		{
			UIImage *picture = ResizeImage(image, 140, 140, 1);
			UIImage *thumbnail = ResizeImage(image, 60, 60, 1);
			//-------------------------------------------------------------------------------------------------------------------------------------
			PFFile *filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(picture, 0.6)];
			[filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
			{
				if (error != nil) [ProgressHUD showError:@"Network error."];
			}];
			//-------------------------------------------------------------------------------------------------------------------------------------
			PFFile *fileThumbnail = [PFFile fileWithName:@"thumbnail.jpg" data:UIImageJPEGRepresentation(thumbnail, 0.6)];
			[fileThumbnail saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
			{
				if (error != nil) [ProgressHUD showError:@"Network error."];
			}];
			//-------------------------------------------------------------------------------------------------------------------------------------
			user[PF_USER_EMAILCOPY] = userData[@"email"];
			user[PF_USER_FULLNAME] = userData[@"name"];
			user[PF_USER_FULLNAME_LOWER] = [userData[@"name"] lowercaseString];
			user[PF_USER_FACEBOOKID] = userData[@"id"];
			user[PF_USER_PICTURE] = filePicture;
			user[PF_USER_THUMBNAIL] = fileThumbnail;
			[user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
			{
				if (error != nil)
				{
					[PFUser logOut];
					[ProgressHUD showError:error.userInfo[@"error"]];
				}
				else [self userLoggedIn:user];
			}];
		}
		else
		{
			[PFUser logOut];
			[ProgressHUD showError:@"Failed to fetch Facebook profile picture."];
		}
	}];
}

#pragma mark - Helper methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)userLoggedIn:(PFUser *)user
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	ParsePushUserAssign();
	PostNotification(NOTIFICATION_USER_LOGGED_IN);
	[ProgressHUD showSuccess:[NSString stringWithFormat:@"Welcome back %@!", user[PF_USER_FULLNAME]]];
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
