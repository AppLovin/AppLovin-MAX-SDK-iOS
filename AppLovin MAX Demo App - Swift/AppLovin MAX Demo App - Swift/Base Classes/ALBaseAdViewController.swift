//
//  ALBaseAdViewController.swift
//  DemoApp-Swift
//
//  Created by Harry Arakkal on 10/7/19.
//  Copyright © 2019 AppLovin. All rights reserved.
//

import AppLovinSDK
import UIKit

class ALBaseAdViewController: UIViewController
{
    @IBOutlet weak var callbackTableView: UITableView!
    
    private var callbacks: [String] = []
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
    self.navigationController?.setToolbarHidden(self.hidesBottomBarWhenPushed, animated: true)
    }

    override func viewWillDisappear(_ animated: Bool)
    {
        self.navigationController?.setToolbarHidden(true, animated: false)
        super.viewWillDisappear(animated)
    }

    internal func logCallback(functionName: String = #function)
    {
        callbacks.append(functionName)
        callbackTableView.insertRows(at: [IndexPath(row: callbacks.count - 1, section: 0)], with: .automatic)
    }
}

extension ALBaseAdViewController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "callbackCell", for: indexPath)
        cell.textLabel?.text = callbacks[indexPath.row]

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return callbacks.count
    }
}
