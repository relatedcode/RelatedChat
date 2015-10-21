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

#import "AppConstant.h"

#import "VideoMediaItem.h"

#import "JSQMessagesMediaPlaceholderView.h"
#import "JSQMessagesMediaViewBubbleImageMasker.h"

#import "UIImage+JSQMessages.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface VideoMediaItem()

@property (strong, nonatomic) UIImageView *cachedVideoImageView;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation VideoMediaItem

#pragma mark - Initialization

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (instancetype)initWithFileURL:(NSURL *)fileURL
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super init];
	if (self)
	{
		_fileURL = [fileURL copy];
		_cachedVideoImageView = nil;
	}
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)dealloc
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	_fileURL = nil;
	_cachedVideoImageView = nil;
}

#pragma mark - Setters

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)setFileURL:(NSURL *)fileURL
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	_fileURL = [fileURL copy];
	_cachedVideoImageView = nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)setImage:(UIImage *)image
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	_image = [image copy];
	_cachedVideoImageView = nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)setAppliesMediaViewMaskAsOutgoing:(BOOL)appliesMediaViewMaskAsOutgoing
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super setAppliesMediaViewMaskAsOutgoing:appliesMediaViewMaskAsOutgoing];
	_cachedVideoImageView = nil;
}

#pragma mark - JSQMessageMediaData protocol

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UIView *)mediaView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (self.status == STATUS_LOADING)
	{
		return nil;
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ((self.status == STATUS_FAILED) && (self.cachedVideoImageView == nil))
	{
		CGSize size = [self mediaViewDisplaySize];
		BOOL outgoing = self.appliesMediaViewMaskAsOutgoing;

		UIImage *icon = [UIImage imageNamed:@"videomediaitem_reload"];
		UIImageView *iconView = [[UIImageView alloc] initWithImage:icon];
		CGFloat ypos = (size.height - icon.size.height) / 2;
		CGFloat xpos = (size.width - icon.size.width) / 2;
		iconView.frame = CGRectMake(xpos, ypos, icon.size.width, icon.size.height);

		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, size.height)];
		imageView.backgroundColor = [UIColor lightGrayColor];
		imageView.clipsToBounds = YES;
		[imageView addSubview:iconView];

		[JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:imageView isOutgoing:outgoing];
		self.cachedVideoImageView = imageView;
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ((self.status == STATUS_SUCCEED) && (self.cachedVideoImageView == nil))
	{
		CGSize size = [self mediaViewDisplaySize];
		BOOL outgoing = self.appliesMediaViewMaskAsOutgoing;

		UIImage *icon = [[UIImage jsq_defaultPlayImage] jsq_imageMaskedWithColor:[UIColor whiteColor]];
		UIImageView *iconView = [[UIImageView alloc] initWithImage:icon];
		iconView.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
		iconView.contentMode = UIViewContentModeCenter;

		UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
		imageView.frame = CGRectMake(0.0f, 0.0f, size.width, size.height);
		imageView.contentMode = UIViewContentModeScaleAspectFill;
		imageView.clipsToBounds = YES;
		[imageView addSubview:iconView];

		[JSQMessagesMediaViewBubbleImageMasker applyBubbleImageMaskToMediaView:imageView isOutgoing:outgoing];
		self.cachedVideoImageView = imageView;
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return self.cachedVideoImageView;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSUInteger)mediaHash
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return self.hash;
}

#pragma mark - NSObject

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (BOOL)isEqual:(id)object
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (![super isEqual:object])
	{
		return NO;
	}
	
	VideoMediaItem *videoItem = (VideoMediaItem *)object;
	
	return [self.fileURL isEqual:videoItem.fileURL];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSUInteger)hash
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return super.hash ^ self.fileURL.hash;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSString *)description
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [NSString stringWithFormat:@"<%@: fileURL=%@, appliesMediaViewMaskAsOutgoing=%@>",
			[self class], self.fileURL, @(self.appliesMediaViewMaskAsOutgoing)];
}

#pragma mark - NSCoding

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (instancetype)initWithCoder:(NSCoder *)aDecoder
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	self = [super initWithCoder:aDecoder];
	if (self)
	{
		_fileURL = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(fileURL))];
	}
	return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)encodeWithCoder:(NSCoder *)aCoder
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[super encodeWithCoder:aCoder];
	[aCoder encodeObject:self.fileURL forKey:NSStringFromSelector(@selector(fileURL))];
}

#pragma mark - NSCopying

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (instancetype)copyWithZone:(NSZone *)zone
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	VideoMediaItem *copy = [[[self class] allocWithZone:zone] initWithFileURL:self.fileURL];
	copy.appliesMediaViewMaskAsOutgoing = self.appliesMediaViewMaskAsOutgoing;
	return copy;
}

@end
