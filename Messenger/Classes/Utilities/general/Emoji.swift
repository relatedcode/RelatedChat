//
// Copyright (c) 2018 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

//-------------------------------------------------------------------------------------------------------------------------------------------------
class Emoji: NSObject {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func isEmoji(text: String) -> Bool {

		if (text.count == 1) {

			let temp = NSString(string: text)
			let high = unichar(temp.character(at: 0))

			if ((0xd800 <= high) && (high <= 0xdbff)) {

				let low  = unichar(temp.character(at: 1))
				let codepoint = (Int((high - 0xd800)) * 0x400) + Int((low - 0xdc00)) + 0x10000

				return (0x1d000 <= codepoint) && (codepoint <= 0x1f77f)

			} else {
				return (0x2100 <= high) && (high <= 0x27bf)
			}
		}
		return false
	}
}
