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

#import "AppConstant.h"
#import "converters.h"
#import "messages.h"
#import "pushnotification.h"

#import "ChatView.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface ChatView()
{
	NSString *groupId;

	BOOL initialized;
	Firebase *firebase;

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
	messages = [[NSMutableArray alloc] init];
	avatars = [[NSMutableDictionary alloc] init];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	PFUser *user = [PFUser currentUser];
	self.senderId = user.objectId;
	self.senderDisplayName = user[PF_USER_FULLNAME];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
	bubbleImageOutgoing = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
	bubbleImageIncoming = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	avatarImageBlank = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"chat_blank"] diameter:30.0];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	firebase = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"%@/Chat/%@", FIREBASE, groupId]];
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
		ClearMessageCounter(groupId);
		[firebase removeAllObservers];
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
	[firebase observeEventType:FEventTypeChildAdded withBlock:^(FDataSnapshot *snapshot)
	{
		JSQMessage *message = [self addMessage:snapshot.value];

		if (initialized)
		{
			if ([self incoming:message])
				[JSQSystemSoundPlayer jsq_playMessageReceivedSound];
			[self finishReceivingMessage];
		}
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[firebase observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot)
	{
		[self finishReceivingMessage];
		[self scrollToBottomAnimated:NO];
		self.automaticallyScrollsToMostRecentMessage = YES;
		initialized	= YES;
	}];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (JSQMessage *)addMessage:(NSDictionary *)values
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *userId = values[@"userId"];
	NSString *name = values[@"name"];
	NSDate *date = String2Date(values[@"date"]);
	NSString *text = values[@"text"];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	JSQMessage *message = [[JSQMessage alloc] initWithSenderId:userId senderDisplayName:name date:date text:text];
	[messages addObject:message];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return message;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sendMessage:(NSString *)text
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	PFUser *user = [PFUser currentUser];
	NSString *userId = user.objectId;
	NSString *name = user[PF_USER_FULLNAME];
	NSString *date = Date2String([NSDate date]);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSDictionary *values = @{@"text":text, @"userId":userId, @"date":date, @"name":name};
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[[firebase childByAutoId] setValue:values withCompletionBlock:^(NSError *error, Firebase *ref)
	{
		if (error != nil) NSLog(@"saveMessage network error.");
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	SendPushNotification(groupId, text);
	UpdateMessageCounter(groupId, text);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[JSQSystemSoundPlayer jsq_playMessageSentSound];
	[self finishSendingMessage];
}

#pragma mark - JSQMessagesViewController method overrides

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self sendMessage:text];
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
	if ([self outgoing:messages[indexPath.item]])
	{
		return bubbleImageOutgoing;
	}
	return bubbleImageIncoming;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
					avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	JSQMessage *message = messages[indexPath.item];
	NSString *userId = message.senderId;

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
		return avatarImageBlank;
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

	if ([self outgoing:messages[indexPath.item]])
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
	return 0;
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
