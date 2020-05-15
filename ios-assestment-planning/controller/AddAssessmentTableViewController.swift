//
//  AddAssessmentTableViewController.swift
//  ios-assestment-planning
//
//  Created by Koshila Dissanayake on 5/13/20.
//  Copyright © 2020 Koshila Dissanayake. All rights reserved.
//

import UIKit
import CoreData
import EventKit

class AddAssessmentTableViewController: UITableViewController, UITextViewDelegate, UIPopoverPresentationControllerDelegate {
    
    var projects: [NSManagedObject] = []
    
    @IBOutlet weak var calendarSwitch: UISwitch!
    @IBOutlet weak var projectName: UITextField!
    @IBOutlet weak var note: UITextField!
    @IBOutlet weak var endDate: UIDatePicker!
    @IBOutlet weak var moduleName: UITextField!
    @IBOutlet weak var value: UITextField!
    
    var parentController: ViewAssessmentTableViewController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        endDate.minimumDate = NSDate() as Date
    }
    
    @IBAction func saveProject(_ sender: Any) {
        let projectName = self.projectName.text
        let note = self.note.text
        let endDate = self.endDate.date
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
          appDelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Project", in: managedContext)!
        
        let projectEntity = NSManagedObject(entity: entity, insertInto: managedContext)
        
        projectEntity.setValue(Int64((Date().timeIntervalSince1970 * 1000.0).rounded()), forKey: "id")
        projectEntity.setValue(projectName, forKey: "projectName")
        projectEntity.setValue(note, forKey: "note")
        projectEntity.setValue(endDate, forKey: "endDate")
        projectEntity.setValue(moduleName.text, forKey: "moduleName")
        projectEntity.setValue(Date(), forKey: "startDate")
        
        let val = value.text!
        projectEntity.setValue(Int(val), forKey: "value")
        
        print(projectEntity)
        do {
            try managedContext.save()
            projects.append(projectEntity)
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
                    calendarIdentifier = self.createEvent(eventStore, title: self.projectName.text!, startDate: Date(), endDate: endDate)
                })
            } else {
                calendarIdentifier = createEvent(eventStore, title: projectName!, startDate: Date(), endDate: endDate)
            }
            
            if calendarIdentifier != "" {
               
            }
        }
        
        parentController?.findAssessments()
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
}

extension AddAssessmentTableViewController {
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 0 {
            return 240
        }
        else if indexPath.section == 1 && indexPath.row == 0 {
            return 200
        }
        return 0
    }
    
}
