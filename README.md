<img src="https://relatedcode.com/github/header14.png" width="880">

## OVERVIEW

This is a native iOS Messenger app, with audio/video calls and realtime chat conversations (full offline support).

---

<img src="https://relatedcode.com/screen52/chat03.png" width="290">.<img src="https://relatedcode.com/screen52/call1.png" width="290">.<img src="https://relatedcode.com/screen52/chats01.png" width="290">
<img src="https://relatedcode.com/screen52/settings2.png" width="290">.<img src="https://relatedcode.com/screen52/chats02.png" width="290">.<img src="https://relatedcode.com/screen52/chat07.png" width="290">

---

## ADDITIONAL FEATURES

- Full source code is available for all features
- Video call (in-app video calling over data connection)
- Audio call (in-app audio calling over data connection)
- Message queue (creating new messages while offline)
- User last active (or currently online) status info
- Spotlight search for users
- Media download network settings (Wi-Fi, Cellular or Manual)
- Cache settings for media messages (automatic/manual cleanup)
- Media message re-download option
- Dynamic password generation
- Block users
- Forward messages
- Mute push notifications
- Home screen quick actions
- Share media message content

## KEY FEATURES

- AI powered chat interface
- Firebase backend (full realtime actions)
- Realm local database (full offline availability)
- AES-256 encryption

## FEATURES

- Live chat between multiple devices
- Private chat functionality
- Group chat functionality
- Push notification support
- No backend programming is needed
- Native and easy to customize user interface
- Login with Email
- Login with SMS
- Sending text messages
- Sending pictures
- Sending videos
- Sending audio messages
- Sending current location
- Sending stickers
- Sending large emojis
- Media file local cache
- Load earlier messages
- Typing indicator
- Message delivery receipt
- Message read receipt
- Save picture messages to device
- Save video messages to device
- Save audio messages to device
- Delete read and unread messages
- Realtime conversation view for ongoing chats
- Archived conversation view for archived chats
- All media view for chat media files
- Picture view for multiple pictures
- Map view for shared locations
- Basic Settings view included
- Basic Profile view for users
- Edit Profile view for changing user details
- Onboarding view on signup
- Wallpaper backgrounds for Chat view
- Call history view
- Privacy Policy view
- Terms of Service view
- Video length limit possibility
- Copy and paste text messages
- Arbitrary message sizes
- Send/Receive sound effects
- Deployment target: iOS 11.0+
- Supported devices: iPhone 5s, SE, 6, 6 Plus, 6s, 6s Plus, 7, 7 Plus, 8, 8 Plus, iPhone X, XS, XR, XS Max

---

<img src="https://relatedcode.com/screen52/addfriends.png" width="290">.<img src="https://relatedcode.com/screen52/chat08.png" width="290">.<img src="https://relatedcode.com/screen52/stickers.png" width="290">
<img src="https://relatedcode.com/screen52/settings_cache.png" width="290">.<img src="https://relatedcode.com/screen52/settings_archive1.png" width="290">.<img src="https://relatedcode.com/screen52/chat04.png" width="290">

---

## REQUIREMENTS

- Xcode 9.3+
- iOS 11.0+
- ARC

## INSTALLATION

**1.,** Run `pod install` first (the CocoaPods Frameworks and Libraries are not included in the repo). If you haven't used CocoaPods before, you can get started [here](https://guides.cocoapods.org/using/getting-started.html). You might prefer to use the [CocoaPods app](https://cocoapods.org/app) over the command line tool.

**2.,** Create an account at [Firebase](https://firebase.google.com) and create a New project for your application.

**3.,** Set up your Firebase [Authentication](https://firebase.google.com/docs/auth) sign-in methods.

**4.,** For using Phone login, configure your Firebase Authentication Settings as it [described here](https://firebase.google.com/docs/auth/ios/phone-auth).

**5.,** Enable your Firebase [Realtime Database](https://firebase.google.com/docs/database) by updating the Realtime Database Rules with [these values](https://github.com/relatedcode/Messenger/issues/165).

**6.,** Enable your Firebase [Storage](https://firebase.google.com/docs/storage) by updating the Storage Rules with the default vaules.

**7.,** Download `GoogleService-Info.plist` from your Firebase project and replace the existing file in your Xcode project.

**8.,** For using push notification feature, create an account at [OneSignal](https://onesignal.com) and replace the `ONESIGNAL_APPID` define value in `AppConstant.h`. You will also need to [configure](https://documentation.onesignal.com/docs/generating-an-ios-push-certificate) your Push certificate details.

**9.,** For using audio and video call features, create an account at [Sinch](https://www.sinch.com) and replace the `SINCH_KEY` and `SINCH_SECRET` define values in `AppConstant.h`. You will also need to [configure](https://www.sinch.com/tutorials/ios8-apps-and-pushkit) your VoIP certificate details.

**10.,** For using the AI powered chat interface you need to configure your [Dialogflow](https://console.dialogflow.com) console. You also need to update the `DIALOGFLOW_ACCESS_TOKEN` define value in `AppConstant.h`.

---

<img src="https://relatedcode.com/screen52/profile2.png" width="290">.<img src="https://relatedcode.com/screen52/people.png" width="290">.<img src="https://relatedcode.com/screen52/chat06.png" width="290">
<img src="https://relatedcode.com/screen52/chat05.png" width="290">.<img src="https://relatedcode.com/screen52/settings1.png" width="290">.<img src="https://relatedcode.com/screen52/chats03.png" width="290">

---

## CONTACT

Do you have any questions or idea? My email is: info@relatedcode.com or you can find some more info at [relatedcode.com](http://relatedcode.com)

## LICENSE

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

---

<img src="https://relatedcode.com/screen52/chat01.png" width="290">.<img src="https://relatedcode.com/screen52/call2.png" width="290">.<img src="https://relatedcode.com/screen52/profile1.png" width="290">
<img src="https://relatedcode.com/screen52/allmedia.png" width="290">.<img src="https://relatedcode.com/screen52/picture1.png" width="290">.<img src="https://relatedcode.com/screen52/settings_status1.png" width="290">
