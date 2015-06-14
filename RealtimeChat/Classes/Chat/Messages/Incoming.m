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

#import "JSQMessage.h"
#import "UIImageView+WebCache.h"

#import "AppConstant.h"
#import "converter.h"

#import "EmojiMediaItem.h"
#import "PhotoMediaItem.h"
#import "VideoMediaItem.h"
#import "JSQLocationMediaItem.h"

#import "Incoming.h"
#import "ChatView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface Incoming()
{
	NSString *senderId;
	ChatView *chatView;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation Incoming

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWith:(NSString *)senderId_ ChatView:(ChatView *)chatView_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	senderId = senderId_;
	chatView = chatView_;
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (JSQMessage *)create:(NSDictionary *)item
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQMessage *message;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([item[@"type"] isEqualToString:@"text"])		message = [self createTextMessage:item];
	if ([item[@"type"] isEqualToString:@"emoji"])		message = [self createEmojiMessage:item];
	if ([item[@"type"] isEqualToString:@"video"])		message = [self createVideoMessage:item];
	if ([item[@"type"] isEqualToString:@"picture"])		message = [self createPictureMessage:item];
	if ([item[@"type"] isEqualToString:@"audio"])		message = [self createAudioMessage:item];
	if ([item[@"type"] isEqualToString:@"location"])	message = [self createLocationMessage:item];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return message;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (JSQMessage *)createTextMessage:(NSDictionary *)item
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *name = item[@"name"];
	NSString *userId = item[@"userId"];
	NSDate *date = String2Date(item[@"date"]);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *text = item[@"text"];
	JSQMessage *message = [[JSQMessage alloc] initWithSenderId:userId senderDisplayName:name date:date text:text];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return message;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (JSQMessage *)createEmojiMessage:(NSDictionary *)item
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *name = item[@"name"];
	NSString *userId = item[@"userId"];
	NSDate *date = String2Date(item[@"date"]);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	EmojiMediaItem *mediaItem = [[EmojiMediaItem alloc] initWithText:item[@"text"]];
	mediaItem.appliesMediaViewMaskAsOutgoing = [userId isEqualToString:senderId];
	JSQMessage *message = [[JSQMessage alloc] initWithSenderId:userId senderDisplayName:name date:date media:mediaItem];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return message;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (JSQMessage *)createVideoMessage:(NSDictionary *)item
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *name = item[@"name"];
	NSString *userId = item[@"userId"];
	NSDate *date = String2Date(item[@"date"]);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	VideoMediaItem *mediaItem = [[VideoMediaItem alloc] initWithFileURL:[NSURL URLWithString:item[@"video"]] isReadyToPlay:NO];
	mediaItem.appliesMediaViewMaskAsOutgoing = [userId isEqualToString:senderId];
	JSQMessage *message = [[JSQMessage alloc] initWithSenderId:userId senderDisplayName:name date:date media:mediaItem];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	SDWebImageManager *manager = [SDWebImageManager sharedManager];
	[manager downloadImageWithURL:[NSURL URLWithString:item[@"thumbnail"]] options:0 progress:nil
	completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL)
	{
		if (image != nil)
		{
			mediaItem.isReadyToPlay = YES;
			mediaItem.image = image;
			[chatView.collectionView reloadData];
		}
		else NSLog(@"Incoming createVideoMessage picture load error.");
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return message;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (JSQMessage *)createPictureMessage:(NSDictionary *)item
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *name = item[@"name"];
	NSString *userId = item[@"userId"];
	NSDate *date = String2Date(item[@"date"]);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PhotoMediaItem *mediaItem = [[PhotoMediaItem alloc] initWithImage:nil Width:item[@"picture_width"] Height:item[@"picture_height"]];
	mediaItem.appliesMediaViewMaskAsOutgoing = [userId isEqualToString:senderId];
	JSQMessage *message = [[JSQMessage alloc] initWithSenderId:userId senderDisplayName:name date:date media:mediaItem];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	SDWebImageManager *manager = [SDWebImageManager sharedManager];
	[manager downloadImageWithURL:[NSURL URLWithString:item[@"picture"]] options:0 progress:nil
	completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL)
	{
		if (image != nil)
		{
			mediaItem.image = image;
			[chatView.collectionView reloadData];
		}
		else NSLog(@"Incoming createPictureMessage picture load error.");
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return message;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (JSQMessage *)createAudioMessage:(NSDictionary *)item
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (JSQMessage *)createLocationMessage:(NSDictionary *)item
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return nil;
}

@end
