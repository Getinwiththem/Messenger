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
class AddFriendsCell: UITableViewCell {

	@IBOutlet var imageUser: UIImageView!
	@IBOutlet var labelInitials: UILabel!
	@IBOutlet var labelName: UILabel!
	@IBOutlet var labelStatus: UILabel!

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func bindData(user: FUser) {

		labelName.text = user[FUSER_FULLNAME] as? String
		labelStatus.text = user[FUSER_STATUS] as? String
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func loadImage(user: FUser, tableView: UITableView, indexPath: IndexPath) {

		imageUser.layer.cornerRadius = imageUser.frame.size.width / 2
		imageUser.layer.masksToBounds = true

		if let thumbnail = user[FUSER_THUMBNAIL] as? String {
			if let path = DownloadManager.pathImage(link: thumbnail) {
				imageUser.image = UIImage(contentsOfFile: path)
				labelInitials.text = nil
			} else {
				imageUser.image = UIImage(named: "addfriends_blank")
				labelInitials.text = user.initials()
				downloadImage(thumbnail: thumbnail, tableView: tableView, indexPath: indexPath)
			}
		} else {
			imageUser.image = UIImage(named: "addfriends_blank")
			labelInitials.text = user.initials()
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func downloadImage(thumbnail: String, tableView: UITableView, indexPath: IndexPath) {

		DownloadManager.image(link: thumbnail) { path, error, network in
			if (error == nil) {
				if (tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false) {
					let cell = tableView.cellForRow(at: indexPath) as! AddFriendsCell
					cell.imageUser.image = UIImage(contentsOfFile: path!)
					cell.labelInitials.text = nil
				}
			} else if ((error! as NSError).code == 102) {
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
					self.downloadImage(thumbnail: thumbnail, tableView: tableView, indexPath: indexPath)
				}
			}
		}
	}
}
