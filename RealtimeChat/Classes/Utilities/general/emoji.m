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

#import "emoji.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
BOOL ContainsEmoji(NSString *string)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	BOOL __block result = NO;

	[string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences
		usingBlock: ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop)
	{
		if (IsEmoji(substring))
		{
			*stop = YES;
			result = YES;
		}
	}];

	return result;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
BOOL IsEmoji(NSString *string)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	if ([string length] == 2)
	{
		const unichar high = [string characterAtIndex:0];

		if (0xd800 <= high && high <= 0xdbff)
		{
			const unichar low = [string characterAtIndex:1];
			const int codepoint = ((high - 0xd800) * 0x400) + (low - 0xdc00) + 0x10000;

			return (0x1d000 <= codepoint && codepoint <= 0x1f77f);
		}
		else return (0x2100 <= high && high <= 0x27bf);
	}
	return NO;
}
