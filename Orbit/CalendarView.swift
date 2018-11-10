//
//  CalendarView.swift
//  Orbit
//
//  Created by ilhan won on 10/10/2018.
//  Copyright © 2018 orbit. All rights reserved.
//

import UIKit
import JTAppleCalendar
import RealmSwift

extension ListViewController {
    
    func setUpUI() {
        thisMonthLabel = UILabel()
        thisMonthLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let constDate : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: thisMonthLabel, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide,
                               attribute: .top, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: thisMonthLabel, attribute: .leading, relatedBy: .equal, toItem: view.safeAreaLayoutGuide,
                               attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: thisMonthLabel, attribute: .trailing, relatedBy: .equal, toItem: view.safeAreaLayoutGuide,
                               attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: thisMonthLabel, attribute: .height, relatedBy: .equal, toItem: nil,
                               attribute: .height, multiplier: 1, constant: 24)]
        
        view.addSubview(thisMonthLabel)
        view.addConstraints(constDate)
        thisMonthLabel.textAlignment = .center
        thisMonthLabel.textColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        thisMonthLabel.font = UIFont.boldSystemFont(ofSize: 14)
        thisMonthLabel.backgroundColor = UIColor(red: 47/255, green: 36/255, blue: 34/255, alpha: 1)

        weeksStackView = UIStackView()
        weeksStackView.translatesAutoresizingMaskIntoConstraints = false
        
        let constStack : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: weeksStackView, attribute: .top, relatedBy: .equal, toItem: thisMonthLabel,
                               attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: weeksStackView, attribute: .leading, relatedBy: .equal, toItem: view.safeAreaLayoutGuide,
                               attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: weeksStackView, attribute: .trailing, relatedBy: .equal, toItem: view.safeAreaLayoutGuide,
                               attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: weeksStackView, attribute: .height, relatedBy: .equal, toItem: nil,
                               attribute: .height, multiplier: 1, constant: 24)]
        view.addSubview(weeksStackView)
        view.addConstraints(constStack)
        weeksStackView.axis = .horizontal
        makeWeekLabel()
        weeksStackView.alignment = .fill
        weeksStackView.distribution = .fillEqually

    }
    
    func makeWeekLabel() {
        for i in self.weeks {
            let weekLabel = UILabel()
            weekLabel.text = i
            weekLabel.font = UIFont.boldSystemFont(ofSize: 14)
            weekLabel.textColor = UIColor(red: 47/255, green: 36/255, blue: 34/255, alpha: 1)
            weekLabel.backgroundColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
            weekLabel.textAlignment = .center
            self.weeksStackView.addArrangedSubview(weekLabel)
        }
    }
    
    
    func setUpCalendarView() {
        
        let layout = UICollectionViewFlowLayout()
        let width = self.view.frame.size.width / 7
        layout.itemSize = CGSize(width: width, height: width)
        layout.scrollDirection = .horizontal
        
        calendarView = JTAppleCalendarView(frame: CGRect.zero)
        calendarView.register(CalendarCell.self, forCellWithReuseIdentifier: "cell")
        calendarView.ibCalendarDelegate = self
        calendarView.ibCalendarDataSource = self
        calendarView.translatesAutoresizingMaskIntoConstraints = false
        
        let constCalendar : [NSLayoutConstraint] = [
            NSLayoutConstraint(item: calendarView, attribute: .top, relatedBy: .equal, toItem: weeksStackView,
                               attribute: .bottom, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: calendarView, attribute: .leading, relatedBy: .equal, toItem: view.safeAreaLayoutGuide,
                               attribute: .leading, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: calendarView, attribute: .trailing, relatedBy: .equal, toItem: view.safeAreaLayoutGuide,
                               attribute: .trailing, multiplier: 1, constant: 0),
            NSLayoutConstraint(item: calendarView, attribute: .height, relatedBy: .equal, toItem: view,
                               attribute: .width, multiplier: 0.9, constant: 0)]
        
        view.addSubview(calendarView)
        calendarView.minimumLineSpacing = 0.5
        calendarView.minimumInteritemSpacing = 0.5
        calendarView.scrollDirection = UICollectionView.ScrollDirection.horizontal
        calendarView.scrollingMode = .stopAtEachCalendarFrame
        calendarView.backgroundColor = .white
        view.addConstraints(constCalendar)
    }
    
}

extension ListViewController : JTAppleCalendarViewDelegate,  JTAppleCalendarViewDataSource {
    func setCalendar() {
        calendarView.visibleDates { (segeInfo) in
            self.updateDateLabel(visibleDate: segeInfo)
            self.dateFormatter.locale = Locale.init(identifier: "kr_KR")
            self.calendarView.scrollToDate(Date.init())
        }
    }
    
    func updateDateLabel(visibleDate : DateSegmentInfo) {
        let date = visibleDate.monthDates.first!.date
        dateFormatter.dateFormat = "MMM yyyy"
        dateFormatter.locale = Locale(identifier: "kr_KR")
        self.thisMonthLabel.text = dateFormatter.string(from: date)
    }
    
    func handleCellColor(cell : JTAppleCell?, cellState : CellState) {
        guard let validCell = cell as? CalendarCell else {return}
        dateFormatter.dateFormat = "yyyy MM dd"
        dateFormatter.locale = Locale(identifier: "kr_KR")
        let currentDate = dateFormatter.string(from: Date.init())
        let cellDate = dateFormatter.string(from: cellState.date)
        
        if currentDate == cellDate {
            validCell.todayView.backgroundColor = #colorLiteral(red: 0.9249536042, green: 0.7891158494, blue: 1, alpha: 1)
        } else {
            validCell.todayView.backgroundColor = .clear
        }
        
        if cellState.isSelected {
            validCell.dateLabel.textColor = .gray
        } else {
          if cellState.dateBelongsTo == .thisMonth {
            validCell.dateLabel.textColor = .black
          } else {
            validCell.dateLabel.textColor = .lightGray
        }
        }
    }
    
    func handleSelectedCellColor(cell : JTAppleCell?, cellState : CellState) {
        guard let validCell = cell as? CalendarCell else {return}
        if cellState.isSelected {
            validCell.isSelectedImg.isHidden = false
            validCell.dateLabel.textColor = UIColor(red: 1, green: 1, blue: 240/255, alpha: 1)
        } else {
            validCell.isSelectedImg.isHidden = true
            validCell.dateLabel.textColor = UIColor(red: 47/255, green: 36/255, blue: 34/255, alpha: 1)
        }
    }
    
    func handleCellisContents(cell : JTAppleCell? ,cellState : CellState) {
        guard let validCell = cell as? CalendarCell else {return}
        dateFormatter.dateFormat = "yyyyMMdd"
        let contentsDate = dateFormatter.string(from: cellState.date)
        if self.contentDate.contains(contentsDate) {
            validCell.isContentsImg.isHidden = false
        }else {
            validCell.isContentsImg.isHidden = true
        }
        
    }
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        handleSelectedCellColor(cell: cell, cellState: cellState)
        handleCellColor(cell: cell, cellState: cellState)
        handleCellisContents(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "cell", for: indexPath) as! CalendarCell
        cell.dateLabel.text = cellState.text
        handleSelectedCellColor(cell: cell, cellState: cellState)
        handleCellColor(cell: cell, cellState: cellState)
        handleCellisContents(cell: cell, cellState: cellState)
        return cell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleSelectedCellColor(cell: cell, cellState: cellState)
        handleCellColor(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        handleSelectedCellColor(cell: cell, cellState: cellState)
        handleCellColor(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        self.updateDateLabel(visibleDate: visibleDates)
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        dateFormatter.dateFormat = "yyyy MM dd"
        dateFormatter.timeZone = Calendar.current.timeZone
        dateFormatter.locale = Calendar.current.locale
        
        let startDate = dateFormatter.date(from: "2017 01 01")!
        let endDate = dateFormatter.date(from: "2021 12 31")!
        let parameters = ConfigurationParameters.init(startDate: startDate, endDate: endDate)
        return parameters
    }

}

