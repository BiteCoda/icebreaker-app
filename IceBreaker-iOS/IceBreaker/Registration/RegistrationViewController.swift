//
//  RegistrationViewController.swift
//  IceBreaker
//
//  Created by Jacob Chen on 3/10/15.
//  Copyright (c) 2015 floridapoly.IceMakers. All rights reserved.
//

import UIKit

class RegistrationViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var beaconsTableView: UITableView!
    
    var cellIdentifier: String = "beaconCell"
    var beacons: [ESTBeacon] = []
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Notification Center
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"foundAllBeacons:", name: NOTIF_ALL_BEACONS_FOUND, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "noBeaconsFound:", name: NOTIF_NONE_FOUND, object: nil)
    }

    override func viewWillAppear(animated: Bool) {
        
        self.navigationController?.navigationBar.hidden = true;
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITableView Methods
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beacons.count
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var beaconCell: BeaconTableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as BeaconTableViewCell
        
        beaconCell.setBeacon(beacons[indexPath.row])
        
        return beaconCell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Take to the password authentication page
        
        var authenticationPage: AuthenticationViewController = self.storyboard?.instantiateViewControllerWithIdentifier(AUTHENTICATION_CONTROLLER) as AuthenticationViewController
        
        authenticationPage.selectedBeacon = beacons[indexPath.row]
        
        self.navigationController?.pushViewController(authenticationPage, animated: true)
        
    }
    
    // MARK: Button methods
    
    @IBAction func didTouchUpInSearchButton(sender: AnyObject) {
        
        // Start ranging and display beacons
        if (BeaconManager.sharedBeaconManager.listenToRegion(
            mode: beaconManagerMode.discoveryAllMode,
            majID: nil,
            minID: nil))
        {
                
            SVProgressHUD.show()
                
        } else {
            
            var alert = UIAlertController(title: "Error", message: "Make sure Bluetooth is on and working", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(
                title: "OK",
                style: UIAlertActionStyle.Default,
                handler: nil
                )
            )
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        
        
    }
    
    // MARK: Notification methods
    
    func foundAllBeacons(notification: NSNotification) {
        
        SVProgressHUD.dismiss()
        
        beacons = notification.userInfo![NOTIF_ALL_BEACONS_KEY] as [ESTBeacon]
        
        self.beaconsTableView.reloadData()
        
    }
    
    func noBeaconsFound(notification: NSNotification) {
        
        SVProgressHUD.dismiss()
        
        var alert = UIAlertController(title: "Try again", message: "Somethings up, Search again?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.Default,
            handler: nil
            )
        )
        self.presentViewController(alert, animated: true, completion: nil)
        
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
