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
extension FUser {

	// MARK: - Class methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func fullname() -> String		{ return FUser.currentUser().fullname()			}
	class func initials() -> String		{ return FUser.currentUser().initials()			}
	class func status() -> String		{ return FUser.currentUser().status()			}
	class func loginMethod() -> String	{ return FUser.currentUser().loginMethod()		}
	class func oneSignalId() -> String	{ return FUser.currentUser().oneSignalId()		}

	class func keepMedia() -> Int32		{ return FUser.currentUser().keepMedia()		}
	class func networkPhoto() -> Int32	{ return FUser.currentUser().networkPhoto()		}
	class func networkVideo() -> Int32	{ return FUser.currentUser().networkVideo()		}
	class func networkAudio() -> Int32	{ return FUser.currentUser().networkAudio()		}

	class func wallpaper() -> String	{ return FUser.currentUser().wallpaper() 		}
	class func pictureAt() -> Int64		{ return FUser.currentUser().pictureAt() 		}
	class func isOnboardOk() -> Bool	{ return FUser.currentUser().isOnboardOk()		}

	// MARK: - Instance methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func fullname() -> String			{ return (self[FUSER_FULLNAME] as? String)		?? ""					}
	func status() -> String				{ return (self[FUSER_STATUS] as? String)		?? ""					}
	func loginMethod() -> String		{ return (self[FUSER_LOGINMETHOD] as? String)	?? ""					}
	func oneSignalId() -> String		{ return (self[FUSER_ONESIGNALID] as? String)	?? ""					}

	func keepMedia() -> Int32			{ return (self[FUSER_KEEPMEDIA] as? Int32)		?? KEEPMEDIA_FOREVER	}
	func networkPhoto() -> Int32		{ return (self[FUSER_NETWORKPHOTO] as? Int32)	?? NETWORK_ALL			}
	func networkVideo() -> Int32		{ return (self[FUSER_NETWORKVIDEO] as? Int32)	?? NETWORK_ALL			}
	func networkAudio() -> Int32		{ return (self[FUSER_NETWORKAUDIO] as? Int32)	?? NETWORK_ALL			}

	func wallpaper() -> String			{ return (self[FUSER_WALLPAPER] as? String)		?? ""					}
	func pictureAt() -> Int64			{ return (self[FUSER_PICTUREAT] as? Int64)		?? 0					}
	func isOnboardOk() -> Bool			{ return self[FUSER_FULLNAME] != nil									}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func initials() -> String {

		if let firstname = self[FUSER_FIRSTNAME] as? String {
			if let lastname = self[FUSER_LASTNAME] as? String {
				let initial1 = (firstname.count != 0) ? firstname.prefix(1) : ""
				let initial2 = (lastname.count != 0) ? lastname.prefix(1) : ""
				return "\(initial1)\(initial2)"
			}
		}
		return ""
	}
}
