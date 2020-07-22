//
//  ViewController.swift
//  Notepad App
//
//  Created by Andrew Rosinski on 6/20/20.
//  Copyright © 2020 Andrew Rosinski. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var table: UITableView!
    var data:[String] = []
    var selectedRow:Int = -1
    var newRowText:String = ""
    
    // save data to a file
    var fileURL:URL!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        table.dataSource = self
        table.delegate = self
        self.title = "Notepad"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNote))
        self.navigationItem.rightBarButtonItem = addButton
        self.navigationItem.leftBarButtonItem = editButtonItem
        
        // save file path url
        let baseURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        fileURL = baseURL.appendingPathComponent("notes.txt")
        
        load()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if selectedRow == -1 {
            return
        }
        data[selectedRow] = newRowText
        if newRowText == "" {
            data.remove(at: selectedRow)
        }
        table.reloadData()
        save()
    }
    
    // add note to array
    @objc func addNote() {
        // disable add rows when in editing mode
        if table.isEditing {
            return
        }
        // uncomment to init new note with Item plus number count
        // let name:String = "Item \(data.count + 1)"
        let name:String = ""
        data.insert(name, at: 0)
        let indexPath:IndexPath = IndexPath(row: 0, section: 0)
        table.insertRows(at: [indexPath], with: .automatic)
        table.selectRow(at: indexPath, animated: true, scrollPosition: .none)
        self.performSegue(withIdentifier: "detail", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        cell.textLabel?.text = data[indexPath.row]
        return cell
     }
    
    // handle edit button
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        table.setEditing(editing, animated: animated)
    }
    
    // enable delete rows
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        data.remove(at: indexPath.row)
        table.deleteRows(at: [indexPath], with: .fade)
        save()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "detail", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let detailView:DetailViewController = segue.destination as!  DetailViewController
        selectedRow = table.indexPathForSelectedRow!.row
        detailView.masterView = self
        detailView.setText(t: data[selectedRow])
    }
    
    // save
    func save() {
        // UserDefaults.standard.set(data, forKey: "notes")
        let a = NSArray(array: data)
        do {
            try a.write(to: fileURL)
        } catch {
            print("error writing file")
        }
    }
    
    // load
    func load() {
        if let loadedData:[String] = NSArray(contentsOf:fileURL) as? [String] {
            data = loadedData
            table.reloadData()
        }
    }
    
    
}

