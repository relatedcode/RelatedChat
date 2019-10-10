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
class LocationManager: NSObject, CLLocationManagerDelegate {

	var locationManager: CLLocationManager?
	var coordinate = CLLocationCoordinate2D()

	//---------------------------------------------------------------------------------------------------------------------------------------------
	static let shared: LocationManager = {
		let instance = LocationManager()
		return instance
	} ()

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func start() {

		shared.locationManager?.startUpdatingLocation()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func stop() {

		shared.locationManager?.stopUpdatingLocation()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func latitude() -> CLLocationDegrees {

		return shared.coordinate.latitude
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func longitude() -> CLLocationDegrees {

		return shared.coordinate.longitude
	}

	// MARK: - Instance methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	override init() {

		super.init()

		locationManager = CLLocationManager()
		locationManager?.delegate = self
		locationManager?.desiredAccuracy = kCLLocationAccuracyBest
		locationManager?.requestWhenInUseAuthorization()
	}

	// MARK: - CLLocationManagerDelegate
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

		if let location = locations.last {
			coordinate = location.coordinate
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {

	}
}
