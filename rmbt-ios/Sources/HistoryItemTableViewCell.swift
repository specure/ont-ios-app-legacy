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
class HistoryItemTableViewCell: UITableViewCell {

    ///
    @IBOutlet var networkTypeImageView: UIImageView?

    ///
    @IBOutlet var networkTypeLabel: UILabel?

    ///
    @IBOutlet var dateLabel: UILabel?

    ///
    @IBOutlet var qosAvailableLabel: UILabel?

    ///
    @IBOutlet var modelLabel: UILabel?

    ///
    @IBOutlet var downloadSpeedLabel: UILabel?

    ///
    @IBOutlet var uploadSpeedLabel: UILabel?

    ///
    @IBOutlet var pingLabel: UILabel?
    
    ///
    @IBOutlet var pingLabelMeasure: UILabel?
    
    ///
    @IBOutlet var downloadLabelMeasure: UILabel?
    
    ///
    @IBOutlet var uploadLabelMeasure: UILabel?
    
    //
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initFromNib()
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        initFromNib()
    }
    
    private func initFromNib() {

    }
    
    func formatTabletSolution() {
        
        if UIDevice.isDeviceTablet() {
            //
            downloadSpeedLabel?.font = UIFont(name: (downloadSpeedLabel?.font?.fontName)!, size: 36)
            uploadSpeedLabel?.font = UIFont(name: (uploadSpeedLabel?.font?.fontName)!, size: 36)
            pingLabel?.font = UIFont(name: (pingLabel?.font?.fontName)!, size: 36)
            //
            pingLabelMeasure?.font = UIFont(name: (pingLabelMeasure?.font?.fontName)!, size: 30)
            downloadLabelMeasure?.font = UIFont(name: (downloadLabelMeasure?.font?.fontName)!, size: 30)
            uploadLabelMeasure?.font = UIFont(name: (uploadLabelMeasure?.font?.fontName)!, size: 30)
        }
    }
}
