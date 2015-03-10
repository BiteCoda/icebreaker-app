//
//  AuthenticationViewController.swift
//  IceBreaker
//
//  Created by Jacob Chen on 3/10/15.
//  Copyright (c) 2015 floridapoly.IceMakers. All rights reserved.
//

import UIKit

class AuthenticationViewController: UIViewController {
    
    var selectedBeacon: ESTBeacon?
    
    @IBOutlet var majorIdLabel: UILabel!
    @IBOutlet var minorIdLabel: UILabel!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        majorIdLabel.text = selectedBeacon?.major.stringValue
        minorIdLabel.text = selectedBeacon?.minor.stringValue
        
        
    }

    override func viewWillAppear(animated: Bool) {
        
        self.navigationController?.navigationBar.hidden = false
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
