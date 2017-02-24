//
//  PBCellState.swift
//  VelikOS
//
//  Created by Pavel Borisevich on 21.02.17.
//  Copyright © 2017 Pavel Borisevich. All rights reserved.
//

import Cocoa

class PBCellState: NSTableCellView, NSComboBoxDelegate {
    
    var rowInTable = 0
    weak var table: NSTableView?
    
    var savedState = 0
    @IBOutlet weak var comboBox: NSComboBox?
    func comboBoxSelectionDidChange(_ notification: Notification) {
        
        guard let unwrappedBox = comboBox else {
            return
        }
        
        if let cellSaved = table?.rowView(atRow: rowInTable, makeIfNecessary: false)?.view(atColumn: 5) as? PBCellSaved {
            cellSaved.isSaved = unwrappedBox.indexOfSelectedItem == savedState
        }
    }
}
