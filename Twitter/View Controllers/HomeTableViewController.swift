//
//  HomeTableViewController.swift
//  Twitter
//
//  Created by Jasmyne Roberts on 10/7/20.
//  Copyright © 2020 dandruf. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController  {

    var tweetArray = [NSDictionary]() // Alternative: [NSDictionary]()
    var numOfTweets : Int!
    
    @IBAction func onLogoutButton(_ sender: UIBarButtonItem) {
        TwitterAPICaller.client?.logout()
        self.dismiss(animated: true, completion: nil)
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
    }
    
    let customRefreshControl = UIRefreshControl()
    
    @objc func loadTweets() {
        numOfTweets = 20
        
        let tweetUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let params = ["count": numOfTweets]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: tweetUrl, parameters: params as [String : Any], success: { (tweets: [NSDictionary]) in
            
            self.tweetArray.removeAll()
            
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            
            self.tableView.reloadData()
            self.customRefreshControl.endRefreshing()
            
        }, failure: { (Error) in
            print("Could not load tweets")
        })
        
    }
    
    func loadMoreTweets() {
        numOfTweets = numOfTweets + 20
        
        let tweetUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let params = ["count": numOfTweets]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: tweetUrl, parameters: params as [String : Any], success: { (tweets: [NSDictionary]) in
            
            self.tweetArray.removeAll()
            
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            
            self.tableView.reloadData()
            self.customRefreshControl.endRefreshing()
            
        }, failure: { (Error) in
            print("Could not load more tweets")
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTweets()
        
        customRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.refreshControl = customRefreshControl
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        loadTweets()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == tweetArray.count {
            loadMoreTweets()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        
        let user = tweetArray[indexPath.row]["user"] as! NSDictionary
        
        cell.usernameLabel.text = user["name"] as? String
        cell.tweetLabel.text = tweetArray[indexPath.row]["text"] as? String
        
        let imageUrl = URL(string: (user["profile_image_url_https"] as? String)!)
        let data = try? Data(contentsOf: imageUrl!)
        
        if let imageData = data {
            cell.profileImageView.image = UIImage(data: imageData)
        }
        
        cell.setFavorite(tweetArray[indexPath.row]["favorited"] as! Bool)
        cell.tweetId = tweetArray[indexPath.row]["id"] as! Int
        cell.setRetweeted(tweetArray[indexPath.row]["retweeted"] as! Bool)

        
        return cell
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetArray.count
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
