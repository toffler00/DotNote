//
//  DrawingDiarySaveDelegate.swift
//  Orbit
//
//  Created by ilhan won on 13/03/2019.
//  Copyright © 2019 orbit. All rights reserved.
//

import UIKit

extension ListViewController : DrawingDiarySaveDelegate {
    func drawingDiarySaveDelegate() {
        // MARK: - ToDo
        contentDate.removeAll()
        guard let contentDate = realmManager.objects(Content.self).value(forKey: "createdAt") as? [Date] else {return}
        for i in contentDate {
            let date = dateToString(in: i, dateFormat: "yyyyMMdd")
            self.contentDate.append(date)
        }
        calendarView.reloadData()
        listTableView.reloadData()
        print("drawingDiarySave")
    }
}
