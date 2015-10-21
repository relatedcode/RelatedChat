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

#import <UIKit/UIKit.h>

//-------------------------------------------------------------------------------------------------------------------------------------------------
NSString*		Applications			(NSString *file);
NSString*		Documents				(NSString *file);
NSString*		Caches					(NSString *file);

//-------------------------------------------------------------------------------------------------------------------------------------------------
BOOL			DirCreate				(NSString *dir);
BOOL			FileExist				(NSString *path);
BOOL			FileDelete				(NSString *path);
void			FileCopy				(NSString *path1, NSString *path2, BOOL overwrite);
NSUInteger		FileSize				(NSString *path);
