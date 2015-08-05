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
#import "MBProgressHUD.h"

#import "AppConstant.h"
#import "AppDelegate.h"
#import "converter.h"
#import "emoji.h"
#import "image.h"
#import "push.h"
#import "recent.h"
#import "video.h"

#import "Outgoing.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface Outgoing()
{
	NSString *groupId;
	UIView *view;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation Outgoing

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWith:(NSString *)groupId_ View:(UIView *)view_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	groupId = groupId_;
	view = view_;
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)send:(NSString *)text Video:(NSURL *)video Picture:(UIImage *)picture Audio:(NSString *)audio
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFUser *user = [PFUser currentUser];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	item[@"userId"] = user.objectId;
	item[@"name"] = user[PF_USER_FULLNAME];
	item[@"date"] = Date2String([NSDate date]);
	item[@"status"] = TEXT_DELIVERED;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	item[@"video"] = item[@"thumbnail"] = item[@"picture"] = item[@"audio"] = item[@"latitude"] = item[@"longitude"] = @"";
	item[@"video_duration"] = item[@"audio_duration"] = @0;
	item[@"picture_width"] = item[@"picture_height"] = @0;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (text != nil) [self sendTextMessage:item Text:text];
	else if (video != nil) [self sendVideoMessage:item Video:video];
	else if (picture != nil) [self sendPictureMessage:item Picture:picture];
	else if (audio != nil) [self sendAudioMessage:item Audio:audio];
	else [self sendLoactionMessage:item];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sendTextMessage:(NSMutableDictionary *)item Text:(NSString *)text
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	item[@"text"] = text;
	item[@"type"] = IsEmoji(text) ? @"emoji" : @"text";
	[self sendMessage:item];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sendVideoMessage:(NSMutableDictionary *)item Video:(NSURL *)video
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
	hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	UIImage *picture = VideoThumbnail(video);
	UIImage *squared = SquareImage(picture, 320);
	NSNumber *duration = VideoDuration(video);
	PFFile *fileThumbnail = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(squared, 0.6)];
	[fileThumbnail saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error == nil)
		{
			PFFile *fileVideo = [PFFile fileWithName:@"video.mp4" data:[[NSFileManager defaultManager] contentsAtPath:video.path]];
			[fileVideo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
			{
				[hud hide:YES];
				if (error == nil)
				{
					item[@"video"] = fileVideo.url;
					item[@"video_duration"] = duration;
					item[@"thumbnail"] = fileThumbnail.url;
					item[@"text"] = @"[Video message]";
					item[@"type"] = @"video";
					[self sendMessage:item];
				}
				else NSLog(@"Outgoing sendVideoMessage video save error.");
			}
			progressBlock:^(int percentDone)
			{
				hud.progress = (float) percentDone/100;
			}];
		}
		else NSLog(@"Outgoing sendVideoMessage picture save error.");
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sendPictureMessage:(NSMutableDictionary *)item Picture:(UIImage *)picture
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
	hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	int width = (int) picture.size.width;
	int height = (int) picture.size.height;
	PFFile *file = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(picture, 0.6)];
	[file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		[hud hide:YES];
		if (error == nil)
		{
			item[@"picture"] = file.url;
			item[@"picture_width"] = [NSNumber numberWithInt:width];
			item[@"picture_height"] = [NSNumber numberWithInt:height];
			item[@"text"] = @"[Picture message]";
			item[@"type"] = @"picture";
			[self sendMessage:item];
		}
		else NSLog(@"Outgoing sendPictureMessage picture save error.");
	}
	progressBlock:^(int percentDone)
	{
		hud.progress = (float) percentDone/100;
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sendAudioMessage:(NSMutableDictionary *)item Audio:(NSString *)audio
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sendLoactionMessage:(NSMutableDictionary *)item
//-------------------------------------------------------------------------------------------------------------------------------------------------
{

}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sendMessage:(NSMutableDictionary *)item
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Message/%@", FIREBASE, groupId]];
	Firebase *reference = [firebase childByAutoId];
	item[@"key"] = reference.key;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[reference setValue:item withCompletionBlock:^(NSError *error, Firebase *ref)
	{
		if (error != nil) NSLog(@"Outgoing sendMessage network error.");
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	SendPushNotification1(groupId, item[@"text"]);
	UpdateRecentCounter1(groupId, 1, item[@"text"]);
}

@end
