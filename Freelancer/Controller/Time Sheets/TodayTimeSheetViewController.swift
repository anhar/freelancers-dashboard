//
//  TodayTimeSheetViewController.swift
//  Freelancer
//
//  Created by Nikola on 2/4/19.
//  Copyright © 2019 Stojković. All rights reserved.
//

import Foundation
import Cocoa
import SQLite

class TodayTimeSheetViewController: NSViewController {
    
    
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var cellFrom: NSTableCellView!
    @IBOutlet weak var cellTo: NSTableCellView!
    @IBOutlet weak var cellTotal: NSTableCellView!
    @IBOutlet weak var currentDay: NSTextField!
    
    let ts_date         = Expression<String>("ts_date")
    let ts_from         = Expression<String>("ts_from")
    let ts_to           = Expression<String>("ts_to")
    let ts_total_time   = Expression<String>("ts_total_time")
    let ts_approved     = Expression<Int64>("ts_approved")
    
    let db = try? Connection("\( NSApp.supportFolderGet())/db.sqlite3")
    let tableTimesheets = Table("timesheets")

    let fmt = DateFormatter()
    
    var data:[[String:String]] = [[:]]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fmt.dateFormat = "hh:mma"
        let today_start: Date = Date().startOfDay
        let today_end: Date   = Date().endOfDay
//        let today_timesheet   = try! db!.prepare(tableTimesheets.filter(ts_date >= fmt.string(from: today_start) && ts_date <= fmt.string(from: today_end)))
//        let today_timesheet   = try! db!.prepare(tableTimesheets)
        
        let query = tableTimesheets.select(*)
            .filter(ts_date >= fmt.string(from: today_start) && ts_date <= fmt.string(from: today_end))
        
        print(query)
        
        let today_timesheet = try! db?.prepare(query)
        
        data.removeAll()
        
        do {
            for entry in today_timesheet! {
                let date_from = (try! entry.get(ts_from)).toTime()
                let date_to   = try! entry.get(ts_to).toTime()
                NSAlert.showAlert(title: "Sadrzaj fajla", message: date_from?.toString())
                data.append(
                    [
                        "CellFrom": (date_from?.toString())!,
                        "CellTo": (date_to?.toString())!,
                        "CellTotal": try! entry.get(ts_total_time)
                    ]
                )
            }
        }
//        catch let Result.error(message, code, statement) where code == SQLITE_ANY {
//            NSAlert.showAlert(title: "constraint failed: \(message)", message: "\(statement)")
//        } catch let error {
//            NSAlert.showAlert(title: "Read FAIL", message: "\(error)")
//                print("insertion failed: \(error)")
//        }
        print(data)
        
        // reload tableview
        tableView.reloadData()
        
        
        currentDay.stringValue = Date().getDay()
        
    }
  
    
    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

}

extension TodayTimeSheetViewController: NSTableViewDataSource, NSTableViewDelegate {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return (data.count)
    }
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let field = data[row]
        
        let cell = tableView.makeView(withIdentifier: (tableColumn!.identifier), owner: self) as? NSTableCellView
        cell?.textField?.stringValue = field[tableColumn!.identifier.rawValue]!
        
        return cell
    }
}
