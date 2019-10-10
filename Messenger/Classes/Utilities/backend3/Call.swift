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
class Call: NSObject {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func createItem(userId: String, recipientId: String, name: String, details: SINCallDetails) {

		let orientation = (userId == recipientId) ? "↘️" : "↗️"
		let type = details.isVideoOffered ? "Video" : "Audio"

		var status = "None"
		if (details.endCause == SINCallEndCause.timeout)				{ status = "Unreachable"			}
		if (details.endCause == SINCallEndCause.denied)					{ status = "Rejected"				}
		if (details.endCause == SINCallEndCause.noAnswer)				{ status = "No answer"				}
		if (details.endCause == SINCallEndCause.error)					{ status = "Error"					}
		if (details.endCause == SINCallEndCause.hungUp)					{ status = "Succeed"				}
		if (details.endCause == SINCallEndCause.canceled)				{ status = "Canceled"				}
		if (details.endCause == SINCallEndCause.otherDeviceAnswered)	{ status = "Other device answered"	}

		var duration = 0
		if (details.endCause == SINCallEndCause.hungUp) {
			if let establishedTime = details.establishedTime {
				duration = Int(details.endedTime.timeIntervalSince(establishedTime))
			}
		}

		let object = FObject(path: FCALL_PATH, subpath: userId)

		object[FCALL_INITIATORID] = FUser.currentId()
		object[FCALL_RECIPIENTID] = recipientId
		object[FCALL_TYPE] = details.isVideoOffered ? CALL_VIDEO : CALL_AUDIO
		object[FCALL_TEXT] = name
		object[FCALL_STATUS] = "\(orientation) \(type) - \(status)"
		object[FCALL_DURATION] = duration

		object[FCALL_STARTEDAT]		= 0
		object[FCALL_ESTABLISHEDAT]	= 0
		object[FCALL_ENDEDAT]		= 0

		if let started = details.startedTime		 { object[FCALL_STARTEDAT]		= started.timestamp()		}
		if let established = details.establishedTime { object[FCALL_ESTABLISHEDAT]	= established.timestamp()	}
		if let ended = details.endedTime			 { object[FCALL_ENDEDAT]		= ended.timestamp()			}

		object[FCALL_ISDELETED] = false

		object.saveInBackground(block: { error in
			if (error != nil) {
				ProgressHUD.showError("Network error.")
			}
		})
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func deleteItem(objectId: String) {

		let object = FObject(path: FCALL_PATH, subpath: FUser.currentId())

		object[FCALL_OBJECTID] = objectId
		object[FCALL_ISDELETED] = true

		object.updateInBackground(block: { error in
			if (error != nil) {
				ProgressHUD.showError("Network error.")
			}
		})
	}
}
