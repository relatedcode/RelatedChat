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
extension Date {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func timestamp() -> Int64 {

		return Int64(self.timeIntervalSince1970 * 1000)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	static func date(timestamp: Int64) -> Date {

		let interval = TimeInterval(TimeInterval(timestamp) / 1000)
		return Date(timeIntervalSince1970: interval)
	}
}
