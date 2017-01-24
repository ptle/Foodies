//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit
import MBProgressHUD

class BusinessesViewController: UIViewController,
    UITableViewDelegate, UITableViewDataSource,
    UISearchControllerDelegate, UISearchResultsUpdating, UISearchBarDelegate,
    UIScrollViewDelegate{
    
    var searchController : UISearchController!
    var businesses: [Business]!
    var filteredData: [Business]!
    var offset: Int = 0
    var loadingMoreView:InfiniteScrollActivityView?
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var networkError: UIView!
    @IBOutlet weak var networkErrorImage: UIImageView!
    
    var isMoreDataLoading = false
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // ... Code to load more results ...
                loadMoreData()
                
            }
        }
    }
    
    func loadMoreData() {
        if businesses != nil {
            offset += businesses.count
        }
        Business.searchWithTerm(term: "Thai", offset: offset, completion: { (businesses: [Business]?, error: Error?) -> Void in
            
            // Update flag
            self.isMoreDataLoading = false
            
            // Stop the loading indicator
            self.loadingMoreView!.stopAnimating()
                                                                        
            // ... Use the new data to update the data source ...
            if(error == nil)
            {
                self.businesses.append(contentsOf: businesses!)
                self.filteredData.append(contentsOf: businesses!)
            }
            // Reload the tableView now that there is new data
            self.tableView.reloadData()
                                                                        
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let image = UIImage(named:"error") {
            networkErrorImage.image = image
        }
        networkError.isHidden = true
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        
        self.navigationController?.navigationBar.barTintColor = UIColor.red
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        self.searchController = UISearchController(searchResultsController:  nil)
        
        self.searchController.searchResultsUpdater = self
        self.searchController.delegate = self
        self.searchController.searchBar.delegate = self
        
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.placeholder = "Restaurants"
        
        self.navigationItem.titleView = searchController.searchBar
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        Business.searchWithTerm(term: "Thai", offset: offset, completion: { (businesses: [Business]?, error: Error?) -> Void in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            self.businesses = businesses
            self.filteredData = businesses
            self.tableView.reloadData()
            
            self.networkError.isHidden = true;
            
            if error != nil {
                self.networkError.isHidden = false;
            }
            /*
            if let businesses = businesses {
                for business in businesses {
                    print(business.name!)
                    print(business.address!)
                }
            }
             */
            
        }
        )
        
        /* Example of Yelp search with more search options specified
         Business.searchWithTerm("Restaurants", sort: .Distance, categories: ["asianfusion", "burgers"], deals: true) { (businesses: [Business]!, error: NSError!) -> Void in
         self.businesses = businesses
         
         for business in businesses {
         print(business.name!)
         print(business.address!)
         }
         }
         */
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if filteredData != nil {
            return filteredData.count
        }
        else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath) as! BusinessCell
        
        cell.business = filteredData[indexPath.row]
        
        return cell
    }
    
    public func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text {
            if searchText.isEmpty {
                filteredData = businesses
                
            }
            else
            {
                filteredData = businesses!.filter({(dataItem: Business) -> Bool in
                    let title = dataItem.name!
                    if title.range(of: searchText, options: .caseInsensitive) != nil {
                        return true
                    }
                    else {
                        return false
                    }
                })
            }
            tableView.reloadData()
        }
        
        
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! BusinessCell
        let indexPath = tableView.indexPath(for: cell)
        let business = filteredData![indexPath!.item]
        
        let detailViewController = segue.destination as! DetailedViewController
        detailViewController.business = business
        detailViewController.image = cell.thumbImageView.image
        
    }
 
    @IBAction func onTap(_ sender: Any) {
        MBProgressHUD.showAdded(to: self.view, animated: true)
        
        Business.searchWithTerm(term: "Thai", offset: offset, completion: { (businesses: [Business]?, error: Error?) -> Void in
            MBProgressHUD.hide(for: self.view, animated: true)
            
            self.businesses = businesses
            self.filteredData = businesses
            self.tableView.reloadData()
            
            self.networkError.isHidden = true;
            
            if error != nil {
                self.networkError.isHidden = false;
            }
            /*
             if let businesses = businesses {
             for business in businesses {
             print(business.name!)
             print(business.address!)
             }
             }
             */
            
        }
        )
    }
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
