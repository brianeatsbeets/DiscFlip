//
//  AddEditDiscTableViewController.swift
//  DiscFlip
//
//  Created by Aguirre, Brian P. on 8/30/22.
//

import UIKit

class AddEditDiscTableViewController: UITableViewController {

    var disc: Disc?
    
    init?(coder: NSCoder, disc: Disc?) {
        self.disc = disc
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
