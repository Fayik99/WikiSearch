//
//  SearchResultsTableViewController.swift
//  WikiSearch
//
//  Created by Fayik Muzammil on 7/24/20.
//  Copyright © 2020 Fayik Muzammil. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SafariServices

final class SearchResultsTableViewController: UITableViewController {

    
    
    private var searchResults = [JSON]() {
    didSet {
    tableView.reloadData()
    }
}
  
        
    private let searchController = UISearchController(searchResultsController: nil)
        private let apiFetcher = APIFetcher()
        private var previousRun = Date()
        private let minInterval = 0.05
        
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        setupTableViewBackgroundView()
        setupSearchBar()
        
        let newXib = UINib(nibName: "CustomTableViewCell", bundle: nil)
        
        tableView.register(newXib, forCellReuseIdentifier: "cell")
       
    }
    
    
    private func setupTableViewBackgroundView() {
        let backgroundViewLabel = UILabel(frame: .zero)
        backgroundViewLabel.textColor = .black
        backgroundViewLabel.backgroundColor = #colorLiteral(red: 0, green: 0.696799651, blue: 0.696799651, alpha: 1)
        backgroundViewLabel.numberOfLines = 0
        backgroundViewLabel.text = " Sorry, No results to show "
        backgroundViewLabel.textAlignment = NSTextAlignment.center
        backgroundViewLabel.font.withSize(30)
        tableView.backgroundView = backgroundViewLabel
    }

    private func setupSearchBar() {
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = "Search anything you want ☺️"
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
    }
  
   override func numberOfSections(in tableView: UITableView) -> Int {
           return 1
       }

       override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return searchResults.count
       }
       
       override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "cell",
            for: indexPath) as! CustomTableViewCell
           
           cell.titleLabel.text = searchResults[indexPath.row]["title"].stringValue
           
           cell.descriptionLabel.text = searchResults[indexPath.row]["terms"]["description"][0].string
           cell.descriptionLabel.sizeToFit()
           
           if let url = searchResults[indexPath.row]["thumbnail"]["source"].string {
               apiFetcher.fetchImage(url: url, completionHandler: { image, _ in
                   cell.wikiImageView.image = image
               })
           }
           
           return cell
       }
       
      override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
          return 140
          }
    
       override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           
           let title = searchResults[indexPath.row]["title"].stringValue
           guard let url = URL.init(string: "https://en.wikipedia.org/wiki/\(title)")
               else { return }
           
           let safariVC = SFSafariViewController(url: url)
           present(safariVC, animated: true, completion: nil)
           tableView.deselectRow(at: indexPath, animated: true)
       }

   }

   extension SearchResultsTableViewController: UISearchBarDelegate {
       
       func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
           searchResults.removeAll()
           guard let textToSearch = searchBar.text, !textToSearch.isEmpty else {
               return
           }
           
           if Date().timeIntervalSince(previousRun) > minInterval {
               previousRun = Date()
               fetchResults(for: textToSearch)
           }
       }
       
       func fetchResults(for text: String) {
           print("Text Searched: \(text)")
           apiFetcher.search(searchText: text, completionHandler: {
               [weak self] results, error in
               if case .failure = error {
                   return
               }
               
               guard let results = results, !results.isEmpty else {
                   return
               }
               
               self?.searchResults = results
           })
       }
       
       func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
           searchResults.removeAll()
       }

   }
