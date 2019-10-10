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
#define		ONESIGNAL_APPID						@"277d0aab-5925-475f-ba99-4af140776900"
//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		SINCH_HOST							@"sandbox.sinch.com"
#define		SINCH_KEY							@"12eb4441-f90b-43f8-a0ed-3c3ff02e1c12"
#define		SINCH_SECRET						@"LwwW9qmV40q1jBrEldaemw=="
//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		DIALOGFLOW_ACCESS_TOKEN				@"bbf2a09367b948e49d44d5aaa97724f6"
//-------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		DEFAULT_TAB							0
#define		DEFAULT_COUNTRY						188
//---------------------------------------------------------------------------------
#define		VIDEO_LENGTH						5
#define		INSERT_MESSAGES						12
#define		DOWNLOAD_TIMEOUT					300
//---------------------------------------------------------------------------------
#define		MEDIA_PHOTO							1
#define		MEDIA_VIDEO							2
#define		MEDIA_AUDIO							3
//---------------------------------------------------------------------------------
#define		NETWORK_MANUAL						1
#define		NETWORK_WIFI						2
#define		NETWORK_ALL							3
//---------------------------------------------------------------------------------
#define		KEEPMEDIA_WEEK						1
#define		KEEPMEDIA_MONTH						2
#define		KEEPMEDIA_FOREVER					3
//---------------------------------------------------------------------------------
#define		CALL_AUDIO							@"audio"
#define		CALL_VIDEO							@"video"
//---------------------------------------------------------------------------------
#define		MESSAGE_TEXT						@"text"
#define		MESSAGE_EMOJI						@"emoji"
#define		MESSAGE_PHOTO						@"photo"
#define		MESSAGE_VIDEO						@"video"
#define		MESSAGE_AUDIO						@"audio"
#define		MESSAGE_LOCATION					@"location"
//---------------------------------------------------------------------------------
#define		STATUS_QUEUED						@"Queued"
#define		STATUS_FAILED						@"Failed"
#define		STATUS_SENT							@"Sent"
#define		STATUS_READ							@"Read"
//---------------------------------------------------------------------------------
#define		MEDIASTATUS_UNKNOWN					0
#define		MEDIASTATUS_LOADING					1
#define		MEDIASTATUS_MANUAL					2
#define		MEDIASTATUS_SUCCEED					3
//---------------------------------------------------------------------------------
#define		AUDIOSTATUS_STOPPED					1
#define		AUDIOSTATUS_PLAYING					2
//---------------------------------------------------------------------------------
#define		LOGIN_EMAIL							@"Email"
#define		LOGIN_PHONE							@"Phone"
//---------------------------------------------------------------------------------
#define		TEXT_SHARE_APP						@"Check out Related Code Messenger https://relatedcode.com"
//-------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		FBLOCKED_PATH						@"Blocked"				//	Path name
#define		FBLOCKED_OBJECTID					@"objectId"				//	String

#define		FBLOCKED_BLOCKEDID					@"blockedId"			//	String
#define		FBLOCKED_ISDELETED					@"isDeleted"			//	Boolean

#define		FBLOCKED_CREATEDAT					@"createdAt"			//	Timestamp
#define		FBLOCKED_UPDATEDAT					@"updatedAt"			//	Timestamp
//---------------------------------------------------------------------------------
#define		FBLOCKER_PATH						@"Blocker"				//	Path name
#define		FBLOCKER_OBJECTID					@"objectId"				//	String

#define		FBLOCKER_BLOCKERID					@"blockerId"			//	String
#define		FBLOCKER_ISDELETED					@"isDeleted"			//	Boolean

#define		FBLOCKER_CREATEDAT					@"createdAt"			//	Timestamp
#define		FBLOCKER_UPDATEDAT					@"updatedAt"			//	Timestamp
//---------------------------------------------------------------------------------
#define		FCALL_PATH							@"Call"					//	Path name
#define		FCALL_OBJECTID						@"objectId"				//	String

#define		FCALL_INITIATORID					@"initiatorId"			//	String
#define		FCALL_RECIPIENTID					@"recipientId"			//	String
#define		FCALL_PHONENUMBER					@"phoneNumber"			//	String

#define		FCALL_TYPE							@"type"					//	String
#define		FCALL_TEXT							@"text"					//	String

#define		FCALL_STATUS						@"status"				//	String
#define		FCALL_DURATION						@"duration"				//	Number

#define		FCALL_STARTEDAT						@"startedAt"			//	Timestamp
#define		FCALL_ESTABLISHEDAT					@"establishedAt"		//	Timestamp
#define		FCALL_ENDEDAT						@"endedAt"				//	Timestamp

#define		FCALL_ISDELETED						@"isDeleted"			//	Boolean

#define		FCALL_CREATEDAT						@"createdAt"			//	Timestamp
#define		FCALL_UPDATEDAT						@"updatedAt"			//	Timestamp
//---------------------------------------------------------------------------------
#define		FCHAT_PATH							@"Chat"					//	Path name
#define		FCHAT_OBJECTID						@"objectId"				//	String
#define		FCHAT_CHATID						@"chatId"				//	String

#define		FCHAT_MEMBERS						@"members"				//	Array
#define		FCHAT_LINKEDS						@"linkeds"				//	Dictionary

#define		FCHAT_SENDERID						@"senderId"				//	String
#define		FCHAT_SENDERFULLNAME				@"senderFullname"		//	String
#define		FCHAT_SENDERINITIALS				@"senderInitials"		//	String
#define		FCHAT_SENDERPICTUREAT				@"senderPictureAt"		//	Timestamp

#define		FCHAT_RECIPIENTID					@"recipientId"			//	String
#define		FCHAT_RECIPIENTFULLNAME				@"recipientFullname"	//	String
#define		FCHAT_RECIPIENTINITIALS				@"recipientInitials"	//	String
#define		FCHAT_RECIPIENTPICTUREAT			@"recipientPictureAt"	//	Timestamp

#define		FCHAT_GROUPID						@"groupId"				//	String
#define		FCHAT_GROUPNAME						@"groupName"			//	String

#define		FCHAT_LASTMESSAGETEXT				@"lastMessageText"		//	String
#define		FCHAT_LASTMESSAGEDATE				@"lastMessageDate"		//	Timestamp

#define		FCHAT_TYPINGS						@"typings"				//	Dictionary
#define		FCHAT_LASTREADS						@"lastReads"			//	Dictionary
#define		FCHAT_MUTEDUNTILS					@"mutedUntils"			//	Dictionary

#define		FCHAT_ARCHIVEDS						@"archiveds"			//	Dictionary
#define		FCHAT_DELETEDS						@"deleteds"				//	Dictionary

#define		FCHAT_CREATEDAT						@"createdAt"			//	Timestamp
#define		FCHAT_UPDATEDAT						@"updatedAt"			//	Timestamp
//---------------------------------------------------------------------------------
#define		FFRIEND_PATH						@"Friend"				//	Path name
#define		FFRIEND_OBJECTID					@"objectId"				//	String

#define		FFRIEND_FRIENDID					@"friendId"				//	String
#define		FFRIEND_ISDELETED					@"isDeleted"			//	Boolean

#define		FFRIEND_CREATEDAT					@"createdAt"			//	Timestamp
#define		FFRIEND_UPDATEDAT					@"updatedAt"			//	Timestamp
//---------------------------------------------------------------------------------
#define		FGROUP_PATH							@"Group"				//	Path name
#define		FGROUP_OBJECTID						@"objectId"				//	String

#define		FGROUP_USERID						@"userId"				//	String
#define		FGROUP_NAME							@"name"					//	String
#define		FGROUP_MEMBERS						@"members"				//	Array
#define		FGROUP_LINKEDS						@"linkeds"				//	Dictionary

#define		FGROUP_ISDELETED					@"isDeleted"			//	Boolean

#define		FGROUP_CREATEDAT					@"createdAt"			//	Timestamp
#define		FGROUP_UPDATEDAT					@"updatedAt"			//	Timestamp
//---------------------------------------------------------------------------------
#define		FMESSAGE_PATH						@"Message"				//	Path name
#define		FMESSAGE_OBJECTID					@"objectId"				//	String

#define		FMESSAGE_CHATID						@"chatId"				//	String
#define		FMESSAGE_MEMBERS					@"members"				//	Array

#define		FMESSAGE_SENDERID					@"senderId"				//	String
#define		FMESSAGE_SENDERFULLNAME				@"senderFullname"		//	String
#define		FMESSAGE_SENDERINITIALS				@"senderInitials"		//	String
#define		FMESSAGE_SENDERPICTUREAT			@"senderPictureAt"		//	Timestamp

#define		FMESSAGE_RECIPIENTID				@"recipientId"			//	String
#define		FMESSAGE_RECIPIENTFULLNAME			@"recipientFullname"	//	String
#define		FMESSAGE_RECIPIENTINITIALS			@"recipientInitials"	//	String
#define		FMESSAGE_RECIPIENTPICTUREAT			@"recipientPictureAt"	//	Timestamp

#define		FMESSAGE_GROUPID					@"groupId"				//	String
#define		FMESSAGE_GROUPNAME					@"groupName"			//	String

#define		FMESSAGE_TYPE						@"type"					//	String
#define		FMESSAGE_TEXT						@"text"					//	String

#define		FMESSAGE_PHOTOWIDTH					@"photoWidth"			//	Number
#define		FMESSAGE_PHOTOHEIGHT				@"photoHeight"			//	Number
#define		FMESSAGE_VIDEODURATION				@"videoDuration"		//	Number
#define		FMESSAGE_AUDIODURATION				@"audioDuration"		//	Number

#define		FMESSAGE_LATITUDE					@"latitude"				//	Number
#define		FMESSAGE_LONGITUDE					@"longitude"			//	Number

#define		FMESSAGE_STATUS						@"status"				//	String
#define		FMESSAGE_ISDELETED					@"isDeleted"			//	Boolean

#define		FMESSAGE_CREATEDAT					@"createdAt"			//	Timestamp
#define		FMESSAGE_UPDATEDAT					@"updatedAt"			//	Timestamp
//---------------------------------------------------------------------------------
#define		FUSER_PATH							@"User"					//	Path name
#define		FUSER_OBJECTID						@"objectId"				//	String

#define		FUSER_EMAIL							@"email"				//	String
#define		FUSER_PHONE							@"phone"				//	String

#define		FUSER_FIRSTNAME						@"firstname"			//	String
#define		FUSER_LASTNAME						@"lastname"				//	String
#define		FUSER_FULLNAME						@"fullname"				//	String
#define		FUSER_COUNTRY						@"country"				//	String
#define		FUSER_LOCATION						@"location"				//	String
#define		FUSER_STATUS						@"status"				//	String

#define		FUSER_KEEPMEDIA						@"keepMedia"			//	Number
#define		FUSER_NETWORKPHOTO					@"networkPhoto"			//	Number
#define		FUSER_NETWORKVIDEO					@"networkVideo"			//	Number
#define		FUSER_NETWORKAUDIO					@"networkAudio"			//	Number
#define		FUSER_WALLPAPER						@"wallpaper"			//	String

#define		FUSER_LOGINMETHOD					@"loginMethod"			//	String
#define		FUSER_ONESIGNALID					@"oneSignalId"			//	String

#define		FUSER_LASTACTIVE					@"lastActive"			//	Timestamp
#define		FUSER_LASTTERMINATE					@"lastTerminate"		//	Timestamp

#define		FUSER_PICTUREAT						@"pictureAt"			//	Timestamp
#define		FUSER_CREATEDAT						@"createdAt"			//	Timestamp
#define		FUSER_UPDATEDAT						@"updatedAt"			//	Timestamp
//-------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------------------------------------
#define		ONESIGNALID							@"OneSignalId"
//---------------------------------------------------------------------------------
#define		NOTIFICATION_APP_STARTED			@"NotificationAppStarted"
#define		NOTIFICATION_USER_LOGGED_IN			@"NotificationUserLoggedIn"
#define		NOTIFICATION_USER_LOGGED_OUT		@"NotificationUserLoggedOut"
//---------------------------------------------------------------------------------
#define		NOTIFICATION_REFRESH_BLOCKEDS		@"NotificationRefreshBlockeds"
#define		NOTIFICATION_REFRESH_BLOCKERS		@"NotificationRefreshBlockers"
#define		NOTIFICATION_REFRESH_CALLS			@"NotificationRefreshCalls"
#define		NOTIFICATION_REFRESH_CHATS			@"NotificationRefreshChats"
#define		NOTIFICATION_REFRESH_FRIENDS		@"NotificationRefreshFriends"
#define		NOTIFICATION_REFRESH_GROUPS			@"NotificationRefreshGroups"
#define		NOTIFICATION_REFRESH_MESSAGES1		@"NotificationRefreshMessages1"
#define		NOTIFICATION_REFRESH_MESSAGES2		@"NotificationRefreshMessages2"
#define		NOTIFICATION_REFRESH_USERS			@"NotificationRefreshUsers"
//---------------------------------------------------------------------------------
#define		NOTIFICATION_CLEANUP_CHATVIEW		@"NotificationCleanupChatView"
//-------------------------------------------------------------------------------------------------------------------------------------------------
