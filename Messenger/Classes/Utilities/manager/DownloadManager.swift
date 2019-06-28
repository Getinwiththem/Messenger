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
class DownloadManager: NSObject {

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func image(link: String, completion: @escaping (_ path: String?, _ error: Error?, _ network: Bool) -> Void) {

		start(link: link, ext: "jpg", md5: nil, manual: false, completion: completion)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func image(link: String, md5: String?, completion: @escaping (_ path: String?, _ error: Error?, _ network: Bool) -> Void) {

		start(link: link, ext: "jpg", md5: md5, manual: true, completion: completion)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func video(link: String, md5: String?, completion: @escaping (_ path: String?, _ error: Error?, _ network: Bool) -> Void) {

		start(link: link, ext: "mp4", md5: md5, manual: true, completion: completion)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func audio(link: String, md5: String?, completion: @escaping (_ path: String?, _ error: Error?, _ network: Bool) -> Void) {

		start(link: link, ext: "m4a", md5: md5, manual: true, completion: completion)
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func start(link: String, ext: String, md5: String?, manual checkManual: Bool,
					 completion: @escaping (_ path: String?, _ error: Error?, _ network: Bool) -> Void) {

		// Check if link is missing
		//-----------------------------------------------------------------------------------------------------------------------------------------
		if (link.count == 0) {
			completion(nil, NSError.description("Missing link error.", code: 100), false)
			return
		}

		//-----------------------------------------------------------------------------------------------------------------------------------------
		let file = filename(link: link, ext: ext)

		let path = Dir.document(file)
		let manual = Dir.document(file + ".manual")
		let loading = Dir.document(file + ".loading")

		// Check if file is already downloaded
		//-----------------------------------------------------------------------------------------------------------------------------------------
		if (File.exist(path: path)) {
			completion(path, nil, false)
			return
		}

		// Check if manual download is required
		//-----------------------------------------------------------------------------------------------------------------------------------------
		if (checkManual) {
			if (File.exist(path: manual)) {
				completion(nil, NSError.description("Manual download required.", code: 101), false)
				return
			}
			try? "manual".write(toFile: manual, atomically: false, encoding: .utf8)
		}

		// Check if file is currently downloading
		//-----------------------------------------------------------------------------------------------------------------------------------------
		let time = Int(Date().timeIntervalSince1970)

		if (File.exist(path: loading)) {
			if let temp = try? String(contentsOfFile: loading, encoding: .utf8) {
				if let check = Int(temp) {
					if (time - check < DOWNLOAD_TIMEOUT) {
						completion(nil, NSError.description("Downloading.", code: 102), false)
						return
					}
				}
			}
		}

		try? "\(time)".write(toFile: loading, atomically: false, encoding: .utf8)

		// Download the file
		//-----------------------------------------------------------------------------------------------------------------------------------------
		if let url = URL(string: link) {
			let request = URLRequest(url: url)
			let task = URLSession.shared.downloadTask(with: request, completionHandler: { location, response, error in
				if (error == nil) {
					do {
						try FileManager.default.moveItem(at: location!, to: URL(fileURLWithPath: path))
						if (File.size(path: path) != 0) {
							if (md5 == nil) {
								succeed(file: file, completion: completion)
							} else {
								if (md5 == Checksum.md5HashOf(path: path)) {
									succeed(file: file, completion: completion)
								} else { failed(file: file, error: NSError.description("MD5 checksum error.", code: 103), completion: completion) }
							}
						} else { failed(file: file, error: NSError.description("File lenght error.", code: 104), completion: completion) }
					} catch { failed(file: file, error: NSError.description("File move error.", code: 105), completion: completion) }
				} else { failed(file: file, error: error, completion: completion) }
			})
			task.resume()
		} else { failed(file: file, error: NSError.description("Link URL error.", code: 106), completion: completion) }
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func succeed(file: String, completion: @escaping (_ path: String?, _ error: Error?, _ network: Bool) -> Void) {

		let path = Dir.document(file)
		let loading = Dir.document(file + ".loading")

		File.remove(path: loading)

		DispatchQueue.main.async {
			completion(path, nil, true)
		}
	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func failed(file: String, error: Error?, completion: @escaping (_ path: String?, _ error: Error?, _ network: Bool) -> Void) {

		let path = Dir.document(file)
		let loading = Dir.document(file + ".loading")

		File.remove(path: path)
		File.remove(path: loading)

		DispatchQueue.main.async {
			completion(nil, error, true)
		}
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func fileImage(link: String) -> String { return filename(link: link, ext: "jpg") 	}
	class func fileVideo(link: String) -> String { return filename(link: link, ext: "mp4") 	}
	class func fileAudio(link: String) -> String { return filename(link: link, ext: "m4a") 	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func filename(link: String, ext: String) -> String {

		let file = Checksum.md5HashOf(string: link)
		return "\(file).\(ext)"
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func pathImage(link: String) -> String? { return path(link: link, ext: "jpg") 	}
	class func pathVideo(link: String) -> String? { return path(link: link, ext: "mp4")		}
	class func pathAudio(link: String) -> String? { return path(link: link, ext: "m4a") 	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func path(link: String, ext: String) -> String? {

		let file = filename(link: link, ext: ext)
		let path = Dir.document(file)
		if (File.exist(path: path)) {
			return path
		}
		return nil
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func clearManualImage(link: String) { clearManual(link: link, ext: "jpg") 	}
	class func clearManualVideo(link: String) { clearManual(link: link, ext: "mp4") 	}
	class func clearManualAudio(link: String) { clearManual(link: link, ext: "m4a") 	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func clearManual(link: String, ext: String) {

		let file = filename(link: link, ext: ext)
		let manual = Dir.document(file + ".manual")
		File.remove(path: manual)
	}

	// MARK: -
	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func saveImage(data: Data, link: String) { saveData(data: data, file: fileImage(link: link))	}
	class func saveVideo(data: Data, link: String) { saveData(data: data, file: fileVideo(link: link))	}
	class func saveAudio(data: Data, link: String) { saveData(data: data, file: fileAudio(link: link))	}

	//---------------------------------------------------------------------------------------------------------------------------------------------
	class func saveData(data: Data, file: String) {

		do {
			let path = Dir.document(file)
			try data.write(to: URL(fileURLWithPath: path), options: .atomic)
		} catch { print("DownloadManager saveData error.") }
	}
}
