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
class UploadManager: NSObject {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func upload(data: Data, name: String, ext: String, completion: @escaping (_ link: String?, _ error: Error?) -> Void) {
		
		let timestamp = Date().timestamp()
		let child = "\(FUser.currentId())/\(name)/\(timestamp).\(ext)"

		let reference = Storage.storage().reference().child(child)
		let task = reference.putData(data, metadata: nil, completion: nil)

		task.observe(StorageTaskStatus.success, handler: { snapshot in
			task.removeAllObservers()
			reference.downloadURL(completion: { URL, error in
				if (error == nil) {
					completion(URL!.absoluteString, nil)
				} else {
					completion(nil, NSError.description("URL fetch failed.", code: 101))
				}
			})
		})

		task.observe(StorageTaskStatus.failure, handler: { snapshot in
			task.removeAllObservers()
			completion(nil, NSError.description("Upload failed.", code: 100))
		})
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func upload(data: Data, name: String, ext: String, progress: @escaping (_ progress: Float) -> Void,
					  completion: @escaping (_ link: String?, _ error: Error?) -> Void) {

		let timestamp = Date().timestamp()
		let child = "\(FUser.currentId())/\(name)/\(timestamp).\(ext)"

		let reference = Storage.storage().reference().child(child)
		let task = reference.putData(data, metadata: nil, completion: nil)

		task.observe(StorageTaskStatus.progress, handler: { snapshot in
			progress(Float(snapshot.progress!.completedUnitCount) / Float(snapshot.progress!.totalUnitCount))
		})

		task.observe(StorageTaskStatus.success, handler: { snapshot in
			task.removeAllObservers()
			reference.downloadURL(completion: { URL, error in
				if (error == nil) {
					completion(URL!.absoluteString, nil)
				} else {
					completion(nil, NSError.description("URL fetch failed.", code: 101))
				}
			})
		})

		task.observe(StorageTaskStatus.failure, handler: { snapshot in
			task.removeAllObservers()
			completion(nil, NSError.description("Upload failed.", code: 100))
		})
	}
}
