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
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	var tabBarController: UITabBarController!

	var chatsView: ChatsView!
	var callsView: CallsView!
	var peopleView: PeopleView!
	var groupsView: GroupsView!
	var settingsView: SettingsView!

	@objc var sinchService: SINService?

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {

		//-----------------------------------------------------------------------------------------------------------------------------------------
		// Firebase initialization
		//-----------------------------------------------------------------------------------------------------------------------------------------
		FirebaseApp.configure()
		Database.database().isPersistenceEnabled = false
		FirebaseConfiguration().setLoggerLevel(.error)

		//-----------------------------------------------------------------------------------------------------------------------------------------
		// Dialogflow initialization
		//-----------------------------------------------------------------------------------------------------------------------------------------
		let configuration = AIDefaultConfiguration()
		configuration.clientAccessToken = DIALOGFLOW_ACCESS_TOKEN
		ApiAI.shared().configuration = configuration

		//-----------------------------------------------------------------------------------------------------------------------------------------
		// Push notification initialization
		//-----------------------------------------------------------------------------------------------------------------------------------------
		let authorizationOptions: UNAuthorizationOptions = [.sound, .alert, .badge]
		UNUserNotificationCenter.current().requestAuthorization(options: authorizationOptions, completionHandler: { granted, error in
			if (error == nil) {
				DispatchQueue.main.async {
					UIApplication.shared.registerForRemoteNotifications()
				}
			}
		})

		//-----------------------------------------------------------------------------------------------------------------------------------------
		// OneSignal initialization
		//-----------------------------------------------------------------------------------------------------------------------------------------
		OneSignal.initWithLaunchOptions(launchOptions, appId: ONESIGNAL_APPID, handleNotificationReceived: nil, handleNotificationAction: nil, settings: [kOSSettingsKeyAutoPrompt: false])
		OneSignal.setLogLevel(ONE_S_LOG_LEVEL.LL_NONE, visualLevel: ONE_S_LOG_LEVEL.LL_NONE)
		OneSignal.inFocusDisplayType = OSNotificationDisplayType.none

		//-----------------------------------------------------------------------------------------------------------------------------------------
		// Firebase auth issue fix
		//-----------------------------------------------------------------------------------------------------------------------------------------
		if (UserDefaults.bool(key: "Initialized") == false) {
			UserDefaults.setObject(value: true, key: "Initialized")
			FUser.logOut()
		}

		//-----------------------------------------------------------------------------------------------------------------------------------------
		// Shortcut items initialization
		//-----------------------------------------------------------------------------------------------------------------------------------------
		Shortcut.create()

		//-----------------------------------------------------------------------------------------------------------------------------------------
		// Manager initialization
		//-----------------------------------------------------------------------------------------------------------------------------------------
		_ = Connectivity.shared
		_ = LocationManager.shared
		_ = RelayManager.shared

		//-----------------------------------------------------------------------------------------------------------------------------------------
		// Backend observer initialization
		//-----------------------------------------------------------------------------------------------------------------------------------------
		_ = Blockeds.shared
		_ = Blockers.shared
		_ = Calls.shared
		_ = Chats.shared
		_ = Friends.shared
		_ = Groups.shared
		_ = Messages.shared
		_ = Users.shared

		//-----------------------------------------------------------------------------------------------------------------------------------------
		// UI initialization
		//-----------------------------------------------------------------------------------------------------------------------------------------
		window = UIWindow(frame: UIScreen.main.bounds)

		chatsView = ChatsView(nibName: "ChatsView", bundle: nil)
		callsView = CallsView(nibName: "CallsView", bundle: nil)
		peopleView = PeopleView(nibName: "PeopleView", bundle: nil)
		groupsView = GroupsView(nibName: "GroupsView", bundle: nil)
		settingsView = SettingsView(nibName: "SettingsView", bundle: nil)

		let navController1 = NavigationController(rootViewController: chatsView)
		let navController2 = NavigationController(rootViewController: callsView)
		let navController3 = NavigationController(rootViewController: peopleView)
		let navController4 = NavigationController(rootViewController: groupsView)
		let navController5 = NavigationController(rootViewController: settingsView)

		tabBarController = UITabBarController()
		tabBarController.viewControllers = [navController1, navController2, navController3, navController4, navController5]
		tabBarController.tabBar.isTranslucent = false
		tabBarController.selectedIndex = Int(DEFAULT_TAB)

		window?.rootViewController = tabBarController
		window?.makeKeyAndVisible()

		_ = chatsView.view
		_ = callsView.view
		_ = peopleView.view
		_ = groupsView.view
		_ = settingsView.view

		//-----------------------------------------------------------------------------------------------------------------------------------------
		// Sinch initialization
		//-----------------------------------------------------------------------------------------------------------------------------------------
		let config = SinchService.config(withApplicationKey: SINCH_KEY, applicationSecret: SINCH_SECRET, environmentHost: SINCH_HOST).pushNotifications(with: SINAPSEnvironment.development).disableMessaging()

		sinchService = SinchService.service(with: config)
		sinchService?.delegate = self
		sinchService?.callClient().delegate = self
		sinchService?.push().setDesiredPushType(SINPushTypeVoIP)

		NotificationCenter.addObserver(target: self, selector: #selector(sinchLogInUser), name: NOTIFICATION_APP_STARTED)
		NotificationCenter.addObserver(target: self, selector: #selector(sinchLogInUser), name: NOTIFICATION_USER_LOGGED_IN)
		NotificationCenter.addObserver(target: self, selector: #selector(sinchLogOutUser), name: NOTIFICATION_USER_LOGGED_OUT)

		return true
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func applicationWillResignActive(_ application: UIApplication) {

	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func applicationDidEnterBackground(_ application: UIApplication) {

		LocationManager.stop()
		Userx.updateLastTerminate(fetch: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func applicationWillEnterForeground(_ application: UIApplication) {

	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func applicationDidBecomeActive(_ application: UIApplication) {

		LocationManager.start()
		Userx.updateLastActive()

		if let status = OneSignal.getPermissionSubscriptionState() {
			UserDefaults.removeObject(key: ONESIGNALID)
			if (status.subscriptionStatus.pushToken != nil) {
				if let userId = status.subscriptionStatus.userId {
					UserDefaults.setObject(value: userId, key: ONESIGNALID)
				}
			}
			Userx.updateOneSignalId()
		}

		CacheManager.cleanupExpired()

		NotificationCenter.post(notification: NOTIFICATION_APP_STARTED)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func applicationWillTerminate(_ application: UIApplication) {

	}

	// MARK: - CoreSpotlight methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {

		if (userActivity.activityType == CSSearchableItemActionType) {
			if let activityIdentifier = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String {
				print("AppDelegate continueUserActivity: \(activityIdentifier)")
				return true
			}
		}
		return false
	}

	// MARK: - Sinch user methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func sinchLogInUser() {

		if (FUser.currentId() != "") {
			sinchService?.logInUser(withId: FUser.currentId())
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func sinchLogOutUser() {

		sinchService?.logOutUser()
	}

	// MARK: - Push notification methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {

		Auth.auth().setAPNSToken(deviceToken, type: .unknown)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {

	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

		if (Auth.auth().canHandleNotification(userInfo)) {
			completionHandler(.noData)
		}
	}

	// MARK: - Home screen dynamic quick action methods
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {

		if (shortcutItem.type == "newchat") {
			chatsView.actionNewChat()
		}

		if (shortcutItem.type == "newgroup") {
			groupsView.actionNewGroup()
		}

		if (shortcutItem.type == "recentuser") {
			if let userInfo = shortcutItem.userInfo as? [String: String] {
				if let userId = userInfo["userId"] {
					chatsView.actionRecentUser(userId: userId)
				}
			}
		}

		if (shortcutItem.type == "shareapp") {
			if let topViewController = topViewController() {
				var shareitems: [AnyHashable] = []
				shareitems.append(TEXT_SHARE_APP)
				let activityView = UIActivityViewController(activityItems: shareitems, applicationActivities: nil)
				topViewController.present(activityView, animated: true)
			}
		}
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func topViewController() -> UIViewController? {

		var viewController = UIApplication.shared.keyWindow?.rootViewController
		while (viewController?.presentedViewController != nil) {
			viewController = viewController?.presentedViewController
		}
		return viewController
	}
}

// MARK: - SINServiceDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension AppDelegate: SINServiceDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func service(_ service: SINService?) throws {

	}
}

// MARK: - SINCallClientDelegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
extension AppDelegate: SINCallClientDelegate {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func client(_ client: SINCallClient?, didReceiveIncomingCall call: SINCall?) {

		if (call!.details.isVideoOffered) {
			if let topViewController = topViewController() {
				let callVideoView = CallVideoView(call: call)
				topViewController.present(callVideoView, animated: true)
			}
		} else {
			if let topViewController = topViewController() {
				let callAudioView = CallAudioView(call: call)
				topViewController.present(callAudioView, animated: true)
			}
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func client(_ client: SINCallClient?, localNotificationForIncomingCall call: SINCall?) -> SINLocalNotification? {

		let notification = SINLocalNotification()
		notification.alertAction = "Answer"
		notification.alertBody = "Incoming call"
		notification.soundName = "call_incoming.wav"
		return notification
	}
}
