//
//  ViewController.swift
//  AzureBlobStorateTest
//
//  Created by Jason on 2021/11/28.
//

import UIKit
import AZSClient

class ViewController: UIViewController {
    let connectionString:String = "Your Storage Account Connection String"

    var blobContainer:AZSCloudBlobContainer?
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    
    var blobstorage:AZBlobService?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage(named: "GlobalAzure2022")
        imageView1.image = image
        blobstorage = AZBlobService(connectionString, containerName: "con-ios")
    }

    @IBAction func upload(_ sender: Any) {
        guard let image = imageView1.image else {return}
        blobstorage?.uploadImage(image: image, blobName: "globalazure")
    }
    
    @IBAction func download(_ sender: Any) {
        blobstorage?.downloadImage(blobName: "globalazure", handler: { data in
            let image = UIImage(data: data)
            DispatchQueue.main.async {
                self.imageView2.image = image
            }
        })
    }
    
    @IBAction func remove(_ sender: Any) {
        blobstorage?.deleteImage(blobName: "globalazure", handler: {
            print("delete complete")
        })
    }
 
}

class AZBlobService{
    let blobContainer:AZSCloudBlobContainer
    
    init(_ connectionString:String, containerName:String) {
        guard let account = try? AZSCloudStorageAccount(fromConnectionString: connectionString) else {
            blobContainer = AZSCloudBlobContainer()
            return
        }
        let blobClient = account.getBlobClient()
        self.blobContainer = blobClient.containerReference(fromName: containerName)
    }
    
    func uploadImage(image:UIImage, blobName:String){
        self.blobContainer.createContainerIfNotExists { error, isExist in
            if let error = error{
                print(error.localizedDescription)
            } else {
                let blockBlob = self.blobContainer.blockBlobReference(fromName: blobName)
                if let data = image.pngData(){
                    blockBlob.upload(from: data) { error in
                        if let error = error{
                            print(error.localizedDescription.description)
                        } else {
                            print("Upload Complete")
                        }
                    }
                }
            }
        }
    }
    
    func downloadImage(blobName:String, handler:@escaping (Data)->()){
        let blockBlob = blobContainer.blockBlobReference(fromName: blobName)
        blockBlob.downloadToData { error, data in
            if let data = data{
               handler(data)
            }
        }
    }
    
    func deleteImage(blobName:String, handler:@escaping ()->()){
        let blockBlob = blobContainer.blockBlobReference(fromName: blobName)
        blockBlob.delete { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                handler()
            }
        }
    }
    
}
