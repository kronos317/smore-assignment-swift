//
//  PhotoPickerController.swift
//  SMoreTest
//
//  Created by Onseen on 8/5/21.
//

import UIKit
import MobileCoreServices
import AVKit
import Photos

@objc protocol PhotoPickerControllerDelegate {
    
    @objc optional func didPhotoPickerControllerFinish(image: UIImage)
    
}

class PhotoPickerController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    weak var delegate: PhotoPickerControllerDelegate? = nil
    weak var parentVC: UIViewController? = nil
    var isAllowEditing = true
    
    func initialize(viewController: UIViewController) {
        self.view.backgroundColor = UIColor(red: 132.0/255.0, green: 233.0/255.0, blue: 245.0/255.0, alpha: 0.7)
        self.view.alpha = 0.5
        self.parentVC = viewController
    }
    
    func takePhotoFromCamera() {
        let cameraDeviceAvailable = UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)
        
        if cameraDeviceAvailable {
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { (granted) in
                DispatchQueue.main.async {
                    if granted == true {
                        self.shouldStartCameraController()
                    }
                    else {
                        self.showErrorMessage(title: "Confirmation", message: "You haven't granted the access to camera.")
                    }

                }
            }
            
        } else {
            self.showErrorMessage(title: "Error", message: "Camera is not available on your device.")
        }
    }
    
    func takePhotoFromAlbum() {
        let photoLibraryAvailable = UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary)
        
        if photoLibraryAvailable {
            PHPhotoLibrary.requestAuthorization { (status) in
                DispatchQueue.main.async {
                    if status == .authorized {
                        self.shouldStartPhotoLibraryPickerController()
                    }
                    else {
                        self.showErrorMessage(title: "Confirmation", message: "You haven't granted the access to photo library.")
                    }
                }
            }
        } else {
            self.showErrorMessage(title: "Error", message: "Photo library is not available on your device.")
        }
    }
    
    func takePhoto(anchorView: UIView?){
        guard let parentVC = self.parentVC else {
            return
        }
        
        let cameraDeviceAvailable = UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)
        let photoLibraryAvailable = UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary)
        
        if cameraDeviceAvailable && photoLibraryAvailable {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Use Camera", style: .default , handler:{ (UIAlertAction) in
                AVCaptureDevice.requestAccess(for: AVMediaType.video) { (granted) in
                    DispatchQueue.main.async {
                        if granted == true {
                            self.shouldStartCameraController()
                        }
                        else {
                            self.showErrorMessage(title: "Confirmation", message: "You haven't granted the access to camera.")
                        }

                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "Use Photo", style: .default , handler:{ (UIAlertAction) in
                PHPhotoLibrary.requestAuthorization { (status) in
                    DispatchQueue.main.async {
                        if status == .authorized {
                            self.shouldStartPhotoLibraryPickerController()
                        }
                        else {
                            self.showErrorMessage(title: "Confirmation", message: "You haven't granted the access to photo library.")
                        }
                    }
                }
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction) in }))
            
            if let popoverController = alert.popoverPresentationController, let anchorView = anchorView {
                popoverController.sourceView = anchorView
                popoverController.sourceRect = anchorView.bounds
            }
            
            DispatchQueue.main.async {
                parentVC.present(alert, animated: true, completion: nil)
            }
            
        } else {
            PHPhotoLibrary.requestAuthorization { (status) in
                DispatchQueue.main.async {
                    if status == .authorized {
                        self.shouldStartPhotoLibraryPickerController()
                    }
                    else {
                        self.showErrorMessage(title: "Confirmation", message: "You haven't granted the access to photo library.")
                    }
                }
            }
        }
    }
    
    func showErrorMessage(title: String, message: String) {
        guard let parentVC = self.parentVC else {
            return
        }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
        
        DispatchQueue.main.async {
            parentVC.present(alert, animated: true, completion: nil)
        }
    }
    
    func shouldPresentPhotoCaptureController () {
        self.shouldStartPhotoLibraryPickerController()
    }
    
    func shouldStartCameraController () {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) == false {
            return
        }
        let cameraUI = UIImagePickerController()
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) == true && UIImagePickerController.availableMediaTypes(for: UIImagePickerController.SourceType.camera)?.contains(kUTTypeImage as String) == true){
            cameraUI.mediaTypes = NSArray(array: [kUTTypeImage]) as! [String]
            cameraUI.sourceType = UIImagePickerController.SourceType.camera
            
            if UIImagePickerController.isCameraDeviceAvailable(UIImagePickerController.CameraDevice.rear) == true {
                cameraUI.cameraDevice = UIImagePickerController.CameraDevice.rear
            } else if UIImagePickerController.isCameraDeviceAvailable(UIImagePickerController.CameraDevice.front) == true{
                cameraUI.cameraDevice = UIImagePickerController.CameraDevice.front
            }
        }
        
        cameraUI.allowsEditing = self.isAllowEditing
        cameraUI.showsCameraControls = true
        cameraUI.delegate = self
        if let parentVC = self.parentVC {
            parentVC.present(cameraUI, animated: true, completion: nil)
        }
    }
    
    func shouldStartPhotoLibraryPickerController() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) == false && UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.savedPhotosAlbum) == false {
            return
        }
        
        let cameraUI = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) == true && UIImagePickerController.availableMediaTypes(for: UIImagePickerController.SourceType.photoLibrary)?.contains(kUTTypeImage as String) == true {
            cameraUI.sourceType = UIImagePickerController.SourceType.photoLibrary
            cameraUI.mediaTypes = NSArray(array: [kUTTypeImage]) as! [String]
            
        } else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.savedPhotosAlbum) == true && UIImagePickerController.availableMediaTypes(for: UIImagePickerController.SourceType.savedPhotosAlbum)?.contains(kUTTypeImage as String) == true {
            cameraUI.sourceType = UIImagePickerController.SourceType.savedPhotosAlbum
            cameraUI.mediaTypes = NSArray(array: [kUTTypeImage]) as! [String]
        } else {
            return
        }
        cameraUI.allowsEditing = self.isAllowEditing
        cameraUI.delegate = self
        if let parentVC = self.parentVC {
            parentVC.present(cameraUI, animated: true, completion: nil)
        }
    }
    
    // MARK: UIImagePickerController Delegates
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        if let parentVC = self.parentVC {
            parentVC.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let parentVC = self.parentVC {
            parentVC.dismiss(animated: true, completion: nil)
        }
        
        let targetSize = CGSize(width: 900, height: 1200)
        
        if self.isAllowEditing == true {
            let image: UIImage = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
            let resizedImage = resizeImage(image, targetSize: targetSize)
            
            if let delegate = self.delegate {
                delegate.didPhotoPickerControllerFinish?(image: resizedImage)
            }
        }
        else {
            let image: UIImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            let resizedImage = resizeImage(image, targetSize: targetSize)
            if let delegate = self.delegate {
                delegate.didPhotoPickerControllerFinish?(image: resizedImage)
            }
        }
    }
    
    func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        
        var newSize: CGSize
        if (widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        }
        else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }

}
