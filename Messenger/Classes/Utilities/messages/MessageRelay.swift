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
class MessageRelay: NSObject {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func send(dbmessage: DBMessage, completion: @escaping (_ error: Error?) -> Void) {

		let message = FObject(path: FMESSAGE_PATH)

		message[FMESSAGE_OBJECTID] = dbmessage.objectId

		message[FMESSAGE_CHATID] = dbmessage.chatId
		message[FMESSAGE_MEMBERS] = dbmessage.members.components(separatedBy: ",")

		message[FMESSAGE_SENDERID] = dbmessage.senderId
		message[FMESSAGE_SENDERNAME] = dbmessage.senderName
		message[FMESSAGE_SENDERINITIALS] = dbmessage.senderInitials
		message[FMESSAGE_SENDERPICTURE] = dbmessage.senderPicture

		message[FMESSAGE_RECIPIENTID] = dbmessage.recipientId
		message[FMESSAGE_RECIPIENTNAME] = dbmessage.recipientName
		message[FMESSAGE_RECIPIENTINITIALS] = dbmessage.recipientInitials
		message[FMESSAGE_RECIPIENTPICTURE] = dbmessage.recipientPicture

		message[FMESSAGE_GROUPID] = dbmessage.groupId
		message[FMESSAGE_GROUPNAME] = dbmessage.groupName
		message[FMESSAGE_GROUPPICTURE] = dbmessage.groupPicture

		message[FMESSAGE_TYPE] = dbmessage.type
		message[FMESSAGE_TEXT] = Cryptor.encrypt(text: dbmessage.text, chatId: dbmessage.chatId)

		message[FMESSAGE_PICTURE] = dbmessage.picture
		message[FMESSAGE_PICTUREWIDTH] = dbmessage.pictureWidth
		message[FMESSAGE_PICTUREHEIGHT] = dbmessage.pictureHeight
		message[FMESSAGE_PICTUREMD5] = ""

		message[FMESSAGE_VIDEO] = dbmessage.video
		message[FMESSAGE_VIDEODURATION] = dbmessage.videoDuration
		message[FMESSAGE_VIDEOMD5] = ""

		message[FMESSAGE_AUDIO] = dbmessage.audio
		message[FMESSAGE_AUDIODURATION] = dbmessage.audioDuration
		message[FMESSAGE_AUDIOMD5] = ""

		message[FMESSAGE_LATITUDE] = dbmessage.latitude
		message[FMESSAGE_LONGITUDE] = dbmessage.longitude

		message[FMESSAGE_STATUS] = TEXT_SENT
		message[FMESSAGE_ISDELETED] = dbmessage.isDeleted

		message[FMESSAGE_CREATEDAT] = dbmessage.createdAt
		message[FMESSAGE_UPDATEDAT] = dbmessage.updatedAt

		if (dbmessage.type == MESSAGE_TEXT)		{ sendMessage(message: message, completion: completion) 		}
		if (dbmessage.type == MESSAGE_EMOJI)	{ sendMessage(message: message, completion: completion)			}
		if (dbmessage.type == MESSAGE_PICTURE)	{ sendPictureMessage(message: message, completion: completion) 	}
		if (dbmessage.type == MESSAGE_VIDEO)	{ sendVideoMessage(message: message, completion: completion)	}
		if (dbmessage.type == MESSAGE_AUDIO)	{ sendAudioMessage(message: message, completion: completion)	}
		if (dbmessage.type == MESSAGE_LOCATION)	{ sendMessage(message: message, completion: completion)			}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func sendPictureMessage(message: FObject, completion: @escaping (_ error: Error?) -> Void) {

		let chatId = message[FMESSAGE_CHATID] as! String
		let link = message[FMESSAGE_PICTURE] as! String

		if let path = DownloadManager.pathImage(link: link) {
			if let dataPicture = try? Data(contentsOf: URL(fileURLWithPath: path)) {
				if let cryptedPicture = Cryptor.encrypt(data: dataPicture, chatId: chatId) {
					let md5Picture = Checksum.md5HashOf(data: cryptedPicture)
					UploadManager.upload(data: cryptedPicture, name: "message_image", ext: "jpg", completion: { link, error in
						if (error == nil) {
							DownloadManager.saveImage(data: dataPicture, link: link!)
							message[FMESSAGE_PICTURE] = link
							message[FMESSAGE_PICTUREMD5] = md5Picture
							sendMessage(message: message, completion: completion)
						} else { completion(NSError.description("Media upload error.", code: 100)) }
					})
				} else { completion(NSError.description("Media encryption error.", code: 101)) }
			} else { completion(NSError.description("Media file error.", code: 102)) }
		} else { completion(NSError.description("Missing media file.", code: 103)) }
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func sendVideoMessage(message: FObject, completion: @escaping (_ error: Error?) -> Void) {

		let chatId = message[FMESSAGE_CHATID] as! String
		let link = message[FMESSAGE_VIDEO] as! String

		if let path = DownloadManager.pathVideo(link: link) {
			if let dataVideo = try? Data(contentsOf: URL(fileURLWithPath: path)) {
				if let cryptedVideo = Cryptor.encrypt(data: dataVideo, chatId: chatId) {
					let md5Video = Checksum.md5HashOf(data: cryptedVideo)
					UploadManager.upload(data: cryptedVideo, name: "message_video", ext: "mp4", completion: { link, error in
						if (error == nil) {
							DownloadManager.saveVideo(data: dataVideo, link: link!)
							message[FMESSAGE_VIDEO] = link
							message[FMESSAGE_VIDEOMD5] = md5Video
							sendMessage(message: message, completion: completion)
						} else { completion(NSError.description("Media upload error.", code: 100)) }
					})
				} else { completion(NSError.description("Media encryption error.", code: 101)) }
			} else { completion(NSError.description("Media file error.", code: 102)) }
		} else { completion(NSError.description("Missing media file.", code: 103)) }
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func sendAudioMessage(message: FObject, completion: @escaping (_ error: Error?) -> Void) {

		let chatId = message[FMESSAGE_CHATID] as! String
		let link = message[FMESSAGE_AUDIO] as! String

		if let path = DownloadManager.pathAudio(link: link) {
			if let dataAudio = try? Data(contentsOf: URL(fileURLWithPath: path)) {
				if let cryptedAudio = Cryptor.encrypt(data: dataAudio, chatId: chatId) {
					let md5Audio = Checksum.md5HashOf(data: cryptedAudio)
					UploadManager.upload(data: cryptedAudio, name: "message_audio", ext: "m4a", completion: { link, error in
						if (error == nil) {
							DownloadManager.saveAudio(data: dataAudio, link: link!)
							message[FMESSAGE_AUDIO] = link
							message[FMESSAGE_AUDIOMD5] = md5Audio
							sendMessage(message: message, completion: completion)
						} else { completion(NSError.description("Media upload error.", code: 100)) }
					})
				} else { completion(NSError.description("Media encryption error.", code: 101)) }
			} else { completion(NSError.description("Media file error.", code: 102)) }
		} else { completion(NSError.description("Missing media file.", code: 103)) }
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func sendMessage(message: FObject, completion: @escaping (_ error: Error?) -> Void) {

		var multiple: [String: Any] = [:]

		for userId in message[FMESSAGE_MEMBERS] as! [String] {
			let path = "\(userId)/\(message.objectId())"
			multiple[path] = message.values
		}

		let firebase = Database.database().reference(withPath: FMESSAGE_PATH)
		firebase.updateChildValues(multiple, withCompletionBlock: { error, ref in
			if (error == nil) {
				SendPushNotification1(message: message);
				completion(nil)
			} else {
				completion(NSError.description("Message sending failed.", code: 104))
			}
		})
	}
}
