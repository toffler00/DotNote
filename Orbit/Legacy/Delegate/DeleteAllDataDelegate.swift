//
//  DeleteAllDataDelegate.swift
//  Orbit
//
//  Created by ilhan won on 24/04/2019.
//  Copyright © 2019 orbit. All rights reserved.
//

import Foundation
import UIKit

extension ListViewController : DeleteAllDataDelegate {
    func deleteAllDataDelegate() {
        self.listTableView.reloadData()
        self.calendarView.reloadData()
    }
}
