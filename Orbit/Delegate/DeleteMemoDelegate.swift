//
//  DeleteMemoDelegate.swift
//  Orbit
//
//  Created by ilhan won on 21/02/2019.
//  Copyright © 2019 orbit. All rights reserved.
//

import UIKit

extension ListViewController : DeleteMemoDelgate {
    func deleteDataDelegate() {
        contentDate.removeAll()
        guard let contentDate = realmManager.objects(Content.self).value(forKey: "createdAt") as? [Date] else {return}
        for i in contentDate {
            let date = dateToString(in: i, dateFormat: "yyyyMMdd")
            self.contentDate.append(date)
        }
        self.calendarView.reloadData()
        self.listTableView.reloadData()
    }
    
}
