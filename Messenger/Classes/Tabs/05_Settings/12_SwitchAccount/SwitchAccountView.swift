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
class SwitchAccountView: UIViewController, UITableViewDataSource, UITableViewDelegate {

	@IBOutlet var tableView: UITableView!

	//---------------------------------------------------------------------------------------------------------------------------------------------
	override func viewDidLoad() {

		super.viewDidLoad()
		title = "Switch Account"

		navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(actionCancel))

		tableView.register(UINib(nibName: "SwitchAccountCell", bundle: nil), forCellReuseIdentifier: "SwitchAccountCell")

		tableView.tableFooterView = UIView()
	}

	// MARK: - User actions
	//---------------------------------------------------------------------------------------------------------------------------------------------
	@objc func actionCancel() {

		dismiss(animated: true)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func actionSwitch(index: Int) {

		ProgressHUD.show(nil, interaction: false)

		let userIds = Account.userIds()
		let userId = userIds[index]
		let account = Account.account(userId: userId)

		if let email = account["email"] {
			if let password = account["password"] {
				FUser.signIn(email: email, password: password) { user, error in
					if (error == nil) {
						UserLoggedIn(loginMethod: LOGIN_EMAIL)
						self.dismiss(animated: true)
					} else {
						ProgressHUD.showError(error!.localizedDescription)
					}
				}
			}
		}
	}

	// MARK: - Table view data source
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func numberOfSections(in tableView: UITableView) -> Int {

		return 1
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return Account.count()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchAccountCell", for: indexPath) as! SwitchAccountCell

		let userIds = Account.userIds()
		let userId = userIds[indexPath.row]
		let account = Account.account(userId: userId)

		cell.bindData(account: account)
		cell.loadImage(account: account, tableView: tableView, indexPath: indexPath)

		cell.accessoryType = (FUser.currentId() == userId) ? .checkmark : .none

		return cell
	}

	// MARK: - Table view delegate
	//---------------------------------------------------------------------------------------------------------------------------------------------
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.deselectRow(at: indexPath, animated: true)

		if (Connection.isReachable()) {
			LogoutUser(delAccount: DEL_ACCOUNT_NONE)
			actionSwitch(index: indexPath.row)
		} else {
			ProgressHUD.showError("No network connection.")
		}
	}
}
