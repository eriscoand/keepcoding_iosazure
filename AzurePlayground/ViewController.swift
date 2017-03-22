//
//  ViewController.swift
//  AzurePlayground
//
//  Created by Eric Risco de la Torre on 21/03/2017.
//  Copyright © 2017 ERISCO. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var account: AZSCloudStorageAccount!
    var blobClient: AZSCloudBlobClient!
    @IBOutlet weak var tableView: UITableView!
    
    var model: [AZSCloudBlobContainer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        setupAzureStorageConnect()
        readAllContainers()
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "showList"){
            let vc = segue.destination as! ListBlobViewController
            vc.blobClient = self.blobClient
            vc.container = sender as! AZSCloudBlobContainer
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupAzureStorageConnect(){
        let credentials = AZSStorageCredentials(accountName: CONSTANTS.ACCOUNT_NAME, accountKey: CONSTANTS.ACCOUNT_KEY)
        
        do {
            account = try AZSCloudStorageAccount(credentials: credentials, useHttps: true)
            blobClient = account.getBlobClient()
        }catch let error{
            print("\(error.localizedDescription)")
        }
        
    }
    
    @IBAction func addNewContainer(_ sender: Any) {
        
        let randomNum:UInt32 = arc4random_uniform(100) // range is 0 to 99
        let someInt:Int = Int(randomNum)
        
        let reference = blobClient.containerReference(fromName: "example"+someInt.description)
        
        reference.createContainerIfNotExists(with: .container, requestOptions: nil, operationContext: nil) { (error, success) in
            if let error = error {
                print("\(error.localizedDescription)")
                return
            }
            
            if success {
                self.readAllContainers()
            }
            
        }
        
        
    }
    
    fileprivate func readAllContainers() {
        
        blobClient.listContainersSegmented(with: nil,
                                           prefix: nil,
                                           containerListingDetails: AZSContainerListingDetails.all,
                                           maxResults: -1) { (error, containerResults) in
                                            
                                            self.model = []
                                            
                                            if let error = error {
                                                print("\(error.localizedDescription)")
                                                return
                                            }
                                            
                                            if let containerResults = containerResults {
                                                self.model = containerResults.results as! [AZSCloudBlobContainer]
                                            }
                                            
                                            DispatchQueue.main.async {
                                                self.tableView.reloadData()
                                            }
                                            
                                            
        }
        
    }

}

extension ViewController {
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "CELLID", for: indexPath) as UITableViewCell
        
        let item = model[indexPath.row]
        
        cell.textLabel?.text = item.name
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = model[indexPath.row] as AZSCloudBlobContainer
        
        performSegue(withIdentifier: "showList", sender: item)
        
    }
    
}

