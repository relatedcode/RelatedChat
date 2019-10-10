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
class Image: NSObject {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func square(image: UIImage, size: CGFloat) -> UIImage {

		var cropped: UIImage!

		if (image.size.width == image.size.height) {
			cropped = image
		} else if (image.size.width > image.size.height) {
			let xpos = (image.size.width - image.size.height) / 2
			cropped = crop(image: image, x: xpos, y: 0, width: image.size.height, height: image.size.height)
		} else if (image.size.height > image.size.width) {
			let ypos = (image.size.height - image.size.width) / 2
			cropped = crop(image: image, x: 0, y: ypos, width: image.size.width, height: image.size.width)
		}

		return resize(image: cropped, width: size, height: size, scale: 1)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func resize(image: UIImage, width: CGFloat, height: CGFloat, scale: CGFloat) -> UIImage {

		let size = CGSize(width: width, height: height)
		let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)

		UIGraphicsBeginImageContextWithOptions(size, false, scale)
		image.draw(in: rect)
		let resized = UIGraphicsGetImageFromCurrentImageContext()!
		UIGraphicsEndImageContext()

		return resized
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func crop(image: UIImage, x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat) -> UIImage {

		let rect = CGRect(x: x, y: y, width: width, height: height)

		let cgImage = image.cgImage?.cropping(to: rect)
		let cropped = UIImage(cgImage: cgImage!)

		return cropped
	}
}
