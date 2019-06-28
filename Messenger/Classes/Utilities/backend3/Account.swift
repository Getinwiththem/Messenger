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
class Account: NSObject {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func add(email: String, password: String) {

		var accounts: [String: Any] = [:]

		if let userAccounts = UserDefaultsX.object(key: USER_ACCOUNTS) as? [String: Any] {
			accounts = userAccounts
		}

		let userId = FUser.currentId()
		let fullname = FUser.fullname()
		let initials = FUser.initials()
		let picture = FUser.thumbnail()

		accounts[userId] = ["email": email, "password": password, "fullname": fullname, "initials": initials, "picture": picture]

		UserDefaultsX.setObject(value: accounts, key: USER_ACCOUNTS)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func update() {

		if (FUser.loginMethod() != LOGIN_EMAIL) { return }

		if var accounts = UserDefaultsX.object(key: USER_ACCOUNTS) as? [String: Any] {

			let userId = FUser.currentId()
			let fullname = FUser.fullname()
			let initials = FUser.initials()
			let picture = FUser.thumbnail()

			let account = accounts[userId] as! [String: String]
			let email = account["email"]
			let password = account["password"]

			accounts[userId] = ["email": email, "password": password, "fullname": fullname, "initials": initials, "picture": picture]

			UserDefaultsX.setObject(value: accounts, key: USER_ACCOUNTS)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func delOne() {

		if var accounts = UserDefaultsX.object(key: USER_ACCOUNTS) as? [String: Any] {
			accounts.removeValue(forKey: FUser.currentId())
			UserDefaultsX.setObject(value: accounts, key: USER_ACCOUNTS)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func delAll() {

		UserDefaultsX.removeObject(key: USER_ACCOUNTS)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func count() -> Int {

		let accounts = UserDefaultsX.object(key: USER_ACCOUNTS) as? [String: Any]
		return accounts?.count ?? 0
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func userIds() -> [String] {

		let accounts = UserDefaultsX.object(key: USER_ACCOUNTS) as! [String: Any]
		return Array(accounts.keys).sorted()
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func account(userId: String) -> [String: String] {

		let accounts = UserDefaultsX.object(key: USER_ACCOUNTS) as! [String: Any]
		return accounts[userId] as! [String: String]
	}
}
