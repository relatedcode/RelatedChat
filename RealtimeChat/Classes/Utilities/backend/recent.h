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

//-------------------------------------------------------------------------------------------------------------------------------------------------
NSString*		StartPrivateChat		(PFUser *user1, PFUser *user2);

//-------------------------------------------------------------------------------------------------------------------------------------------------
NSString*		StartMultipleChat		(NSMutableArray *users);

//-------------------------------------------------------------------------------------------------------------------------------------------------
void			StartGroupChat			(PFObject *group);

//-------------------------------------------------------------------------------------------------------------------------------------------------
void			RestartRecentChat		(NSDictionary *recent);

//-------------------------------------------------------------------------------------------------------------------------------------------------
void			CreateRecent			(NSString *userId, NSString *groupId, NSArray *members, NSString *desc, NSString *profileId, NSString *type);
void			CreateRecents			(NSString *groupId, NSArray *members, NSString *desc, NSString *profileId, NSString *type);

void			CreateRecentItem		(NSString *userId, NSString *groupId, NSArray *members, NSString *desc, NSString *profileId, NSString *type);

//-------------------------------------------------------------------------------------------------------------------------------------------------
void			UpdateRecents			(NSString *groupId, NSString *lastMessage);
void			UpdateRecentItem		(NSDictionary *recent, NSString *lastMessage);

//-------------------------------------------------------------------------------------------------------------------------------------------------
void			ClearRecentCounter		(NSString *groupId);
void			ClearRecentCounterItem	(NSDictionary *recent);

//-------------------------------------------------------------------------------------------------------------------------------------------------
void			DeleteRecents			(PFUser *user1, PFUser *user2);
void			DeleteRecentItem		(NSDictionary *recent);
