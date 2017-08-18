/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import MobileCoreServices
import UIKit

extension UIPasteboard {

    func addImageWithData(_ data: Data, forURL url: URL) {
        let isGIF = UIImage.dataIsGIF(data)

        // Setting pasteboard.items allows us to set multiple representations for the same item.
        items = [[
            kUTTypeURL as String: url,
            imageTypeKey(isGIF): data
        ]]
    }

    fileprivate func imageTypeKey(_ isGIF: Bool) -> String {
        return (isGIF ? kUTTypeGIF : kUTTypePNG) as String
    }

    @available(*, deprecated, message: "use asyncURL(:) instead")
    var copiedURL: URL? {
        return self.syncURL
    }

    private var syncURL: URL? {
        if let string = UIPasteboard.general.string,
            let url = URL(string: string), url.isWebPage() {
            return url
        } else {
            return nil
        }
    }

    func asyncString(queue: DispatchQueue = DispatchQueue.main, callback: @escaping (String?) -> ()) {
        fetchAsync(queue: queue, callback: callback) {
            return UIPasteboard.general.string
        }
    }

    func asyncURL(queue: DispatchQueue = DispatchQueue.main, callback: @escaping (URL?) -> ()) {
        fetchAsync(queue: queue, callback: callback) {
            return self.syncURL
        }
    }

    // Converts the potentially long running synchronous operation into an asynchronous one.
    // The given queue is the dispatch queue that the given callback should be called upon.
    private func fetchAsync<T>(queue: DispatchQueue,
                            callback: @escaping (T?) -> (),
                            getter: @escaping () -> T?) {
        DispatchQueue.global().async {
            let value = getter()
            queue.async {
                callback(value)
            }
        }
    }
}
