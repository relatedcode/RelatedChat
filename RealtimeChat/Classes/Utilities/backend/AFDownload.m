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

#import "AFNetworking.h"
#import "AiChecksum.h"

#import "utilities.h"

#import "AFDownload.h"

@implementation AFDownload

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)start:(NSString *)link complete:(void (^)(NSString *path, NSError *error, BOOL network))complete
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[self start:link md5:nil complete:complete];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)start:(NSString *)link md5:(NSString *)md5 complete:(void (^)(NSString *path, NSError *error, BOOL network))complete
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Check if link is missing
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([link length] == 0) { complete(nil, NSERROR(@"Missing link", 100), NO); return; }
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *file = [link stringByReplacingOccurrencesOfString:LINK_PARSE withString:@""];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *path = Documents(file);
	NSString *stat = Documents([file stringByAppendingString:@".loading"]);
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Check if file is already downloaded
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([[NSFileManager defaultManager] fileExistsAtPath:path]) { complete(path, nil, NO); return; }
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	// Check if file is currently downloading
	//---------------------------------------------------------------------------------------------------------------------------------------------
	int time = (int) [[NSDate date] timeIntervalSince1970];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if ([[NSFileManager defaultManager] fileExistsAtPath:stat])
	{
		int check = [[NSString stringWithContentsOfFile:stat encoding:NSUTF8StringEncoding error:nil] intValue];
		if (time - check < AFDOWNLOAD_TIMEOUT) return;
	}
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[[NSString stringWithFormat:@"%d", time] writeToFile:stat atomically:NO encoding:NSUTF8StringEncoding error:nil];
	//---------------------------------------------------------------------------------------------------------------------------------------------

	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:link]];
	AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
	operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
	[operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
	{
		if (FileSize(path) != 0)
		{
			if (md5 != nil)
			{
				if ([md5 isEqualToString:[AiChecksum md5HashOfPath:path]])
				{
					[self succeed:path stat:stat complete:complete];
				}
				else [self failed:path stat:stat error:NSERROR(@"MD5 checksum", 101) complete:complete];
			}
			else [self succeed:path stat:stat complete:complete];
		}
		else [self failed:path stat:stat error:NSERROR(@"Zero lenght", 102) complete:complete];
	}
	failure:^(AFHTTPRequestOperation *operation, NSError *error)
	{
		[self failed:path stat:stat error:error complete:complete];
	}];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	[[NSOperationQueue mainQueue] addOperation:operation];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)succeed:(NSString *)path stat:(NSString *)stat
	   complete:(void (^)(NSString *path, NSError *error, BOOL network))complete
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	FileDelete(stat);
	complete(path, nil, YES);
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
+ (void)failed:(NSString *)path stat:(NSString *)stat error:(NSError *)error
	  complete:(void (^)(NSString *path, NSError *error, BOOL network))complete
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	FileDelete(path);
	FileDelete(stat);
	complete(nil, error, YES);
}

@end
