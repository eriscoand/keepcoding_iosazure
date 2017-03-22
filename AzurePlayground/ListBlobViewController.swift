//
//  ListBlobViewController.swift
//  AzurePlayground
//
//  Created by Eric Risco de la Torre on 22/03/2017.
//  Copyright © 2017 ERISCO. All rights reserved.
//

import UIKit

class ListBlobViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var blobClient: AZSCloudBlobClient!
    var container: AZSCloudBlobContainer!
    var model: [AZSCloudBlockBlob] = []
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = container.name
        
        tableView.dataSource = self
        tableView.delegate = self
        
        readAllBlobs()

        // Do any additional setup after loading the view.
    }
    
    func readAllBlobs(){
        container.listBlobsSegmented(with: nil,
                                     prefix: nil,
                                     useFlatBlobListing: true,
                                     blobListingDetails: AZSBlobListingDetails.all,
                                     maxResults: -1) { (error, result) in
                                        
                                        if let error = error {
                                            print("\(error.localizedDescription)")
                                            return
                                        }
                                        
                                        if let result = result,
                                           let blobs = result.blobs{
                                            self.model = blobs as! [AZSCloudBlockBlob]
                                        }
                                        
                                        DispatchQueue.main.async {
                                            self.tableView.reloadData()
                                        }
                                        
        }
    }
    
    @IBAction func uploadClick(_ sender: Any) {
        uploadBlob()
    }
    
    fileprivate func uploadBlob(){
        let blobLocal = container.blockBlobReference(fromName: UUID().uuidString)
        
        if let image = UIImage.init(named: "test.jpg"){
            if let data = UIImageJPEGRepresentation(image, 0.5){
                blobLocal.upload(from: data) { (error) in
                    self.readAllBlobs()
                }
            }
        }
        
    }
    
    fileprivate func downloadBlob(blob: AZSCloudBlockBlob){
        let blobLocal = container.blockBlobReference(fromName: blob.blobName)
        
        blobLocal.downloadToData { (error, data) in
            if let error = error {
                print("\(error.localizedDescription)")
                return
            }
            if let data = data {
                if let image = UIImage(data: data){
                    DispatchQueue.main.async {
                        print("\(image.size)")
                    }
                }
            }
        }
    }
    
    fileprivate func deleteBlob(blob: AZSCloudBlockBlob){
        
        blob.delete { (error) in
            if let _ = error {
                print("\(error.debugDescription)")
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


extension ListBlobViewController {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = model[indexPath.row] as AZSCloudBlockBlob
        downloadBlob(blob: item)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if model.isEmpty {
            return 0
        }
        return model.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELLBLOBID", for: indexPath) as UITableViewCell
        
        let item = model[indexPath.row]
        
        cell.textLabel?.text = item.blobName
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let item = model[indexPath.row]
            model.remove(at: indexPath.row)
            deleteBlob(blob: item)
            self.tableView.reloadData()
        }
        
    }
    
}
