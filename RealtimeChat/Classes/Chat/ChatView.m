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

#import <MediaPlayer/MediaPlayer.h>

#import "AFNetworking.h"
#import <Parse/Parse.h>
#import <Firebase/Firebase.h>
#import "IDMPhotoBrowser.h"

#import "AppConstant.h"
#import "AppDelegate.h"
#import "camera.h"
#import "common.h"
#import "converter.h"
#import "image.h"
#import "push.h"
#import "recent.h"
#import "video.h"

#import "VideoMediaItem.h"

#import "ChatView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface ChatView()
{
	NSString *groupId;

	BOOL initialized;

	Firebase *firebase1;

	NSMutableArray *items;
	NSMutableArray *messages;
	NSMutableDictionary *avatars;

	JSQMessagesBubbleImage *bubbleImageOutgoing;
	JSQMessagesBubbleImage *bubbleImageIncoming;
	JSQMessagesAvatarImage *avatarImageBlank;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation ChatView

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWith:(NSString *)groupId_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	groupId = groupId_;
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Chat";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	items = [[NSMutableArray alloc] init];
	messages = [[NSMutableArray alloc] init];
	avatars = [[NSMutableDictionary alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PFUser *user = [PFUser currentUser];
	self.senderId = user.objectId;
	self.senderDisplayName = user[PF_USER_FULLNAME];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
	bubbleImageOutgoing = [bubbleFactory outgoingMessagesBubbleImageWithColor:COLOR_OUTGOING];
	bubbleImageIncoming = [bubbleFactory incomingMessagesBubbleImageWithColor:COLOR_INCOMING];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	avatarImageBlank = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"chat_blank"] diameter:30.0];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	firebase1 = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Message/%@", FIREBASE, groupId]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self loadMessages];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidAppear:animated];
	self.collectionView.collectionViewLayout.springinessEnabled = NO;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewWillDisappear:animated];
	if (self.isMovingFromParentViewController)
	{
		ClearRecentCounter(groupId);
		[firebase1 removeAllObservers];
	}
}

#pragma mark - Backend methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadMessages
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	initialized = NO;
	self.automaticallyScrollsToMostRecentMessage = NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[firebase1 observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot)
	{
		BOOL incoming = [self addMessage:snapshot.value];

		if (initialized)
		{
			if (incoming) [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
			[self finishReceivingMessage];
		}
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[firebase1 observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
	{
		[self finishReceivingMessage];
		[self scrollToBottomAnimated:NO];
		self.automaticallyScrollsToMostRecentMessage = YES;
		initialized	= YES;
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)addMessage:(NSDictionary *)item
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQMessage *message;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([item[@"type"] isEqualToString:@"text"])		message = [self createTextMessage:item];
	if ([item[@"type"] isEqualToString:@"video"])		message = [self createVideoMessage:item];
	if ([item[@"type"] isEqualToString:@"picture"])		message = [self createPictureMessage:item];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (message == nil) return NO;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[items addObject:item];
	[messages addObject:message];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return [self incoming:message];
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
- (JSQMessage *)createVideoMessage:(NSDictionary *)item
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *name = item[@"name"];
	NSString *userId = item[@"userId"];
	NSDate *date = String2Date(item[@"date"]);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	VideoMediaItem *mediaItem = [[VideoMediaItem alloc] initWithFileURL:[NSURL URLWithString:item[@"video"]] isReadyToPlay:NO];
	mediaItem.appliesMediaViewMaskAsOutgoing = [userId isEqualToString:self.senderId];
	JSQMessage *message = [[JSQMessage alloc] initWithSenderId:userId senderDisplayName:name date:date media:mediaItem];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:item[@"thumbnail"]]];
	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	operation.responseSerializer = [AFImageResponseSerializer serializer];
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
	{
		mediaItem.isReadyToPlay = YES;
		mediaItem.image = (UIImage *)responseObject;
		[self.collectionView reloadData];
	}
	failure:^(AFHTTPRequestOperation *operation, NSError *error)
	{
		NSLog(@"createVideoMessage picture load error.");
	}];
	[[NSOperationQueue mainQueue] addOperation:operation];
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
	JSQPhotoMediaItem *mediaItem = [[JSQPhotoMediaItem alloc] initWithImage:nil];
	mediaItem.appliesMediaViewMaskAsOutgoing = [userId isEqualToString:self.senderId];
	JSQMessage *message = [[JSQMessage alloc] initWithSenderId:userId senderDisplayName:name date:date media:mediaItem];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:item[@"picture"]]];
	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	operation.responseSerializer = [AFImageResponseSerializer serializer];
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
	{
		mediaItem.image = (UIImage *)responseObject;
		[self.collectionView reloadData];
	}
	failure:^(AFHTTPRequestOperation *operation, NSError *error)
	{
		NSLog(@"createPictureMessage picture load error.");
	}];
	[[NSOperationQueue mainQueue] addOperation:operation];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return message;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadAvatar:(NSString *)senderId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
	[query whereKey:PF_USER_OBJECTID equalTo:senderId];
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
	{
		if (error == nil)
		{
			if ([objects count] != 0)
			{
				PFUser *user = [objects firstObject];
				PFFile *file = user[PF_USER_THUMBNAIL];
				[file getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error)
				{
					if (error == nil)
					{
		 				UIImage *image = [UIImage imageWithData:imageData];
						avatars[senderId] = [JSQMessagesAvatarImageFactory avatarImageWithImage:image diameter:30.0];
						[self.collectionView reloadData];
					}
				}];
			}
		}
		else NSLog(@"loadAvatar query error.");
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sendMessage:(NSString *)text Video:(NSURL *)video Picture:(UIImage *)picture Audio:(NSString *)audio
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFUser *user = [PFUser currentUser];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSMutableDictionary *item = [[NSMutableDictionary alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	item[@"userId"] = user.objectId;
	item[@"name"] = user[PF_USER_FULLNAME];
	item[@"date"] = Date2String([NSDate date]);
	item[@"status"] = @"Delivered";
	//---------------------------------------------------------------------------------------------------------------------------------------------
	item[@"video"] = item[@"thumbnail"] = item[@"picture"] = item[@"audio"] = item[@"latitude"] = item[@"longitude"] = @"";
	item[@"duration"] = @0;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (text != nil) [self sendTextMessage:item Text:text];
	else if (video != nil) [self sendVideoMessage:item Video:video];
	else if (picture != nil) [self sendPictureMessage:item Picture:picture];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sendTextMessage:(NSMutableDictionary *)item Text:(NSString *)text
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	item[@"text"] = text;
	item[@"type"] = @"text";
	[self messageSave:item];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sendVideoMessage:(NSMutableDictionary *)item Video:(NSURL *)video
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
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
				if (error == nil)
				{
					item[@"video"] = fileVideo.url;
					item[@"thumbnail"] = fileThumbnail.url;
					item[@"duration"] = duration;
					item[@"text"] = @"[Video message]";
					item[@"type"] = @"video";
					[self messageSave:item];
				}
				else NSLog(@"sendVideoMessage video save error.");
			}];
		}
		else NSLog(@"sendVideoMessage picture save error.");
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sendPictureMessage:(NSMutableDictionary *)item Picture:(UIImage *)picture
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFFile *file = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(picture, 0.6)];
	[file saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
	{
		if (error == nil)
		{
			item[@"picture"] = file.url;
			item[@"text"] = @"[Picture message]";
			item[@"type"] = @"picture";
			[self messageSave:item];
		}
		else NSLog(@"sendPictureMessage picture save error.");
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)messageSave:(NSMutableDictionary *)item
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	Firebase *reference = [firebase1 childByAutoId];
	item[@"key"] = reference.key;
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[reference setValue:item withCompletionBlock:^(NSError *error, Firebase *ref)
	{
		if (error != nil) NSLog(@"messageSave network error.");
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	SendPushNotification(groupId, item[@"text"]);
	UpdateRecentCounter(groupId, 1, item[@"text"]);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[JSQSystemSoundPlayer jsq_playMessageSentSound];
	[self finishSendingMessage];
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionDelete
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel"
										  destructiveButtonTitle:@"Delete message" otherButtonTitles:nil];
	action.tag = 1;
	[action showInView:self.view];
}

#pragma mark - JSQMessagesViewController method overrides

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)name date:(NSDate *)date
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self sendMessage:text Video:nil Picture:nil Audio:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didPressAccessoryButton:(UIButton *)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
		otherButtonTitles:@"Take photo or video", @"Choose existing photo", @"Choose existing video", @"Record audio", @"Send location", nil];
	action.tag = 2;
	[action showInView:self.view];
}

#pragma mark - JSQMessages CollectionView DataSource

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return messages[indexPath.item];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
			 messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([self outgoing:messages[indexPath.item]])
	{
		return bubbleImageOutgoing;
	}
	else return bubbleImageIncoming;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
					avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQMessage *message = messages[indexPath.item];
	if (avatars[message.senderId] == nil)
	{
		[self loadAvatar:message.senderId];
		return avatarImageBlank;
	}
	else return avatars[message.senderId];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (indexPath.item % 3 == 0)
	{
		JSQMessage *message = messages[indexPath.item];
		return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
	}
	else return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQMessage *message = messages[indexPath.item];
	if ([self incoming:message])
	{
		if (indexPath.item > 0)
		{
			JSQMessage *previous = messages[indexPath.item-1];
			if ([previous.senderId isEqualToString:message.senderId])
			{
				return nil;
			}
		}
		return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
	}
	else return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([self outgoing:messages[indexPath.item]])
	{
		NSDictionary *item = items[indexPath.item];
		return [[NSAttributedString alloc] initWithString:item[@"status"]];
	}
	else return nil;
}

#pragma mark - UICollectionView DataSource

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [messages count];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];

	if ([self outgoing:messages[indexPath.item]])
	{
		cell.textView.textColor = [UIColor whiteColor];
	}
	else
	{
		cell.textView.textColor = [UIColor blackColor];
	}
	return cell;
}

#pragma mark - JSQMessages collection view flow layout delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
				   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (indexPath.item % 3 == 0)
	{
		return kJSQMessagesCollectionViewCellLabelHeightDefault;
	}
	else return 0;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
				   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQMessage *message = messages[indexPath.item];
	if ([self incoming:message])
	{
		if (indexPath.item > 0)
		{
			JSQMessage *previous = messages[indexPath.item-1];
			if ([previous.senderId isEqualToString:message.senderId])
			{
				return 0;
			}
		}
		return kJSQMessagesCollectionViewCellLabelHeightDefault;
	}
	else return 0;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
				   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([self outgoing:messages[indexPath.item]])
	{
		return kJSQMessagesCollectionViewCellLabelHeightDefault;
	}
	else return 0;
}

#pragma mark - Responding to collection view tap events

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(JSQMessagesCollectionView *)collectionView
				header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSLog(@"didTapLoadEarlierMessagesButton");
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView
		   atIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSLog(@"didTapAvatarImageView");
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQMessage *message = messages[indexPath.item];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([self outgoing:message])
	{
		NSDictionary *item = items[indexPath.item];
		if ([item[@"status"] isEqualToString:@"Read"] == NO)
		{
			[self actionDelete];
			return;
		}
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (message.isMediaMessage)
	{
		if ([message.media isKindOfClass:[JSQPhotoMediaItem class]])
		{
			JSQPhotoMediaItem *mediaItem = (JSQPhotoMediaItem *)message.media;
			NSArray *photos = [IDMPhoto photosWithImages:@[mediaItem.image]];
			IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:photos];
			[self presentViewController:browser animated:YES completion:nil];
		}
		if ([message.media isKindOfClass:[VideoMediaItem class]])
		{
			VideoMediaItem *mediaItem = (VideoMediaItem *)message.media;
			MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:mediaItem.fileURL];
			[self presentMoviePlayerViewControllerAnimated:moviePlayer];
			[moviePlayer.moviePlayer play];
		}
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSLog(@"didTapCellAtIndexPath %@", NSStringFromCGPoint(touchLocation));
}

#pragma mark - UIActionSheetDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (actionSheet.tag == 1) [self actionSheet:actionSheet clickedButtonAtIndex1:buttonIndex];
	if (actionSheet.tag == 2) [self actionSheet:actionSheet clickedButtonAtIndex2:buttonIndex];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex1:(NSInteger)buttonIndex
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (buttonIndex != actionSheet.cancelButtonIndex)
	{
		PresentPremium(self);
	}
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex2:(NSInteger)buttonIndex
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (buttonIndex != actionSheet.cancelButtonIndex)
	{
		if (buttonIndex == 0)	PresentMultiCamera(self, YES);
		if (buttonIndex == 1)	PresentPhotoLibrary(self, YES);
		if (buttonIndex == 2)	PresentVideoLibrary(self, YES);
		if (buttonIndex == 3)	PresentPremium(self);
		if (buttonIndex == 4)	PresentPremium(self);
	}
}

#pragma mark - UIImagePickerControllerDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSURL *video = info[UIImagePickerControllerMediaURL];
	UIImage *picture = info[UIImagePickerControllerEditedImage];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self sendMessage:nil Video:video Picture:picture Audio:nil];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Helper methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)incoming:(JSQMessage *)message
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return ([message.senderId isEqualToString:self.senderId] == NO);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)outgoing:(JSQMessage *)message
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return ([message.senderId isEqualToString:self.senderId] == YES);
}

@end
