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
class GroupsCell: UITableViewCell {

	@IBOutlet var imageGroup: UIImageView!
	@IBOutlet var labelName: UILabel!
	@IBOutlet var labelMembers: UILabel!

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func bindData(dbgroup: DBGroup) {

		labelName.text = dbgroup.name

		let members = dbgroup.members.components(separatedBy: ",")
		labelMembers.text = "\(members.count) members"
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func loadImage(dbgroup: DBGroup, tableView: UITableView, indexPath: IndexPath) {

		imageGroup.layer.cornerRadius = imageGroup.frame.size.width / 2
		imageGroup.layer.masksToBounds = true

		if let path = DownloadManager.pathImage(link: dbgroup.picture) {
			imageGroup.image = UIImage(contentsOfFile: path)
		} else {
			imageGroup.image = UIImage(named: "groups_blank")
			downloadImage(dbgroup: dbgroup, tableView: tableView, indexPath: indexPath)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func downloadImage(dbgroup: DBGroup, tableView: UITableView, indexPath: IndexPath) {

		DownloadManager.image(link: dbgroup.picture) { path, error, network in
			if (error == nil) {
				if (tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false) {
					let cell = tableView.cellForRow(at: indexPath) as! GroupsCell
					cell.imageGroup.image = UIImage(contentsOfFile: path!)
				}
			}
		}
	}
}
