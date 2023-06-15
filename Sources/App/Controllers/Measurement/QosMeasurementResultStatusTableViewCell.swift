/*****************************************************************************************************
 * Copyright 2014-2016 SPECURE GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *****************************************************************************************************/

import Foundation

///
class QosMeasurementResultStatusTableViewCell: UITableViewCell {

    ///
    @IBOutlet var titleLabel: UILabel?

    ///
    @IBOutlet var resultLabel: UILabel?

    ///
    @IBOutlet var statusView: UIBoolVisualizationView?
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard UIApplication.shared.applicationState == .inactive else {
            return
        }
        
        self.applyColorScheme()
    }
    
    func applyColorScheme() {
        self.backgroundColor = self.isHighlighted ? RMBTColorManager.highlightHistoryCellColor : RMBTColorManager.cellBackground
        self.titleLabel?.textColor = self.isHighlighted ? RMBTColorManager.historyTextColor : RMBTColorManager.tintColor
        self.resultLabel?.textColor = RMBTColorManager.textColor
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.setHighlighted(selected, animated: animated)
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        let duration = highlighted ? 0.0 : 0.3
        UIView.animate(withDuration: duration) {
            self.applyColorScheme()
        }
    }
}
