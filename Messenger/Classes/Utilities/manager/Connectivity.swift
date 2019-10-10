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
class Connectivity: NSObject {

	var reachability: Reachability?

	//---------------------------------------------------------------------------------------------------------------------------------------------
	static let shared: Connectivity = {
		let instance = Connectivity()
		return instance
	} ()

	// MARK: - Reachability methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func isReachable() -> Bool {

		return shared.reachability?.isReachable() ?? false
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func isReachableViaWWAN() -> Bool {

		return shared.reachability?.isReachableViaWWAN() ?? false
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func isReachableViaWiFi() -> Bool {

		return shared.reachability?.isReachableViaWiFi() ?? false
	}

	// MARK: - Instance methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	override init() {

		super.init()

		reachability = Reachability(hostname: "www.google.com")
		reachability?.startNotifier()

		let notification = NSNotification.Name.reachabilityChanged
		NotificationCenter.addObserver(target: self, selector: #selector(reachabilityChanged(_:)), name: notification.rawValue)
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func reachabilityChanged(_ notification: Notification?) {

	}
}
