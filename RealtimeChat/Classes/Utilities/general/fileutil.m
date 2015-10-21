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

#import "fileutil.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
NSString* Applications(NSString *file)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *path = [[NSBundle mainBundle] resourcePath];
	if (file != nil) path = [path stringByAppendingPathComponent:file];
	return path;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
NSString* Documents(NSString *file)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	if (file != nil) path = [path stringByAppendingPathComponent:file];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *dir = [path stringByDeletingLastPathComponent];
	if (FileExist(dir) == NO) DirCreate(dir);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return path;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
NSString* Caches(NSString *file)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
	if (file != nil) path = [path stringByAppendingPathComponent:file];
	//---------------------------------------------------------------------------------------------------------------------------------------------
	NSString *dir = [path stringByDeletingLastPathComponent];
	if (FileExist(dir) == NO) DirCreate(dir);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	return path;
}

//=================================================================================================================================================

//-------------------------------------------------------------------------------------------------------------------------------------------------
BOOL DirCreate(NSString *dir)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:YES attributes:nil error:nil];;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
BOOL FileExist(NSString *path)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
BOOL FileDelete(NSString *path)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void FileCopy(NSString *path1, NSString *path2, BOOL overwrite)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if (overwrite) FileDelete(path2);
	//---------------------------------------------------------------------------------------------------------------------------------------------
	if (FileExist(path2) == NO) [[NSFileManager defaultManager] copyItemAtPath:path1 toPath:path2 error:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
NSUInteger FileSize(NSString *path)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	return (NSUInteger) [[[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil] fileSize];
}
