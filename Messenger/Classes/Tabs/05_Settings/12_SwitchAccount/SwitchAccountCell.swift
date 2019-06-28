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
class SwitchAccountCell: UITableViewCell {

	@IBOutlet var imageUser: UIImageView!
	@IBOutlet var labelInitials: UILabel!
	@IBOutlet var labelName: UILabel!
	@IBOutlet var labelEmail: UILabel!

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func bindData(account: [String: String]) {

		labelName.text = account["fullname"]
		labelEmail.text = account["email"]
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func loadImage(account: [String: String], tableView: UITableView, indexPath: IndexPath) {

		imageUser.layer.cornerRadius = imageUser.frame.size.width / 2
		imageUser.layer.masksToBounds = true

		if let picture = account["picture"] {
			if let path = DownloadManager.pathImage(link: picture) {
				imageUser.image = UIImage(contentsOfFile: path)
				labelInitials.text = nil
			} else {
				imageUser.image = UIImage(named: "switchaccount_blank")
				labelInitials.text = account["initials"]
				downloadImage(picture: picture, tableView: tableView, indexPath: indexPath)
			}
		} else {
			imageUser.image = UIImage(named: "switchaccount_blank")
			labelInitials.text = account["initials"]
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func downloadImage(picture: String, tableView: UITableView, indexPath: IndexPath) {

		DownloadManager.image(link: picture) { path, error, network in
			if (error == nil) {
				if (tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false) {
					let cell = tableView.cellForRow(at: indexPath) as! SwitchAccountCell
					cell.imageUser.image = UIImage(contentsOfFile: path!)
					cell.labelInitials.text = nil
				}
			} else if ((error! as NSError).code == 102) {
				DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
					self.downloadImage(picture: picture, tableView: tableView, indexPath: indexPath)
				}
			}
		}
	}
}
