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
class CacheManager: NSObject {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func cleanupExpired() {

		if (FUser.currentId() != "") {
			if (FUser.keepMedia() == KEEPMEDIA_WEEK) {
				cleanupExpired(days: 7)
			}
			if (FUser.keepMedia() == KEEPMEDIA_MONTH) {
				cleanupExpired(days: 30)
			}
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func cleanupExpired(days: Int) {

		var isDir: ObjCBool = false
		let extensions = ["jpg", "mp4", "m4a"]

		let past = Date().addingTimeInterval(TimeInterval(-days * 24 * 60 * 60))

		// Clear Documents files
		//-----------------------------------------------------------------------------------------------------------------------------------------
		if let enumerator = FileManager.default.enumerator(atPath: Dir.document()) {
			while let file = enumerator.nextObject() as? String {
				let path = Dir.document(file)
				FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
				if (isDir.boolValue == false) {
					let ext = (path as NSString).pathExtension
					if (extensions.contains(ext)) {
						let created = File.created(path: path)
						if (created.compare(past) == .orderedAscending) {
							File.remove(path: path)
						}
					}
				}
			}
		}

		// Clear Caches files
		//-----------------------------------------------------------------------------------------------------------------------------------------
		if let files = try? FileManager.default.contentsOfDirectory(atPath: Dir.cache()) {
			for file in files {
				let path = Dir.cache(file)
				FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
				if (isDir.boolValue == false) {
					let ext = (path as NSString).pathExtension
					if (ext == "mp4") {
						let created = File.created(path: path)
						if (created.compare(past) == .orderedAscending) {
							File.remove(path: path)
						}
					}
				}
			}
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func cleanupManual(logout: Bool) {

		var isDir: ObjCBool = false
		let extensions = logout ? ["jpg", "mp4", "m4a", "manual", "loading"] : ["jpg", "mp4", "m4a"]

		// Clear Documents files
		//-----------------------------------------------------------------------------------------------------------------------------------------
		if let enumerator = FileManager.default.enumerator(atPath: Dir.document()) {
			while let file = enumerator.nextObject() as? String {
				let path = Dir.document(file)
				FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
				if (isDir.boolValue == false) {
					let ext = (path as NSString).pathExtension
					if (extensions.contains(ext)) {
						File.remove(path: path)
					}
				}
			}
		}

		// Clear Caches files
		//-----------------------------------------------------------------------------------------------------------------------------------------
		if let files = try? FileManager.default.contentsOfDirectory(atPath: Dir.cache()) {
			for file in files {
				let path = Dir.cache(file)
				FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
				if (isDir.boolValue == false) {
					let ext = (path as NSString).pathExtension
					if (ext == "mp4") {
						File.remove(path: path)
					}
				}
			}
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func total() -> Int64 {

		var isDir: ObjCBool = false
		let extensions = ["jpg", "mp4", "m4a"]

		var total: Int64 = 0

		// Count Documents files
		//-----------------------------------------------------------------------------------------------------------------------------------------
		if let enumerator = FileManager.default.enumerator(atPath: Dir.document()) {
			while let file = enumerator.nextObject() as? String {
				let path = Dir.document(file)
				FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
				if (isDir.boolValue == false) {
					let ext = (path as NSString).pathExtension
					if (extensions.contains(ext)) {
						total += File.size(path: path)
					}
				}
			}
		}

		// Count Caches files
		//-----------------------------------------------------------------------------------------------------------------------------------------
		if let files = try? FileManager.default.contentsOfDirectory(atPath: Dir.cache()) {
			for file in files {
				let path = Dir.cache(file)
				FileManager.default.fileExists(atPath: path, isDirectory: &isDir)
				if (isDir.boolValue == false) {
					let ext = (path as NSString).pathExtension
					if (ext == "mp4") {
						total += File.size(path: path)
					}
				}
			}
		}

		return total
	}
}
