//
//  AddTaskTableViewController.swift
//  ios-assestment-planning
//
//  Created by Koshila Dissanayake on 5/14/20.
//  Copyright © 2020 Koshila Dissanayake. All rights reserved.
//

import UIKit
import CoreData
import EventKit

class AddTaskTableViewController: UITableViewController {

    var tasks: [NSManagedObject] = []
    var assessment : NSManagedObject? = nil
    var parentController: AssessmentDetailViewController? = nil
    
    @IBOutlet weak var calendarSwitch: UISwitch!
    @IBOutlet weak var notificationPercentage: UISlider!
    @IBOutlet weak var note: UITextField!
    @IBOutlet weak var taskName: UITextField!
    @IBOutlet weak var notifySwitch: UISwitch!
    @IBOutlet weak var endDate: UIDatePicker!
    @IBOutlet weak var completeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        endDate.minimumDate = NSDate() as Date
        endDate.maximumDate = assessment?.value(forKey: "endDate") as? Date
    }
    
    @IBAction func saveTask(_ sender: Any) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
          appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Task", in: managedContext)!
        
        let taskEntity = NSManagedObject(entity: entity, insertInto: managedContext)
        
        taskEntity.setValue(taskName.text, forKey: "taskName")
        taskEntity.setValue(note.text, forKey: "note")
        taskEntity.setValue(Date(), forKey: "startDate")
        taskEntity.setValue(endDate.date, forKey: "endDate")
        taskEntity.setValue(notificationPercentage.value, forKey: "notificationPercentage")
        taskEntity.setValue(notifySwitch.isOn, forKey: "notify")
        taskEntity.setValue(assessment?.value(forKey: "id"), forKey: "projectId")
        
        do {
            try managedContext.save()
            tasks.append(taskEntity)
        } catch let error as NSError {
          print("Could not save. \(error), \(error.userInfo)")
        }
        
        dismiss(animated: true, completion: nil)
        
        // Add To Calendar
        let eventStore = EKEventStore()
        var calendarIdentifier = ""
        
        if calendarSwitch.isOn {
            if (EKEventStore.authorizationStatus(for: .event) != EKAuthorizationStatus.authorized) {
                eventStore.requestAccess(to: .event, completion: {
                    granted, error in
                    calendarIdentifier = self.createEvent(eventStore, title: self.taskName.text!, startDate: Date(), endDate: self.endDate.date)
                })
            } else {
                calendarIdentifier = createEvent(eventStore, title: self.taskName.text!, startDate: Date(), endDate: endDate.date)
            }
            
            if calendarIdentifier != "" {
               
            }
        }
        
        parentController?.findTasks()
    }

    func createEvent(_ eventStore: EKEventStore, title: String, startDate: Date, endDate: Date) -> String {
        let event = EKEvent(eventStore: eventStore)
        var identifier = ""
        
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.calendar = eventStore.defaultCalendarForNewEvents
        
        do {
            try eventStore.save(event, span: .thisEvent)
            identifier = event.eventIdentifier
        } catch {
            let alert = UIAlertController(title: "Error", message: "Calendar event could not be created!", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
        return identifier
    }
    
    @IBAction func completeSlider(_ sender: UISlider) {
        let currentValue = Int(sender.value)
        completeLabel.text = String(currentValue) + "% complete"
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 1 && indexPath.row == 0 {
            return 200.0
        }
        
        // Make Notes text view bigger: 80
        if indexPath.section == 0 && indexPath.row == 0 {
            return 250.0
        }
        
        return 0
    }
}
