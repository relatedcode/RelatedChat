//
// Copyright (c) 2014 Related Code - http://relatedcode.com
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
#import "camera.h"
#import "messages.h"
#import "pushnotification.h"

#import "ChatView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface ChatView()
{
	NSString *roomId;

	BOOL initialized;
	FirebaseHandle handle;

	NSMutableArray *messages;
	NSMutableDictionary *avatars;

	JSQMessagesBubbleImage *outgoingBubbleImageData;
	JSQMessagesBubbleImage *incomingBubbleImageData;
	
	JSQMessagesAvatarImage *placeholderImageData;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation ChatView

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWith:(NSString *)roomId_
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	roomId = roomId_;
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidLoad];
	self.title = @"Chat";

	messages = [[NSMutableArray alloc] init];
	avatars = [[NSMutableDictionary alloc] init];

	PFUser *user = [PFUser currentUser];
	self.senderId = user.objectId;
	self.senderDisplayName = user[PF_USER_FULLNAME];

	JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
	outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
	incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];

	placeholderImageData = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"chat_blank"] diameter:30.0];

	[self loadMessages];

	ClearMessageCounter(roomId);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewDidAppear:animated];
	self.collectionView.collectionViewLayout.springinessEnabled = YES;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewWillDisappear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super viewWillDisappear:animated];
	[self.firebase removeAllObservers];
}

#pragma mark - Backend methods

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadMessages
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	initialized = NO;
	self.firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/%@", FIREBASE, roomId]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[self.firebase observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot)
	{
		NSString *userId = snapshot.value[@"userId"];
		NSString *name = snapshot.value[@"name"];
		NSString *dateStr = snapshot.value[@"date"];
		NSString *text = snapshot.value[@"text"];

		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'zzz'"];
		[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
		NSDate *date = [formatter dateFromString:dateStr];

		JSQMessage *message = [[JSQMessage alloc] initWithSenderId:userId senderDisplayName:name date:date text:text];
		[messages addObject:message];

		if (initialized)
		{
			[JSQSystemSoundPlayer jsq_playMessageReceivedSound];
			[self finishReceivingMessage];
		}
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	handle = [self.firebase observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
	{
		[self.firebase removeObserverWithHandle:handle];
		
		[self finishReceivingMessage];
		[ProgressHUD dismiss];
		
		initialized	= YES;
	}];
}

#pragma mark - JSQMessagesViewController method overrides

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'zzz'"];
	[formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	NSString *dateStr = [formatter stringFromDate:date];

	[[self.firebase childByAutoId] setValue:@{@"text":text, @"userId":senderId, @"date":dateStr, @"name":senderDisplayName}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	SendPushNotification(roomId, text);
	UpdateMessageCounter(roomId, text);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[JSQSystemSoundPlayer jsq_playMessageSentSound];
	[self finishSendingMessage];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didPressAccessoryButton:(UIButton *)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSLog(@"didPressAccessoryButton");
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
	JSQMessage *message = messages[indexPath.item];
	if ([message.senderId isEqualToString:self.senderId])
	{
		return outgoingBubbleImageData;
	}
	return incomingBubbleImageData;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
					avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQMessage *message = messages[indexPath.item];
	NSString *userId = [message senderId];

	if (avatars[userId] == nil)
	{
		PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
		[query whereKey:PF_USER_OBJECTID equalTo:userId];
		[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
		{
			if (error == nil)
			{
				if ([objects count] != 0)
				{
					PFUser *user = [objects firstObject];
					PFFile *fileThumbnail = user[PF_USER_THUMBNAIL];
					[fileThumbnail getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error)
					{
						if (error == nil)
						{
							UIImage *image = [UIImage imageWithData:imageData];
							avatars[userId] = [JSQMessagesAvatarImageFactory avatarImageWithImage:image diameter:30.0];
							[self.collectionView reloadData];
						}
						else NSLog(@"Network error.");
					}];
				}
			}
			else NSLog(@"Network error.");
		}];
		return placeholderImageData;
	}
	else return avatars[userId];
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
	return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQMessage *message = messages[indexPath.item];
	if ([message.senderId isEqualToString:self.senderId])
	{
		return nil;
	}

	if (indexPath.item - 1 > 0)
	{
		JSQMessage *previousMessage = messages[indexPath.item-1];
		if ([previousMessage.senderId isEqualToString:message.senderId])
		{
			return nil;
		}
	}
	return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return nil;
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
	
	JSQMessage *message = messages[indexPath.item];
	if ([message.senderId isEqualToString:self.senderId])
	{
		cell.textView.textColor = [UIColor blackColor];
	}
	else
	{
		cell.textView.textColor = [UIColor whiteColor];
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
	return 0.0f;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
				   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQMessage *message = messages[indexPath.item];
	if ([message.senderId isEqualToString:self.senderId])
	{
		return 0.0f;
	}
	
	if (indexPath.item - 1 > 0)
	{
		JSQMessage *previousMessage = messages[indexPath.item-1];
		if ([previousMessage.senderId isEqualToString:message.senderId])
		{
			return 0.0f;
		}
	}
	return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
				   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return 0.0f;
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
	NSLog(@"didTapMessageBubbleAtIndexPath");
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSLog(@"didTapCellAtIndexPath %@", NSStringFromCGPoint(touchLocation));
}

@end
