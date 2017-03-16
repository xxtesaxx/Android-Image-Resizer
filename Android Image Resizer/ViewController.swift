//
//  ViewController.swift
//  Android Image Resizer
//
//  Created by Jan Thielemann on 16.03.17.
//  Copyright © 2017 Jan Thielemann. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var sourceSizeDropDown: NSPopUpButton!
    
    @IBOutlet weak var ldpiCheckbox: NSButton!
    @IBOutlet weak var mdpiCheckbox: NSButton!
    @IBOutlet weak var hdpiCheckbox: NSButton!
    @IBOutlet weak var xhdpiCheckbox: NSButton!
    @IBOutlet weak var xxhdpiCheckbox: NSButton!
    @IBOutlet weak var xxxhdpiCheckbox: NSButton!
    
    @IBOutlet weak var appStoreIconImageGrey: NSImageView!
    @IBOutlet weak var appStoreIconImageBlue: NSImageView!
    
    @IBOutlet weak var thumbnailImage: NSImageView!
    
    @IBOutlet weak var saveButton: NSButton!
    
    @IBOutlet weak var destinationView: DestinationView!
    
    var checkboxes = [NSButton]()
    var imageUrl: URL?
    
    enum DrawablePaths : String{
        case ldpi = "drawable-ldpi"
        case mdpi = "drawable-mdpi"
        case hdpi = "drawable-hdpi"
        case xhdpi = "drawable-xhdpi"
        case xxhdpi = "drawable-xxhdpi"
        case xxxhdpi = "drawable-xxxhdpi"
    }
    
    enum DrawableScaleFactor : Double {
        case ldpi = 0.75
        case mdpi = 1.0
        case hdpi = 1.5
        case xhdpi = 2.0
        case xxhdpi = 3.0
        case xxxhdpi = 4.0
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Disable save button on start
        saveButton.isEnabled = false
        
        //Set self as delegate for drag & drop view
        destinationView.delegate = self
        
        //Set initially dragging to false
        isReceivingDrag(false)
        
        thumbnailImage.imageScaling = .scaleProportionallyUpOrDown
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        //Make sure url is set
        guard let imageUrl = imageUrl else { return }
        
        //Create folder with image name
        if !FileManager.default.fileExists(atPath: imageUrl.deletingPathExtension().relativePath) {
            try! FileManager.default.createDirectory(at: imageUrl.deletingPathExtension(), withIntermediateDirectories: false)
        }
        
        //For each checked checkbox, create the folder and save a scaled image
        if ldpiCheckbox.state == NSOnState {
            save(imageUrl: imageUrl, sizeFolder: .ldpi, scaleFactor: .ldpi)
        }

        if mdpiCheckbox.state == NSOnState {
            save(imageUrl: imageUrl, sizeFolder: .mdpi, scaleFactor: .mdpi)
        }
        
        if hdpiCheckbox.state == NSOnState {
            save(imageUrl: imageUrl, sizeFolder: .hdpi, scaleFactor: .hdpi)
        }
        
        if xhdpiCheckbox.state == NSOnState {
            save(imageUrl: imageUrl, sizeFolder: .xhdpi, scaleFactor: .xhdpi)
        }
        
        if xxhdpiCheckbox.state == NSOnState {
            save(imageUrl: imageUrl, sizeFolder: .xxhdpi, scaleFactor: .xxhdpi)
        }
        
        if xxxhdpiCheckbox.state == NSOnState {
            save(imageUrl: imageUrl, sizeFolder: .xxxhdpi, scaleFactor: .xxxhdpi)
        }
        
    }
    
    func save(imageUrl: URL, sizeFolder: DrawablePaths, scaleFactor: DrawableScaleFactor) {
        let imageFolder = imageUrl.deletingPathExtension()
        let sizeFolder = imageFolder.appendingPathComponent(sizeFolder.rawValue, isDirectory: true)
        
        if !FileManager.default.fileExists(atPath: sizeFolder.relativePath) {
            try! FileManager.default.createDirectory(at: sizeFolder, withIntermediateDirectories: false)
        }
        
        //Calculate the scale factor
        let targetScale = scaleFactor.rawValue
        let baseScale = scaleFactorForSelectedSourceSize().rawValue
        let actualScale = targetScale / baseScale
        
        print("The scale for \(scaleFactor) with source \(scaleFactorForSelectedSourceSize()) is \(actualScale)")
        
        
        //Get the image
        guard let image = NSImage(contentsOf: imageUrl) else { return }
        
        //Sacle the image to size
        let resizedImage = image.resizeWhileMaintainingAspectRatio(scale: CGFloat(actualScale))
        
        
        //Create the url to save the image to
        let imageName = imageUrl.lastPathComponent
        let newImageUrl = sizeFolder.appendingPathComponent(imageName, isDirectory: false)
        
        //Check if the image exists already and delete if so
        if FileManager.default.fileExists(atPath: newImageUrl.relativePath) {
            try! FileManager.default.removeItem(at: newImageUrl)
        }
        
        //Save image
        if imageUrl.pathExtension.lowercased() == "png" {
            try! resizedImage?.savePNGRepresentationToURL(url: newImageUrl)
        }else {
            try! resizedImage?.saveJPGRepresentationToURL(url: newImageUrl)
        }
        
        
        
    }
    
    func scaleFactorForSelectedSourceSize() -> DrawableScaleFactor {
        switch sourceSizeDropDown.indexOfSelectedItem {
        case 0:
            return .ldpi
        case 1:
            return .mdpi
        case 2:
            return .hdpi
        case 3:
            return .xhdpi
        case 4:
            return .xxhdpi
        case 5:
            return .xxxhdpi
        default:
            return .xxxhdpi
        }
    }
    
}

extension ViewController: DestinationViewDelegate {
    func processImageURL(_ url: URL) {
        print("We shall process a image url: \(url)")
        
        appStoreIconImageBlue.isHidden = true
        appStoreIconImageGrey.isHidden = true
        
        thumbnailImage.image = NSImage(byReferencing: url)
        imageUrl = url
        
        saveButton.isEnabled = true
    }
    
    func isReceivingDrag(_ isReceiving: Bool) {
        print("Are we receiving a drag? \(isReceiving)")
        
        if isReceiving {
            appStoreIconImageBlue.isHidden = false
            appStoreIconImageGrey.isHidden = true
        }else {
            appStoreIconImageBlue.isHidden = true
            appStoreIconImageGrey.isHidden = false
        }
        //If ture tint image blue if false tint it grey
    }
}



extension NSImage {
    
    /// Returns the height of the current image.
    var height: CGFloat {
        return self.size.height
    }
    
    /// Returns the width of the current image.
    var width: CGFloat {
        return self.size.width
    }
    
    /// Returns a png representation of the current image.
    var pngRepresentation: Data? {
        if let tiff = self.tiffRepresentation, let tiffData = NSBitmapImageRep(data: tiff) {
            return tiffData.representation(using: .PNG, properties: [:])
        }
        
        return nil
    }
    
    var jpgRepresentation: Data? {
        if let tiff = self.tiffRepresentation, let tiffData = NSBitmapImageRep(data: tiff) {
            return tiffData.representation(using: .JPEG, properties: [:])
        }
        
        return nil
    }
    
    func copyWithSize(size: NSSize) -> NSImage? {
        // Create a new rect with given width and height
        let frame = NSMakeRect(0, 0, size.width, size.height)
        
        // Get the best representation for the given size.
        guard let rep = self.bestRepresentation(for: frame, context: nil, hints: nil) else {
            return nil
        }
        
        // Create an empty image with the given size.
        let img = NSImage(size: size)
        
        // Set the drawing context and make sure to remove the focus before returning.
        img.lockFocus()
        defer { img.unlockFocus() }
        
        // Draw the new image
        if rep.draw(in: frame) {
            return img
        }
        
        // Return nil in case something went wrong.
        return nil
    }
    
    func resizeWhileMaintainingAspectRatio(scale: CGFloat) -> NSImage? {
        var actualScale: CGFloat
        
        if let displayScale = NSScreen.main()?.backingScaleFactor {
            actualScale = scale / displayScale
        }else {
            actualScale = scale
        }
        
        
        let width = floor(self.width * actualScale)
        let height = floor(self.height * actualScale)
        print("old width \(self.width) old height \(self.height)")
        print("new width \(width) new height \(height)")
        
        
        
        let newSize = NSSize(width: width, height: height)
        return self.copyWithSize(size: newSize)
    }
    
  
    func savePNGRepresentationToURL(url: URL) throws {
        if let png = self.pngRepresentation {
            try png.write(to: url, options: .atomicWrite)
        }
    }
    
    func saveJPGRepresentationToURL(url: URL) throws {
        if let jpg = self.jpgRepresentation {
            try jpg.write(to: url, options: .atomicWrite)
        }
    }
}
