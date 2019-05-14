//
//  ViewController.swift
//  CalProject
//
//  Created by Luis Paz on 5/12/19.
//  Copyright © 2019 Luis Paz. All rights reserved.
//

import UIKit
import VACalendar
import MBCalendarKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var monthHeaderView: VAMonthHeaderView! {
        didSet {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "LLLL"
            
            let appereance = VAMonthHeaderViewAppearance(
                previousButtonImage: #imageLiteral(resourceName: "previous"),
                nextButtonImage: #imageLiteral(resourceName: "next"),
                dateFormatter: dateFormatter
            )
            monthHeaderView.delegate = self
            monthHeaderView.appearance = appereance
        }
    }
    
    @IBOutlet weak var weekDaysView: VAWeekDaysView! {
        didSet {
            let appereance = VAWeekDaysViewAppearance(symbolsType: .short, calendar: defaultCalendar)
            weekDaysView.appearance = appereance
        }
    }
    
    let defaultCalendar: Calendar = {
        var calendar = Calendar.current
        calendar.firstWeekday = 1
        calendar.timeZone = TimeZone(abbreviation: "EST")!
        return calendar
    }()
    
    var calendarView: VACalendarView!
    var secondsInHour: Double = 3600
    var hoursInDay: Double = 24
    var ed: [(Date, [VADaySupplementary])] = []
    var selectedDate : Date = Date()
    var selectedStringDate : String = ""
    var dateStrings: [String] = ["05/16/2019 10:00","05/16/2019 12:00","05/21/2019 13:00","05/22/2019 08:00", "5/22/2019 09:00"]
    var dateAsDates: [Date] = []
    var assignmentDictionary: [String: [String]] = [:]
    var switchInteger = 1
    
    
    //var viewModel = CalendarViewControllerVM()
    
    // This function converts an array of strings formatted as as 'MM/dd/yyyy HH:mm' to dates in order to be
    // added to the calendar
    func createDateArray() {
        for stringDate in dateStrings {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy HH:mm" // Date format
            dateFormatter.timeZone = TimeZone(abbreviation: "EST") //Current time zone
            
            //Based on format your date string
            guard let date2 = dateFormatter.date(from: stringDate) else {
                fatalError()
            }
            
            dateAsDates.append(date2)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assignmentDictionary["05/16/2019"] = ["10:00 - Assignment 1 Duties", "12:00 - Assignment 2 Duties"]
        assignmentDictionary["05/21/2019"] = ["13:00 - Assignment 3 Duties"]
        assignmentDictionary["05/22/2019"] = ["08:00 - Assignment 4 Duties", "09:00 - Assignment 4 Duties"]
        
        let calendar = VACalendar(calendar: defaultCalendar)
        calendarView = VACalendarView(frame: .zero, calendar: calendar)
        calendarView.showDaysOut = true
        calendarView.selectionStyle = .single
        calendarView.monthDelegate = monthHeaderView
        calendarView.dayViewAppearanceDelegate = self
        calendarView.monthViewAppearanceDelegate = self
        calendarView.calendarDelegate = self
        calendarView.scrollDirection = .horizontal
        
    
        
        
        let now = Date()
        print(now)
        /*
        calendarView.setSupplementaries([
            (now.addingTimeInterval((secondsInHour * hoursInDay * 2)), [VADaySupplementary.bottomDots([.red, .magenta])]),
            (now.addingTimeInterval((60 * 60 * 110)), [VADaySupplementary.bottomDots([.red])]),
            (now.addingTimeInterval((60 * 60 * 370)), [VADaySupplementary.bottomDots([.blue, .darkGray])]),
            (now.addingTimeInterval((60 * 60 * 430)), [VADaySupplementary.bottomDots([.orange, .purple, .cyan])]),
            (Date(), [VADaySupplementary.bottomDots([.orange, .purple, .cyan])])
            ])
         */
        
        createDateArray()
        for date in dateAsDates {
            ed.append((date, [VADaySupplementary.bottomDots([.red])]))
        }
        
        calendarView.setSupplementaries(ed)
        
        view.addSubview(calendarView)
    }
 
    func viewDidAppear() {
        if switchInteger == 1{
            self.tableView.frame = CGRect(x: 0, y: 640, width: 375, height: 172)
        } else if switchInteger == 2 {
            self.tableView.frame = CGRect(x: 0, y: 265, width: 375, height: 500)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if calendarView.frame == .zero {
            calendarView.frame = CGRect(
                x: 0,
                y: weekDaysView.frame.maxY,
                width: view.frame.width,
                height: view.frame.height * 0.6
            )
            calendarView.setup()
        }
        
        if switchInteger == 1{
            self.tableView.frame = CGRect(x: 0, y: 640, width: 375, height: 172)
        } else if switchInteger == 2 {
            self.tableView.frame = CGRect(x: 0, y: 265, width: 375, height: 500)
        }
        tableView.reloadData()
    }
    
    @IBAction func changeMode(_ sender: Any) {
        calendarView.changeViewType()
        if switchInteger == 1{
            switchInteger = 2
        } else {
            switchInteger = 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assignmentDictionary[selectedStringDate]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        
        var compiledString : String = ""
        for stringAssignment in assignmentDictionary[selectedStringDate] ?? [] {
            compiledString += stringAssignment
        }
        
        var stringArr : [String] = []
        stringArr = assignmentDictionary[selectedStringDate] ?? []
        cell.textLabel?.text = stringArr[indexPath.row]
        
        return cell
    }

}

extension ViewController: VAMonthHeaderViewDelegate {
    
    func didTapNextMonth() {
        calendarView.nextMonth()
        //DispatchQueue.main.async { self.tableView.reloadData() }
    }
    
    func didTapPreviousMonth() {
        calendarView.previousMonth()
        //DispatchQueue.main.async { self.tableView.reloadData() }
    }
    
}

extension ViewController: VAMonthViewAppearanceDelegate {
    
    func leftInset() -> CGFloat {
        return 10.0
    }
    
    func rightInset() -> CGFloat {
        return 10.0
    }
    
    func verticalMonthTitleFont() -> UIFont {
        return UIFont.systemFont(ofSize: 16, weight: .semibold)
    }
    
    func verticalMonthTitleColor() -> UIColor {
        return .black
    }
    
    func verticalCurrentMonthTitleColor() -> UIColor {
        return .red
    }
    
}

extension ViewController: VADayViewAppearanceDelegate {
    
    func textColor(for state: VADayState) -> UIColor {
        switch state {
        case .out:
            return UIColor(red: 214 / 255, green: 214 / 255, blue: 219 / 255, alpha: 1.0)
        case .selected:
            return .white
        case .unavailable:
            return .lightGray
        default:
            return .black
        }
    }
    
    func textBackgroundColor(for state: VADayState) -> UIColor {
        switch state {
        case .selected:
            return .red
        default:
            return .clear
        }
    }
    
    func shape() -> VADayShape {
        return .circle
    }
    
    func dotBottomVerticalOffset(for state: VADayState) -> CGFloat {
        switch state {
        case .selected:
            return 2
        default:
            return -7
        }
    }
    
}

extension ViewController: VACalendarViewDelegate {
    
    func selectedDates(_ dates: [Date]) {
        calendarView.startDate = dates.last ?? Date()
        print("Selected")
        print(dates)
        
        
        for currDate in dates {
            selectedDate = currDate
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy" // Format of string
        selectedStringDate = (dateFormatter.string(from: selectedDate))
        
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
    
}

