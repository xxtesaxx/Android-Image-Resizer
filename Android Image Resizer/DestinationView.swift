/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */


import Cocoa

protocol DestinationViewDelegate {
    func processImageURL(_ urls: URL)
    func isReceivingDrag(_ isReceiving: Bool)
}

class DestinationView: NSView {
    
    enum Appearance {
        static let lineWidth: CGFloat = 10.0
    }
    
    var delegate: DestinationViewDelegate?
    
    override func awakeFromNib() {
        register(forDraggedTypes: [NSURLPboardType])
    }
    
    override func hitTest(_ aPoint: NSPoint) -> NSView? {
        return nil
    }
    
    let filteringOptions = [NSPasteboardURLReadingContentsConformToTypesKey:NSImage.imageTypes()]
    
    func shouldAllowDrag(_ draggingInfo: NSDraggingInfo) -> Bool {
        let pasteBoard = draggingInfo.draggingPasteboard()
        if pasteBoard.canReadObject(forClasses: [NSURL.self], options: filteringOptions) {
            return true
        }
        return false
    }
    
    var isReceivingDrag = false {
        didSet {
            delegate?.isReceivingDrag(isReceivingDrag)
        }
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let allow = shouldAllowDrag(sender)
        isReceivingDrag = allow
        return allow ? .copy : NSDragOperation()
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {
        isReceivingDrag = false
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let allow = shouldAllowDrag(sender)
        return allow
    }
    
    override func performDragOperation(_ draggingInfo: NSDraggingInfo) -> Bool {
        isReceivingDrag = false
        let pasteBoard = draggingInfo.draggingPasteboard()
        if let urls = pasteBoard.readObjects(forClasses: [NSURL.self], options:filteringOptions) as? [URL], urls.count > 0 {
            delegate?.processImageURL(urls[0])
            return true
        }
        return false
    }
}
