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
#import "AiChecksum.h"
#import "MBProgressHUD.h"

#import "utilities.h"

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
	NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	item[@"userId"] = [PFUser currentId];
	item[@"name"] = [PFUser currentName];
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
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSData *dataThumbnail = UIImageJPEGRepresentation(squared, 0.6);
	NSData *dataVideo = [NSData dataWithContentsOfFile:video.path];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSData *cryptedThumbnail = EncryptData(groupId, dataThumbnail);
	NSData *cryptedVideo = EncryptData(groupId, dataVideo);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *md5Video = [AiChecksum md5HashOfData:cryptedVideo];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PFFile *fileThumbnail = [PFFile fileWithName:@"picture.jpg" data:cryptedThumbnail];
	[fileThumbnail saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error == nil)
		{
			PFFile *fileVideo = [PFFile fileWithName:@"video.mp4" data:cryptedVideo];
			[fileVideo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
			{
				[hud hide:YES];
				if (error == nil)
				{
					[self saveLocal:fileVideo.url Data:dataVideo];
					[self saveLocal:fileThumbnail.url Data:dataThumbnail];
					item[@"video"] = fileVideo.url;
					item[@"video_duration"] = duration;
					item[@"video_md5hash"] = md5Video;
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
		else NSLog(@"Outgoing sendVideoMessage thumbnail save error.");
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
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSData *dataPicture = UIImageJPEGRepresentation(picture, 0.6);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSData *cryptedPicture = EncryptData(groupId, dataPicture);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *md5Picture = [AiChecksum md5HashOfData:cryptedPicture];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PFFile *file = [PFFile fileWithName:@"picture.jpg" data:cryptedPicture];
	[file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		[hud hide:YES];
		if (error == nil)
		{
			[self saveLocal:file.url Data:dataPicture];
			item[@"picture"] = file.url;
			item[@"picture_width"] = [NSNumber numberWithInt:width];
			item[@"picture_height"] = [NSNumber numberWithInt:height];
			item[@"picture_md5hash"] = md5Picture;
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
	MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
	hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSNumber *duration = AudioDuration(audio);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSData *dataAudio = [NSData dataWithContentsOfFile:audio];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSData *cryptedAudio = EncryptData(groupId, dataAudio);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *md5Audio = [AiChecksum md5HashOfData:cryptedAudio];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PFFile *file = [PFFile fileWithName:@"audio.m4a" data:cryptedAudio];
	[file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		[hud hide:YES];
		if (error == nil)
		{
			[self saveLocal:file.url Data:dataAudio];
			item[@"audio"] = file.url;
			item[@"audio_duration"] = duration;
			item[@"audio_md5hash"] = md5Audio;
			item[@"text"] = @"[Audio message]";
			item[@"type"] = @"audio";
			[self sendMessage:item];
		}
		else NSLog(@"Outgoing sendAudioMessage audio save error.");
	}
	progressBlock:^(int percentDone)
	{
		hud.progress = (float) percentDone/100;
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sendLoactionMessage:(NSMutableDictionary *)item
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	AppDelegate *app = (AppDelegate *) [[UIApplication sharedApplication] delegate];
	item[@"latitude"] = [NSNumber numberWithDouble:app.coordinate.latitude];
	item[@"longitude"] = [NSNumber numberWithDouble:app.coordinate.longitude];
	item[@"text"] = @"[Location message]";
	item[@"type"] = @"location";
	[self sendMessage:item];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sendMessage:(NSMutableDictionary *)item
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	item[@"text"] = EncryptText(groupId, item[@"text"]);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	Firebase *firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Message/%@", FIREBASE, groupId]];
	Firebase *reference = [firebase childByAutoId];
	item[@"messageId"] = reference.key;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[reference setValue:item withCompletionBlock:^(NSError *error, Firebase *ref)
	{
		if (error != nil) NSLog(@"Outgoing sendMessage network error.");
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	SendPushNotification1(groupId, item[@"text"]);
	UpdateRecents(groupId, item[@"text"]);
}

#pragma mark - Helper methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)saveLocal:(NSString *)link Data:(NSData *)data
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *file = [link stringByReplacingOccurrencesOfString:LINK_PARSE withString:@""];
	[data writeToFile:Documents(file) atomically:NO];
}

@end
