//
//  AddItemViewController.swift
//  Shopping Mall
//
//  Created by Jarukorn Thuengjitvilas on 1/3/2565 BE.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class AddItemViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var costTextField: UITextField!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var submitButton: UIButton!
    
    var imagePickerController : UIImagePickerController!
    var selectedImage: UIImage? = nil
    
    let pleaseWaitAlert = UIAlertController(title: "Please Wait...", message: nil, preferredStyle: .alert)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagePickerController = UIImagePickerController()
        self.imagePickerController.delegate = self
        self.imagePickerController.allowsEditing = false
        
        self.titleTextField.layer.borderColor = UIColor.lightGray.cgColor
        self.titleTextField.layer.borderWidth = 0.5
        self.titleTextField.layer.cornerRadius = 8
        
        self.descriptionTextView.backgroundColor = .white
        self.descriptionTextView.layer.borderColor = UIColor.lightGray.cgColor
        self.descriptionTextView.layer.borderWidth = 0.5
        self.descriptionTextView.layer.cornerRadius = 12
        
        self.costTextField.layer.borderColor = UIColor.lightGray.cgColor
        self.costTextField.layer.borderWidth = 0.5
        self.costTextField.layer.cornerRadius = 8
        
        self.itemImageView.layer.borderColor = UIColor.lightGray.cgColor
        self.itemImageView.layer.borderWidth = 0.5
        self.itemImageView.layer.cornerRadius = 12
        self.itemImageView.isUserInteractionEnabled = true
        self.itemImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectImage)))
        
        self.submitButton.layer.cornerRadius = 12
    }

    @objc func selectImage() {
        let alert = UIAlertController(title: nil, message: "Select Photo", preferredStyle: .actionSheet)

            let cameraPhoto = UIAlertAction(title: "Camera", style: .default, handler: {
                (alert: UIAlertAction) -> Void in
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {

                    self.imagePickerController.mediaTypes = ["public.image"]
                    self.imagePickerController.sourceType = UIImagePickerController.SourceType.camera;
                    self.present(self.imagePickerController, animated: true, completion: nil)
                }
                else{
                    UIAlertController(title: "iOSDevCenter", message: "No Camera available.", preferredStyle: .alert).show(self, sender: nil);
                }

            })

            let PhotoLibrary = UIAlertAction(title: "Photo Library", style: .default, handler: {
                (alert: UIAlertAction) -> Void in
                if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
                    self.imagePickerController.mediaTypes = ["public.image"]
                    self.imagePickerController.sourceType = UIImagePickerController.SourceType.photoLibrary;
                    self.present(self.imagePickerController, animated: true, completion: nil)
                }

            })

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                (alert: UIAlertAction) -> Void in

            })

            alert.addAction(cameraPhoto)
            alert.addAction(PhotoLibrary)
            alert.addAction(cancelAction)


            if UIDevice.current.userInterfaceIdiom == .pad {
                let presentC : UIPopoverPresentationController  = alert.popoverPresentationController!
                presentC.sourceView = self.view
                presentC.sourceRect = self.view.bounds
                self.present(alert, animated: true, completion: nil)
            }
            else{
                self.present(alert, animated: true, completion: nil)
            }
    }
    
    @IBAction func submitButtonClicked(_ sender: Any) {
        present(pleaseWaitAlert, animated: true)
        if let title: String = titleTextField.text, !title.isEmpty,
           let description: String = descriptionTextView.text, !description.isEmpty,
           let _: Double = Double(costTextField.text ?? "") {
            if selectedImage != nil {
                // Save Image to Firebase Cloud Storage
                uploadImage()
            } else {
                // Save Data to Firestore
                uploadItem()
            }
        } else {
            pleaseWaitAlert.dismiss(animated: true) {
                let alert = UIAlertController(title: "Invalid Input", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
    
    private func uploadImage() {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let uuid = UUID().uuidString
        let imageRef = storageRef.child("\(uuid).jpg")
        
        // Data in memory
        guard let data = selectedImage?.jpegData(compressionQuality: 0.5) else { return }
        
        // Upload the file to the path
        imageRef.putData(data, metadata: nil) { (metadata, error) in
            guard let _ = metadata else {
                // Uh-oh, an error occurred!
                self.pleaseWaitAlert.dismiss(animated: true) {
                    let alert = UIAlertController(title: "Error Occurred", message: error?.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
                return
            }
            
            // You can also access to download URL after upload.
            imageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    self.pleaseWaitAlert.dismiss(animated: true) {
                        let alert = UIAlertController(title: "Error Occurred", message: error?.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
                    return
                }
                
                print(downloadURL.absoluteString)
                self.uploadItem(imageUrl: downloadURL.absoluteString)
            }
        }
    }
    
    private func uploadItem(imageUrl: String = "") {
        let db = Firestore.firestore()
        var ref: DocumentReference? = nil
        
        if let title: String = titleTextField.text, !title.isEmpty,
           let description: String = descriptionTextView.text, !description.isEmpty,
           let cost: Double = Double(costTextField.text ?? "") {
            ref = db.collection("items").addDocument(data: [
                "title": title,
                "description": description,
                "cost": cost,
                "imageUrl": imageUrl
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                } else {
                    print("Document added with ID: \(ref!.documentID)")
                    self.navigationController?.popViewController(animated: true)
                }
            }
            pleaseWaitAlert.dismiss(animated: true, completion: nil)
        } else {
            pleaseWaitAlert.dismiss(animated: true) {
                let alert = UIAlertController(title: "Invalid Input", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
    
}

extension AddItemViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        itemImageView.image = image
        self.selectedImage = image
        self.imagePickerController.dismiss(animated: true, completion: { () -> Void in
            // Dismiss
        })

    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.imagePickerController.dismiss(animated: true, completion: { () -> Void in
            // Dismiss
        })
    }
    
}
