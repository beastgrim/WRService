//
//  SwiftViewController.swift
//  WRService
//
//  Created by Евгений Богомолов on 08/05/2017.
//  Copyright © 2017 WR. All rights reserved.
//

import UIKit
import WRService


class SwiftViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        testObjectRequest()
    }


    
    func testObjectRequest() {
        let url = URL(string: "https://api.github.com/gists/public")!
        
        let op = WRObjectOperation(request: URLRequest(url: url), resultClass: GitHubGist.self)!
        
        WRService.execute(op, onSuccess: { (op, gists) in
            
            if let gist = (gists as? Array<GitHubGist>)?.first {
                NSLog("Gist: %@", gist)
            }
        }) { (op, error) in
            
        }
    }

}
