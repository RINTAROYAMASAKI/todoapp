//
//  TodosViewController.swift
//  iOSTodos
//
//  Created by Hideaki Ishii on 2/15/15.
//  Copyright (c) 2015 danimal141. All rights reserved.
//

//github_open_data

import UIKit
import CoreData
import Foundation

class TodosViewController: UITableViewController, NSFetchedResultsControllerDelegate{
    
    var count = 0
    
    let managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    lazy var fetchedResultController: NSFetchedResultsController = {
        guard let managedObjectContext = self.managedObjectContext else { return NSFetchedResultsController() }
        let fetchedResultController = NSFetchedResultsController(fetchRequest: self.todoFetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultController.delegate = self
        return fetchedResultController
    }()
    
    let todoFetchRequest: NSFetchRequest = {
        let fetchRequest = NSFetchRequest(entityName: "Todo")
        let sortDescriptor = NSSortDescriptor(key: "content", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        return fetchRequest
    }()
    
    
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //cellの高さ設定
        tableView.rowHeight = 100
        //UITableViewAutomaticDimension
        
        
        
        do {
            try self.fetchedResultController.performFetch()
        } catch _ {
        }
        
        //日付フォーマットの取得
        let dateFormatter = NSDateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy/MM/dd"
        //日付のキャスト
        let date = dateFormatter.stringFromDate(NSDate())
        
        self.navigationController?.navigationBar.topItem?.title = "T O D O"
        
        self.navigationItem.prompt = date
        
        //ナビゲーションタイトル文字列の変更
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor(),UIFontDescriptorNameAttribute: "HelveticaNeue"]
        
        
    }
    
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRowsInsection = self.fetchedResultController.sections?[section].numberOfObjects
        return numberOfRowsInsection ?? 0
    }
    
    
    //セルタップ時のアクション
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // セルの選択状態を解除
        
        let selectedCell = tableView.cellForRowAtIndexPath(indexPath)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        print("section:\(indexPath.section) row:\(indexPath.row)")
        
        
        //checkMarkの制御
        if let selectedCell =  selectedCell{
            if selectedCell.accessoryType != .Checkmark {
                //checkMark色変更
                selectedCell.tintColor = UIColor.redColor()
                selectedCell.accessoryType = UITableViewCellAccessoryType.Checkmark
            }else{
                selectedCell.accessoryType = .None
                
            }
        }
        
    }
    
    
    //初期呼び出し時に実行
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        guard let todo = self.fetchedResultController.objectAtIndexPath(indexPath) as? Todo else { fatalError("Todo is invalid") }
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel?.text = todo.content
        
        return cell
        
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        guard let managedObject = self.fetchedResultController.objectAtIndexPath(indexPath) as? NSManagedObject else { return }
        self.managedObjectContext?.deleteObject(managedObject)
        do {
            try managedObjectContext?.save()
        } catch {
            managedObjectContext?.rollback()
        }
    }
    
    
    // MARK: - NSFetchedResultsControllerDelegate Protocol
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        self.tableView.reloadData()
    }
    
}
