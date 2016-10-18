//
//  Resizer.swift
//  GIFPop
//
//  Created by Matt Reagan on 10/9/16.
//  Copyright © 2016 Matt Reagan. All rights reserved.
//

import Foundation
import Cocoa

/****************************************************************************/
/*  Resizer Class */
/****************************************************************************/

class Resizer : NSObject, GIFPreviewDelegate
{
    enum FrameTrimmingOption: Int
    {
        case dontChange = 0, trimBeginning, trimEnd
    }
    
    //MARK: - UI Outlets -
    
    @IBOutlet weak var newWidthTextField: NSTextField!
    @IBOutlet weak var newHeightTextField: NSTextField!
    @IBOutlet weak var frameTrimTextField: NSTextField!
    @IBOutlet weak var gifInfoLabel: NSTextField!
    @IBOutlet weak var framesPopUp: NSPopUpButton!
    @IBOutlet weak var optimizationPopUp: NSPopUpButton!
    @IBOutlet weak var newColorsPopUp: NSPopUpButton!
    
    @IBOutlet weak var optionsBox: NSBox!
    @IBOutlet weak var newSizeSlider: NSSlider!
    @IBOutlet weak var saveGIFButton: NSButton!
    @IBOutlet weak var preview: GIFPreview!
    
    @IBOutlet weak var aboutWindow: NSWindow!
    @IBOutlet weak var aboutIcon: NSImageView!
    @IBOutlet var aboutTextView: NSTextView!
    @IBOutlet weak var aboutOKButton: NSButton!
    @IBOutlet weak var resizerWindow: NSWindow!
    
    //MARK: - Properties -
    
    var inputGIFImage: NSImage?
    let gifsicle: Gifsicle = Gifsicle()
    var inputGIFInfo: GifInfo = (0, 0, 0.0)
    var originalGIFPath: String?
    
    var inputGIFPath: String?
    {
        didSet
        {
            inputGIFImage = NSImage.init(contentsOf: URL.init(fileURLWithPath: inputGIFPath!))
            refreshUI(shouldReset: true)
        }
    }
    
    var originalGIFSize: NSSize
    {
        return (inputGIFImage == nil) ? .zero : inputGIFImage!.size
    }
    
    var proposedSize: NSSize
    {
        let newWidth: CGFloat = max(CGFloat(newWidthTextField.doubleValue), 1.0)
        let newHeight: CGFloat = max(CGFloat(newHeightTextField.doubleValue), 1.0)
        
        return NSSize(width: newWidth > 0 ? newWidth : originalGIFSize.width,
                      height: newHeight > 0 ? newHeight : originalGIFSize.height)
    }
}

/****************************************************************************/
/*  XIB, UI, and other utilities */
/****************************************************************************/

extension Resizer
{
    //MARK: - Setup -
    
    override func awakeFromNib()
    {
        preview.delegate = self
        refreshUI()
    }
    
    //MARK: - Preview Delegate -
    
    func gifPreview(preview: GIFPreview, receivedGIF pathToGIF: String)
    {
        loadGIFAtPath(pathToGIF: pathToGIF)
    }
    
    //MARK: - UI Helper Functions -
    
    func loadGIFAtPath(pathToGIF: String)
    {
        let defaultTempGIFName = "GIFPopResizeOriginal.gif"
        let tempGIFPath = (NSTemporaryDirectory() as NSString).appendingPathComponent(defaultTempGIFName)
        
        try? FileManager.default.removeItem(atPath: tempGIFPath)
        try? FileManager.default.copyItem(atPath: pathToGIF, toPath: tempGIFPath)
        
        inputGIFInfo = gifsicle.getGifsicleInfo(inputImage: tempGIFPath)
        originalGIFPath = pathToGIF
        inputGIFPath = tempGIFPath
    }
    
    func refreshUIWithPreviewAnimationDisabled()
    {
        /*  Disables the animation of the GIF NSImageView during preview resizing */
        
        preview.animates = false
        refreshUI()
        preview.animates = true
    }
    
    func refreshUI()
    {
        refreshUI(shouldReset: false)
    }
    
    func refreshUI(shouldReset: Bool)
    {
        let hasGIF = ((inputGIFPath != nil) && (inputGIFImage != nil))
        
        if (hasGIF)
        {
            gifInfoLabel.stringValue = (originalGIFPath! as NSString).lastPathComponent + "\n" +
                "Dimensions: \(Int(self.originalGIFSize.width)) x \(Int(self.originalGIFSize.height))" +
                "\tFile size: \(calculateFileSizeOfInputGIFInKB()) kb\n" +
                "Frames: \(inputGIFInfo.numberOfFrames) @ \(Int(inputGIFInfo.frameDelay * 1000.0))ms delay\n" +
                "Colors: \(inputGIFInfo.numberOfColors)"
            gifInfoLabel.alignment = .left
            
            if (shouldReset)
            {
                newWidthTextField.integerValue = Int(self.originalGIFSize.width)
                newHeightTextField.integerValue = Int(self.originalGIFSize.height)
                newSizeSlider.doubleValue = newSizeSlider.maxValue
                frameTrimTextField.stringValue = ""
                framesPopUp.selectItem(withTag: 0)
                optimizationPopUp.selectItem(withTag: 0)
                newColorsPopUp.selectItem(withTag: 0)
            }
            
            preview.displayAimatedGIF(gif: inputGIFImage, atSize: self.proposedSize)
        }
        else
        {
            gifInfoLabel.stringValue = "No GIF loaded"
            gifInfoLabel.alignment = .center
            preview.displayAimatedGIF(gif: nil, atSize: NSSize.zero)
        }
        
        setOptionsEnabled(hasGIF)
        validateFrameTrimField()
    }
    
    func setOptionsEnabled(_ enabled: Bool)
    {
        /*  A bit heavy handed but we just filter on any NSControls in the NSBox: */
        
        let controls = self.optionsBox.contentView?.subviews.flatMap { $0 as? NSControl }
        
        for control in controls! { control.isEnabled = enabled }
        
        saveGIFButton.isEnabled = enabled
    }
    
    func validateFrameTrimField()
    {
        let selectedTrimOption = framesPopUp.selectedTag()
        
        if ((selectedTrimOption == FrameTrimmingOption.trimBeginning.rawValue) ||
            (selectedTrimOption == FrameTrimmingOption.trimEnd.rawValue))
        {
            frameTrimTextField.isEnabled = true
        }
        else
        {
            frameTrimTextField.isEnabled = false
            frameTrimTextField.stringValue = ""
        }
    }
    
    //MARK: - Misc Helper Functions -
    
    func calculateFileSizeOfInputGIFInKB() -> UInt64
    {
        var fileSizeOfGIFInKB: UInt64 = 0
        let fileAttributes = try? FileManager.default.attributesOfItem(atPath: inputGIFPath!)
        
        if (fileAttributes != nil)
        {
            fileSizeOfGIFInKB = (fileAttributes! as NSDictionary).fileSize()
            fileSizeOfGIFInKB /= 1024
        }
        
        return fileSizeOfGIFInKB
    }
}

/****************************************************************************/
/*  Gifsicle */
/****************************************************************************/

extension Resizer
{
    //MARK: - Gifsicle -
    
    func runGifsicle(outputPath: String)
    {
        if let gifPath = inputGIFPath
        {
            let newSize = NSSize(width: newWidthTextField.integerValue,
                                 height: newHeightTextField.integerValue)
            let optimization = optimizationPopUp.selectedTag()
            let colorLimit = newColorsPopUp.selectedTag()
            let totalFrames = self.inputGIFInfo.numberOfFrames
            let frameTrimCount = max(0, min(frameTrimTextField.integerValue, totalFrames - 1))
            var trimmedFrames: String? = nil
            
            if (frameTrimCount > 0)
            {
                switch framesPopUp.selectedTag()
                {
                    case FrameTrimmingOption.trimBeginning.rawValue:
                        trimmedFrames = "\(frameTrimCount)-\(totalFrames - 1)"
                    case FrameTrimmingOption.trimEnd.rawValue:
                        trimmedFrames = "0-\(totalFrames - 1 - frameTrimCount)"
                    default:
                        trimmedFrames = "0-\(totalFrames - 1)"
                }
            }
            
            self.gifsicle.runGifsicle(inputImage: gifPath,
                                      resizeTo: newSize,
                                      optimize: optimization,
                                      limitColors: colorLimit,
                                      trimmedFrames: trimmedFrames,
                                      outputPath: outputPath)
        }
    }
}

/****************************************************************************/
/*  IBActions, UI glue */
/****************************************************************************/

extension Resizer
{
    //MARK: - Actions -
    
    @IBAction func saveResizedClicked(_ sender: AnyObject)
    {
        if (inputGIFImage != nil && inputGIFPath != nil)
        {
            let gifExtension = "gif"
            
            let savePanel = NSSavePanel()
            savePanel.isExtensionHidden = false
            savePanel.canSelectHiddenExtension = true
            savePanel.allowedFileTypes = [gifExtension]
            savePanel.allowsOtherFileTypes = false
            
            let originalName = (originalGIFPath! as NSString).lastPathComponent
            let newName = (originalName as NSString).deletingPathExtension
            
            savePanel.nameFieldStringValue = newName + " Resized.gif"
            savePanel.nameFieldLabel = "Save resized GIF as:"
            
            savePanel.begin { (result: Int) in
                if (result == NSFileHandlingPanelOKButton)
                {
                    if let url = savePanel.url
                    {
                        self.runGifsicle(outputPath: url.path)
                    }
                }
            }
        }
    }
    
    @IBAction func newWidthFieldChanged(_ sender: NSTextField)
    {
        let newWidth = min(Double(originalGIFSize.width), max(sender.doubleValue, 1.0))
        let ratio = newWidth / Double(originalGIFSize.width)
        let newHeight = Double(originalGIFSize.height) * ratio
        updateNewDimensionValues(width: newWidth, height: newHeight)
        updateSizeSlider(ratio)
    }
    
    @IBAction func newHeightFieldChanged(_ sender: NSTextField)
    {
        let newHeight = min(Double(originalGIFSize.height), max(sender.doubleValue, 1.0))
        let ratio = newHeight / Double(originalGIFSize.height)
        let newWidth = Double(originalGIFSize.width) * ratio
        updateNewDimensionValues(width: newWidth, height: newHeight)
        updateSizeSlider(ratio)
    }
    
    @IBAction func framePopUpChanged(_ sender: NSPopUpButton)
    {
        validateFrameTrimField()
    }
    
    @IBAction func sizeSliderChanged(_ sender: AnyObject)
    {
        var width = Double(self.originalGIFSize.width)
        var height = Double(self.originalGIFSize.height)
        
        let ratio = self.newSizeSlider.doubleValue / 100.0
        
        width *= ratio
        height *= ratio
        
        width = max(width, 1.0)
        height = max(height, 1.0)
        
        updateNewDimensionValues(width: width, height: height)
    }
    
    //MARK: - Menu Actions -
    
    @IBAction func closeMenuItemSelected(_ sender: AnyObject)
    {
        NSApp.terminate(nil)
    }
    
    @IBAction func saveMenuItemSelected(_ sender: AnyObject)
    {
        saveResizedClicked(sender)
    }
    
    @IBAction func openMenuItemSelected(_ sender: AnyObject)
    {
        let openPanel = NSOpenPanel()
        openPanel.allowedFileTypes = ["gif"]
        openPanel.allowsOtherFileTypes = false
        openPanel.allowsMultipleSelection = false
        openPanel.nameFieldLabel = "Select a .gif:"
        
        openPanel.begin { (result: Int) in
            if (result == NSFileHandlingPanelOKButton)
            {
                if let path = openPanel.url?.path
                {
                    self.loadGIFAtPath(pathToGIF: path)
                }
            }
        }
    }
    
    //MARK: - Utility
    
    func updateSizeSlider(_ ratio: Double)
    {
        newSizeSlider.doubleValue = ratio * newSizeSlider.maxValue
    }
    
    func updateNewDimensionValues(width: Double, height: Double)
    {
        newWidthTextField.integerValue = Int(width.rounded())
        newHeightTextField.integerValue = Int(height.rounded())
        refreshUIWithPreviewAnimationDisabled()
    }
}

/****************************************************************************/
/*  About window */
/****************************************************************************/

extension Resizer
{
    //MARK: - About / Help -
    
    @IBAction func helpButtonClicked(_ sender: AnyObject)
    {
        aboutTextView.readRTFD(fromFile: Bundle.main.path(forResource: "HelpText", ofType: "rtf")!)
        aboutIcon.image = NSImage.init(imageLiteralResourceName: "AppIcon")
        resizerWindow.beginSheet(aboutWindow) { (response: NSModalResponse) in }
        aboutWindow.makeFirstResponder(aboutOKButton)
    }
    
    @IBAction func aboutOKClicked(_ sender: AnyObject)
    {
        resizerWindow?.endSheet(aboutWindow)
    }
}
