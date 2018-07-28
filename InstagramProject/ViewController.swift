//
//  AppDelegate.swift
//  InstagramProject
//
//  Created by Dipen Desai on 7/28/18.
//  Copyright © 2018 Ankita. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var jsonResult: [AnyObject] = []
    var task: URLSessionDownloadTask!
    var session: URLSession!
    var cache = NSCache<AnyObject, AnyObject>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.session = URLSession.shared
        task = URLSessionDownloadTask()
        self.cache = NSCache()
        
        tableView.tableFooterView = UIView()
        
        let url = URL(string: "https://picsum.photos/list")
        let session = URLSession.shared
        if let usableUrl = url {
            let task = session.dataTask(with: usableUrl, completionHandler: { (data, response, error) in
                if let data = data {
                    do{
                        self.jsonResult = (try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [AnyObject])!
                        print(self.jsonResult)
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }catch{
                        
                    }
                    
                }
            })
            task.resume()
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jsonResult.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell
        cell.imageViewProfile.image = UIImage(named: "placeholder")
        let data = jsonResult[indexPath.row] as! [String:AnyObject]
        
        let url = "https://picsum.photos/\(data["width"] as! Int)/\(data["height"] as! Int)?image=\(data["id"] as! Int)"
        if (self.cache.object(forKey: indexPath.row as AnyObject) != nil){
            cell.imageViewProfile.image = self.cache.object(forKey: (indexPath.row as AnyObject)) as? UIImage
        }else{
            
            let url = URL(string: url)
            task = session.downloadTask(with: url!, completionHandler: { (location, response, error) -> Void in
                if let data = try? Data(contentsOf: url!){
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                        if let updateCell = tableView.cellForRow(at: indexPath) as? TableViewCell{
                            let img:UIImage! = UIImage(data: data)
                            updateCell.imageViewProfile.image = img
                            self.cache.setObject(img, forKey: (indexPath.row as AnyObject))
                        }
                    })
                }
            })
            task.resume()
        }
        cell.lblAuthor.text = data["author"] as? String
        cell.lblAuthorUrl.text = data["author_url"] as? String
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}

class TableViewCell: UITableViewCell{
    @IBOutlet weak var imageViewProfile: UIImageView!
    @IBOutlet weak var lblAuthorUrl: UILabel!
    @IBOutlet weak var lblAuthor: UILabel!
    var imageUrl: NSURL!
}
