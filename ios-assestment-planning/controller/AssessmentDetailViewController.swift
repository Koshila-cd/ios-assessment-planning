//
//  AssessmentDetailViewController.swift
//  ios-assestment-planning
//
//  Created by Koshila Dissanayake on 5/13/20.
//  Copyright © 2020 Koshila Dissanayake. All rights reserved.
//

import UIKit
import CoreData

class AssessmentDetailViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDelegate, UIPopoverPresentationControllerDelegate, UITableViewDataSource {

    var assessment : NSManagedObject? = nil
    var parentController: ViewAssessmentTableViewController? = nil
    var tasks: [Any] = []
    
    var dateCal: DateCalculations = DateCalculations()
    let dateFormatter : DateFormatter = DateFormatter()
    @IBOutlet weak var completeProgressBar: CircleProgress!
    @IBOutlet weak var remainingDaysProgress: CircleProgress!
    
    @IBOutlet weak var moduleName: UILabel!
    let colours: Colours = Colours()
    
    @IBOutlet weak var note: UILabel!
    @IBOutlet weak var assessmentName: UILabel!
    
    @IBOutlet weak var taskTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        assessmentName.font = UIFont.boldSystemFont(ofSize: 30.0)

        dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
        assessmentName.text = (assessment?.value(forKey: "projectName") as? String)?.uppercased()
        moduleName.text = assessment?.value(forKey: "moduleName") as? String
        note.text = assessment?.value(forKey: "note") as? String
        
        let startDate = (assessment as AnyObject).value(forKey: "startDate")
        let dueDate = (assessment as AnyObject).value(forKey: "endDate")
        
        let daysRemPercentage = Int(self.dateCal.getRemainingTimePercentage(startDate! as! Date, end: dueDate! as! Date))
        let days = self.dateCal.getDateDiff(Date(), end: dueDate as! Date)
        
        DispatchQueue.main.async {
            let colours = self.colours.getProgressGradient(daysRemPercentage)
            self.remainingDaysProgress?.customTitle = "\(days)"
            self.remainingDaysProgress?.customSubtitle = "Days Left"
            self.remainingDaysProgress?.startGradientColor = colours[0]
            self.remainingDaysProgress?.endGradientColor = colours[1]
            self.remainingDaysProgress?.progress = CGFloat(daysRemPercentage) / 100
            self.remainingDaysProgress?.isHidden = false
        }
        
        taskTableView.delegate = self
        taskTableView.dataSource = self
        
        findTasks()
    }
    
    func findTasks(){
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        let predicate = NSPredicate(format: "projectId = %@", assessment?.value(forKey: "id") as! CVarArg)
        fetchRequest.predicate = predicate
        
        // Create Entity Description
        let entityDescription = NSEntityDescription.entity(forEntityName: "Task", in: managedContext)
        
        // Configure Fetch Request
        fetchRequest.entity = entityDescription
        
        do {
            tasks = try managedContext.fetch(fetchRequest)
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        taskTableView.reloadData()
        
        setCompleteProgress()
    }
    
    func setCompleteProgress(){
        if tasks.count > 0 {
            
            var days: Int = 0
            
            for task in tasks {
                
                let startDate = (task as AnyObject).value(forKey: "startDate")
                let dueDate = (task as AnyObject).value(forKey: "endDate")
                
                days += Int(self.dateCal.getRemainingTimePercentage(startDate! as! Date, end: dueDate! as! Date))
            }
            
            let percentage = days / tasks.count
            
            
            DispatchQueue.main.async {
                       let colours = self.colours.getProgressGradient(percentage)
                       self.completeProgressBar?.customSubtitle = "Completed"
                       self.completeProgressBar?.startGradientColor = colours[0]
                       self.completeProgressBar?.endGradientColor = colours[1]
                       self.completeProgressBar?.progress = CGFloat(percentage) / 100
                       self.completeProgressBar?.isHidden = false
            }
                   
        }else {
            DispatchQueue.main.async {
                       let colours = self.colours.getProgressGradient(0)
                       self.completeProgressBar?.customSubtitle = "Completed"
                       self.completeProgressBar?.startGradientColor = colours[0]
                       self.completeProgressBar?.endGradientColor = colours[1]
                       self.completeProgressBar?.progress = CGFloat(0) / 100
                       self.completeProgressBar?.isHidden = false
            }
        }
    }

    @IBAction func deleteTask(_ sender: Any) {
        let index = self.taskTableView.indexPathForSelectedRow
        
        if index != nil {
            let refreshAlert = UIAlertController(title: "Delete Task", message: "Are you sure you want to delete task?", preferredStyle: UIAlertController.Style.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                
                let task = self.tasks[index!.row]
                
                if task != nil {
                    guard let appDelegate =
                        UIApplication.shared.delegate as? AppDelegate else {
                            return
                    }
                    
                    let context =
                        appDelegate.persistentContainer.viewContext
                    
                    do {
                        context.delete(task as! NSManagedObject)
                        try context.save();
                    }catch{}
                    
                    self.findTasks()
                }
                
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                
            }))
            
            present(refreshAlert, animated: true, completion: nil)
        }else{
            let refreshAlert = UIAlertController(title: "Task Not Selected", message: "Please select a task", preferredStyle: UIAlertController.Style.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                           
            }))
            
            present(refreshAlert, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell") as! TaskTableViewCell

        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(red: 204/255, green: 255/255, blue: 229/255, alpha: 1.00)
        cell.selectedBackgroundView = bgColorView

        let taskEntity: NSManagedObject? = tasks[indexPath.row] as? NSManagedObject
        cell.taskNo.text = "Task " + String(indexPath.row + 1)
        
        cell.taskName.text = (taskEntity?.value(forKey: "taskName") as? String)?.uppercased()
        cell.taskNote.text = taskEntity?.value(forKey: "note") as? String
        cell.endDate.text =  dateFormatter.string(from: taskEntity?.value(forKey: "endDate") as! Date)
        
        let startDate = taskEntity?.value(forKey: "startDate")
        let dueDate = taskEntity?.value(forKey: "endDate")
        
        let days = self.dateCal.getRemainingTimePercentage(startDate! as! Date, end: dueDate! as! Date)
        
        cell.progressBar.progress = Float(CGFloat(days) / 100)
        
        DispatchQueue.main.async {
            let colours = self.colours.getProgressGradient(days)
            cell.circleProgress?.customTitle = "\(days)%"
            cell.circleProgress?.customSubtitle = ""
            cell.circleProgress?.startGradientColor = colours[0]
            cell.circleProgress?.endGradientColor = colours[1]
            cell.circleProgress?.progress = CGFloat(days) / 100
            cell.progressBar?.isHidden = false
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openTaskPopover" {
            let controller = (segue.destination as! UINavigationController).topViewController as! AddTaskTableViewController
            controller.assessment = assessment
            controller.parentController = self
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
}
