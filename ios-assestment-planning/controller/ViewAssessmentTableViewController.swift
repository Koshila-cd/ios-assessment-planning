//
//  ViewAssessmentTableViewController.swift
//  ios-assestment-planning
//
//  Created by Koshila Dissanayake on 5/13/20.
//  Copyright © 2020 Koshila Dissanayake. All rights reserved.
//

import UIKit
import CoreData

class ViewAssessmentTableViewController: UITableViewController
,NSFetchedResultsControllerDelegate, UIPopoverPresentationControllerDelegate{
    
    var assessments: [Any] = []
    let dateFormatter : DateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dateFormatter.dateFormat = "dd MMM yyyy HH:mm"
        
        findAssessments()
    }

    func findAssessments(){
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        
        // Create Entity Description
        let entityDescription = NSEntityDescription.entity(forEntityName: "Project", in: managedContext)
        
        // Configure Fetch Request
        fetchRequest.entity = entityDescription
        
        do {
            assessments = try managedContext.fetch(fetchRequest)
        } catch {
            let fetchError = error as NSError
            print(fetchError)
        }
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let indexPath = IndexPath(row: 0, section: 0)
        autoSelectRow(indexPath: indexPath);
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return assessments.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AssessmentCell") as! AssessmentTableViewCell
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor(red: 204/255, green: 255/255, blue: 229/255, alpha: 1.00)
        cell.selectedBackgroundView = bgColorView

        let assessment = assessments[indexPath.row] as! NSManagedObject;
        cell.assessmentName.text = assessment.value(forKey: "projectName") as? String
        
        let endDate = assessment.value(forKey: "endDate")
        
        cell.endDate.text = dateFormatter.string(from: endDate as! Date)
        
        let module = assessment.value(forKey: "moduleName");
        
        if module != nil {
            cell.moduleName.text = module as? String
        }else{
            cell.moduleName.text = ""
        }
        
        return cell
    }
    
    @IBAction func deleteAssesment(_ sender: Any) {
        let index = self.tableView.indexPathForSelectedRow
        
        if index != nil {
            let refreshAlert = UIAlertController(title: "Delete Assessment", message: "Are you sure you want to delete assessment?", preferredStyle: UIAlertController.Style.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                
                let index = self.tableView.indexPathForSelectedRow
                let assessment = self.assessments[index!.row]
                
                if assessment != nil {
                    guard let appDelegate =
                        UIApplication.shared.delegate as? AppDelegate else {
                            return
                    }
                    
                    let context =
                        appDelegate.persistentContainer.viewContext
                    
                    do {
                        context.delete(assessment as! NSManagedObject)
                        try context.save();
                    }catch{}
                    
                    self.findAssessments()
                }
                
            }))
            
            refreshAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action: UIAlertAction!) in
                
            }))
            
            present(refreshAlert, animated: true, completion: nil)
        }else{
            let refreshAlert = UIAlertController(title: "Assessment Not Selected", message: "Please select a assessment", preferredStyle: UIAlertController.Style.alert)
            
            refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                
            }))
            
            present(refreshAlert, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        autoSelectRow(indexPath: indexPath)
    }
    
    func autoSelectRow(indexPath: IndexPath) {
        
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
        if tableView.indexPathForSelectedRow != nil {
            let assessment = assessments[indexPath.row]
            self.performSegue(withIdentifier: "showAssessmentDetails", sender: assessment)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showAssessmentDetails" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let assessment = assessments[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! AssessmentDetailViewController
                controller.assessment = assessment as? NSManagedObject
                controller.parentController = self
            }
        }
        
        if segue.identifier == "openAssessmentPopup"{
            let controller = (segue.destination as! UINavigationController).topViewController as! AddAssessmentTableViewController
            controller.parentController = self
        }
        
    }
}
