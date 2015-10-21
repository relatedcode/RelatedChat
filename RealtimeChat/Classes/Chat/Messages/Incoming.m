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

#import "utilities.h"

#import "AudioMediaItem.h"
#import "EmojiMediaItem.h"
#import "PhotoMediaItem.h"
#import "VideoMediaItem.h"
#import "JSQLocationMediaItem.h"

#import "Incoming.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface Incoming()
{
	BOOL maskOutgoing;
	NSString *groupId;
	JSQMessagesCollectionView *collectionView;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation Incoming

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWith:(NSString *)groupId_ CollectionView:(JSQMessagesCollectionView *)collectionView_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	groupId = groupId_;
	collectionView = collectionView_;
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (JSQMessage *)create:(NSDictionary *)item
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQMessage *message;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	maskOutgoing = [[PFUser currentId] isEqualToString:item[@"userId"]];
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
	NSString *text = DecryptText(groupId, item[@"text"]);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return [[JSQMessage alloc] initWithSenderId:userId senderDisplayName:name date:date text:text];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (JSQMessage *)createEmojiMessage:(NSDictionary *)item
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *name = item[@"name"];
	NSString *userId = item[@"userId"];
	NSDate *date = String2Date(item[@"date"]);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *text = DecryptText(groupId, item[@"text"]);
	EmojiMediaItem *mediaItem = [[EmojiMediaItem alloc] initWithText:text];
	mediaItem.appliesMediaViewMaskAsOutgoing = maskOutgoing;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return [[JSQMessage alloc] initWithSenderId:userId senderDisplayName:name date:date media:mediaItem];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (JSQMessage *)createVideoMessage:(NSDictionary *)item
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *name = item[@"name"];
	NSString *userId = item[@"userId"];
	NSDate *date = String2Date(item[@"date"]);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	VideoMediaItem *mediaItem = [[VideoMediaItem alloc] initWithMaskAsOutgoing:maskOutgoing];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self loadVideoMedia:item MediaItem:mediaItem];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return [[JSQMessage alloc] initWithSenderId:userId senderDisplayName:name date:date media:mediaItem];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadVideoMedia:(NSDictionary *)item MediaItem:(VideoMediaItem *)mediaItem
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	mediaItem.status = STATUS_LOADING;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[AFDownload start:item[@"video"] md5:item[@"video_md5hash"] complete:^(NSString *path, NSError *error, BOOL network)
	{
		if (error == nil)
		{
			mediaItem.status = STATUS_SUCCEED;
			if (network) DecryptFile(groupId, path);
			mediaItem.fileURL = [NSURL fileURLWithPath:path];
		}
		else mediaItem.status = STATUS_FAILED;
		if (network) [collectionView reloadData];
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[AFDownload start:item[@"thumbnail"] complete:^(NSString *path, NSError *error, BOOL network)
	{
		if (error == nil)
		{
			if (network) DecryptFile(groupId, path);
			mediaItem.image = [[UIImage alloc] initWithContentsOfFile:path];
		}
		else mediaItem.status = STATUS_FAILED;
		if (network) [collectionView reloadData];
	}];
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
	mediaItem.appliesMediaViewMaskAsOutgoing = maskOutgoing;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self loadPictureMedia:item MediaItem:mediaItem];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return [[JSQMessage alloc] initWithSenderId:userId senderDisplayName:name date:date media:mediaItem];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadPictureMedia:(NSDictionary *)item MediaItem:(PhotoMediaItem *)mediaItem
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	mediaItem.status = STATUS_LOADING;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[AFDownload start:item[@"picture"] md5:item[@"picture_md5hash"] complete:^(NSString *path, NSError *error, BOOL network)
	{
		if (error == nil)
		{
			mediaItem.status = STATUS_SUCCEED;
			if (network) DecryptFile(groupId, path);
			mediaItem.image = [[UIImage alloc] initWithContentsOfFile:path];
		}
		else mediaItem.status = STATUS_FAILED;
		if (network) [collectionView reloadData];
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (JSQMessage *)createAudioMessage:(NSDictionary *)item
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *name = item[@"name"];
	NSString *userId = item[@"userId"];
	NSDate *date = String2Date(item[@"date"]);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	AudioMediaItem *mediaItem = [[AudioMediaItem alloc] initWithFileURL:nil Duration:item[@"audio_duration"]];
	mediaItem.appliesMediaViewMaskAsOutgoing = maskOutgoing;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self loadAudioMedia:item MediaItem:mediaItem];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return [[JSQMessage alloc] initWithSenderId:userId senderDisplayName:name date:date media:mediaItem];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadAudioMedia:(NSDictionary *)item MediaItem:(AudioMediaItem *)mediaItem
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	mediaItem.status = STATUS_LOADING;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[AFDownload start:item[@"audio"] md5:item[@"audio_md5hash"] complete:^(NSString *path, NSError *error, BOOL network)
	{
		if (error == nil)
		{
			mediaItem.status = STATUS_SUCCEED;
			if (network) DecryptFile(groupId, path);
			mediaItem.fileURL = [NSURL fileURLWithPath:path];
		}
		else mediaItem.status = STATUS_FAILED;
		if (network) [collectionView reloadData];
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (JSQMessage *)createLocationMessage:(NSDictionary *)item
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *name = item[@"name"];
	NSString *userId = item[@"userId"];
	NSDate *date = String2Date(item[@"date"]);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	JSQLocationMediaItem *mediaItem = [[JSQLocationMediaItem alloc] initWithLocation:nil];
	mediaItem.appliesMediaViewMaskAsOutgoing = maskOutgoing;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	CLLocation *location = [[CLLocation alloc] initWithLatitude:[item[@"latitude"] doubleValue] longitude:[item[@"longitude"] doubleValue]];
	[mediaItem setLocation:location withCompletionHandler:^{
		[collectionView reloadData];
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return [[JSQMessage alloc] initWithSenderId:userId senderDisplayName:name date:date media:mediaItem];
}

@end
