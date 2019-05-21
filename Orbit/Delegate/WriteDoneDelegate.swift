//
//  WriteDoneDelegate.swift
//  Orbit
//
//  Created by David Koo on 25/08/2018.
//  Copyright © 2018 orbit. All rights reserved.
//

import UIKit
import Photos

extension ListViewController: WriteDoneDelegate {
    func writeDone() {
        // MARK: - ToDo
        contentDate.removeAll()
        guard let contentDate = realmManager.objects(Content.self).value(forKey: "createdAt") as? [Date] else {return}
        for i in contentDate {
            let date = dateToString(in: i, dateFormat: "yyyyMMdd")
            self.contentDate.append(date)
        }
        calendarView.reloadData()
        listTableView.reloadData()
        print("writeDone")
    }
}

