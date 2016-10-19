//
//  GIFPreview.swift
//  GIFPop
//
//  Created by Matt Reagan on 10/9/16.
//  Copyright © 2016 Matt Reagan. All rights reserved.
//

import Cocoa
import CoreServices

protocol GIFPreviewDelegate: class {
    func gifPreview(preview: GIFPreview, receivedGIF pathToGIF: String)
}

/****************************************************************************/
/*  GIFPreview View */
/****************************************************************************/

class GIFPreview: NSView {
    //MARK: - Properties -
    
    lazy var dropHereImage: NSImage = { return NSImage(named: "dropGifHere")! }()
    var gifView: NSImageView?
    var gifWidthConstraint: NSLayoutConstraint?
    var gifHeightConstraint: NSLayoutConstraint?
    weak var delegate: GIFPreviewDelegate?
    
    var animates: Bool {
        set(newAnimates) {
            gifView?.animates = newAnimates
        }
        
        get {
            if gifView != nil {
                return gifView!.animates
            }

            return false
        }
    }
    
    //MARK: - Displaying GIFs -
    
    func displayAimatedGIF(gif: NSImage?, atSize size: NSSize) {
        if gif != nil {
            if gifView == nil {
                gifView = createGIFImageView()
                self.addSubview(gifView!)
                
                applyGIFViewConstraints(atSize: size)
            } else {
                gifWidthConstraint?.constant = size.width
                gifHeightConstraint?.constant = size.height
            }
            
            gifView?.image = gif
        } else {
            gifView?.removeFromSuperview()
            gifView = nil
        }
        
        self.setNeedsDisplay(bounds)
    }
    
    func createGIFImageView() -> NSImageView {
        let gifView = NSImageView.init(frame: self.bounds)
        gifView.imageScaling = NSImageScaling.scaleProportionallyDown
        gifView.animates = true
        gifView.canDrawSubviewsIntoLayer = true
        gifView.layerContentsRedrawPolicy = NSViewLayerContentsRedrawPolicy.duringViewResize
        gifView.translatesAutoresizingMaskIntoConstraints = false
        gifView.isEditable = false
        
        return gifView
    }
    
    func applyGIFViewConstraints(atSize size: NSSize) {
        self.addConstraint(NSLayoutConstraint.init(item: gifView!,
                                                   attribute: .centerX,
                                                   relatedBy: .equal,
                                                   toItem: self,
                                                   attribute: .centerX,
                                                   multiplier: 1.0,
                                                   constant: 0.0))
        
        self.addConstraint(NSLayoutConstraint.init(item: gifView!,
                                                   attribute: .centerY,
                                                   relatedBy: .equal,
                                                   toItem: self,
                                                   attribute: .centerY,
                                                   multiplier: 1.0,
                                                   constant: 0.0))
        
        self.addConstraint(NSLayoutConstraint.init(item: gifView!,
                                                   attribute: .width,
                                                   relatedBy: .lessThanOrEqual,
                                                   toItem: self,
                                                   attribute: .width,
                                                   multiplier: 1.0,
                                                   constant: 0.0))
        
        self.addConstraint(NSLayoutConstraint.init(item: gifView!,
                                                   attribute: .height,
                                                   relatedBy: .lessThanOrEqual,
                                                   toItem: self,
                                                   attribute: .height,
                                                   multiplier: 1.0,
                                                   constant: 0.0))
        
        gifWidthConstraint = NSLayoutConstraint.init(item: gifView!,
                                                     attribute: .width,
                                                     relatedBy: .lessThanOrEqual,
                                                     toItem: nil,
                                                     attribute: .width,
                                                     multiplier: 1.0,
                                                     constant: size.width)
        
        gifHeightConstraint = NSLayoutConstraint.init(item: gifView!,
                                                      attribute: .height,
                                                      relatedBy: .lessThanOrEqual,
                                                      toItem: self,
                                                      attribute: .height,
                                                      multiplier: 1.0,
                                                      constant: size.height)
        
        self.addConstraint(gifWidthConstraint!)
        self.addConstraint(gifHeightConstraint!)
    }
    
    //MARK: - View Overrides -
    
    override func awakeFromNib() {
        setUpDragSupport()
        beginObserving()
    }
    
    //MARK: - Drag and Drop -
    
    func setUpDragSupport() {
        self.register(forDraggedTypes: [NSFilenamesPboardType])
    }
    
    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return NSDragOperation.every;
    }
    
    override func draggingExited(_ sender: NSDraggingInfo?) {

        self.setNeedsDisplay(self.bounds)
    }
    
    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pasteboard = sender.draggingPasteboard()
        
        guard pasteboard.types?.contains(NSFilenamesPboardType) == true else {
            return false
        }
        
        guard let imagePath = (pasteboard.propertyList(forType: NSFilenamesPboardType) as? NSArray)?.firstObject as? String else {
            return false
        }
        
        guard let utiType = try? NSWorkspace.shared().type(ofFile: imagePath) else {
            return false
        }
        
        if utiType == (kUTTypeGIF as String) {
            delegate?.gifPreview(preview: self, receivedGIF: imagePath)
        } else {
            DispatchQueue.main.async {
                let alert = NSAlert.init()
                alert.messageText = "Animatd GIFs only, please"
                alert.informativeText = "This file type (\(utiType)) is not allowed. GIFPop works only with animated .gif files."
                alert.runModal()
            }
        }
        
        return true
    }
    
    override func prepareForDragOperation(_ sender: NSDraggingInfo) -> Bool {
        return true;
    }
    
    //MARK: - Drawing -

    override func draw(_ dirtyRect: NSRect) {
        if gifView == nil {
            let myWidth = NSWidth(bounds)
            let myHeight = NSHeight(bounds)
            let imageSize: CGFloat = min(160.0, min(myWidth, myHeight))
            let imageRect = NSMakeRect(floor((myWidth - imageSize) / 2.0),
                                       floor((myHeight - imageSize) / 2.0),
                                       imageSize, imageSize)
            
            dropHereImage.draw(in: imageRect, from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 0.7)
        }
        
        NSColor.init(white: 0.0, alpha: 0.08).setFill()
        NSFrameRectWithWidth(bounds, 1.0)
    }
    
    //MARK: - Notifications -
    
    func beginObserving() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(GIFPreview.windowBeganResizing),
                                               name: NSNotification.Name.NSWindowWillStartLiveResize,
                                               object: self.window)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(GIFPreview.windowFinishedResizing),
                                               name: NSNotification.Name.NSWindowDidEndLiveResize,
                                               object: self.window)
    }
    
    func windowBeganResizing() { animates = false }
    
    func windowFinishedResizing() { animates = true }

}
