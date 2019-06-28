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
class MediaLoader: NSObject {

	// MARK: - Picture public
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func loadPicture(rcmessage: RCMessage, dbmessage: DBMessage, tableView: UITableView) {

		if let path = DownloadManager.pathImage(link: dbmessage.picture) {
			showPictureFile(rcmessage: rcmessage, path: path, tableView: tableView)
		} else {
			loadPictureMedia(rcmessage: rcmessage, dbmessage: dbmessage, tableView: tableView)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func loadPictureManual(rcmessage: RCMessage, dbmessage: DBMessage, tableView: UITableView) {

		DownloadManager.clearManualImage(link: dbmessage.picture)
		downloadPictureMedia(rcmessage: rcmessage, dbmessage: dbmessage, tableView: tableView)
	}

	// MARK: - Picture private
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func loadPictureMedia(rcmessage: RCMessage, dbmessage: DBMessage, tableView: UITableView) {

		let network = FUser.networkImage()

		if (network == NETWORK_MANUAL) || ((network == NETWORK_WIFI) && (Connection.isReachableViaWiFi() == false)) {
			rcmessage.status = Int(STATUS_MANUAL)
		} else {
			downloadPictureMedia(rcmessage: rcmessage, dbmessage: dbmessage, tableView: tableView)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func downloadPictureMedia(rcmessage: RCMessage, dbmessage: DBMessage, tableView: UITableView) {

		rcmessage.status = Int(STATUS_LOADING)

		DownloadManager.image(link: dbmessage.picture, md5: dbmessage.pictureMD5) { path, error, network in
			if (error == nil) {
				if (network) {
					Cryptor.decrypt(path: path!, chatId: dbmessage.chatId)
				}
				showPictureFile(rcmessage: rcmessage, path: path!, tableView: tableView)
			} else {
				rcmessage.status = Int(STATUS_MANUAL)
			}
			tableView.reloadData()
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func showPictureFile(rcmessage: RCMessage, path: String, tableView: UITableView) {

		rcmessage.picture_image = UIImage(contentsOfFile: path)
		rcmessage.status = Int(STATUS_SUCCEED)
	}

	// MARK: - Video public
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func loadVideo(rcmessage: RCMessage, dbmessage: DBMessage, tableView: UITableView) {

		if let path = DownloadManager.pathVideo(link: dbmessage.video) {
			showVideoFile(rcmessage: rcmessage, path: path, tableView: tableView)
		} else {
			loadVideoMedia(rcmessage: rcmessage, dbmessage: dbmessage, tableView: tableView)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func loadVideoManual(rcmessage: RCMessage, dbmessage: DBMessage, tableView: UITableView) {

		DownloadManager.clearManualVideo(link: dbmessage.video)
		downloadVideoMedia(rcmessage: rcmessage, dbmessage: dbmessage, tableView: tableView)
	}

	// MARK: - Video private
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func loadVideoMedia(rcmessage: RCMessage, dbmessage: DBMessage, tableView: UITableView) {

		let network = FUser.networkVideo()

		if (network == NETWORK_MANUAL) || ((network == NETWORK_WIFI) && (Connection.isReachableViaWiFi() == false)) {
			rcmessage.status = Int(STATUS_MANUAL)
		} else {
			downloadVideoMedia(rcmessage: rcmessage, dbmessage: dbmessage, tableView: tableView)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func downloadVideoMedia(rcmessage: RCMessage, dbmessage: DBMessage, tableView: UITableView) {

		rcmessage.status = Int(STATUS_LOADING)

		DownloadManager.video(link: dbmessage.video, md5: dbmessage.videoMD5) { path, error, network in
			if (error == nil) {
				if (network) {
					Cryptor.decrypt(path: path!, chatId: dbmessage.chatId)
				}
				showVideoFile(rcmessage: rcmessage, path: path!, tableView: tableView)
			} else {
				rcmessage.status = Int(STATUS_MANUAL)
			}
			tableView.reloadData()
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func showVideoFile(rcmessage: RCMessage, path: String, tableView: UITableView) {

		rcmessage.video_path = path
		let picture = Video.thumbnail(path: path)
		rcmessage.video_thumbnail = Image.square(image: picture, size: 320)
		rcmessage.status = Int(STATUS_SUCCEED)
	}

	// MARK: - Audio public
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func loadAudio(rcmessage: RCMessage, dbmessage: DBMessage, tableView: UITableView) {

		if let path = DownloadManager.pathAudio(link: dbmessage.audio) {
			showAudioFile(rcmessage: rcmessage, path: path, tableView: tableView)
		} else {
			loadAudioMedia(rcmessage: rcmessage, dbmessage: dbmessage, tableView: tableView)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func loadAudioManual(rcmessage: RCMessage, dbmessage: DBMessage, tableView: UITableView) {

		DownloadManager.clearManualAudio(link: dbmessage.audio)
		downloadAudioMedia(rcmessage: rcmessage, dbmessage: dbmessage, tableView: tableView)
	}

	// MARK: - Audio private
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func loadAudioMedia(rcmessage: RCMessage, dbmessage: DBMessage, tableView: UITableView) {

		let network = FUser.networkAudio()

		if (network == NETWORK_MANUAL) || ((network == NETWORK_WIFI) && (Connection.isReachableViaWiFi() == false)) {
			rcmessage.status = Int(STATUS_MANUAL)
		} else {
			downloadAudioMedia(rcmessage: rcmessage, dbmessage: dbmessage, tableView: tableView)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func downloadAudioMedia(rcmessage: RCMessage, dbmessage: DBMessage, tableView: UITableView) {

		rcmessage.status = Int(STATUS_LOADING)

		DownloadManager.audio(link: dbmessage.audio, md5: dbmessage.audioMD5) { path, error, network in
			if (error == nil) {
				if (network) {
					Cryptor.decrypt(path: path!, chatId: dbmessage.chatId)
				}
				showAudioFile(rcmessage: rcmessage, path: path!, tableView: tableView)
			} else {
				rcmessage.status = Int(STATUS_MANUAL)
			}
			tableView.reloadData()
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func showAudioFile(rcmessage: RCMessage, path: String, tableView: UITableView) {

		rcmessage.audio_path = path
		rcmessage.status = Int(STATUS_SUCCEED)
	}
}
