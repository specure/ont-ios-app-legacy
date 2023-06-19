/*****************************************************************************************************
 * Copyright 2013 appscape gmbh
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
import RMBTClient

///
let kRoundedCornerRadius: CGFloat = 6.0

///
let kTriangleSize: CGSize = CGSize(width: 30.0, height: 20.0)

protocol RMBTMapCalloutViewDelegate: AnyObject {
    func mapCalloutView(_ sender: RMBTMapCalloutView, didShowDetails measurement: SpeedMeasurementResultResponse)
}
///
class RMBTMapCalloutView: UIView, UITableViewDataSource, UITableViewDelegate {

    ///
    @IBOutlet var tableView: UITableView!

    ///
    @IBOutlet var titleLabel: UILabel!
    
    weak var delegate: RMBTMapCalloutViewDelegate?

    ///
    private var _measurementCells = [KeyValueTableViewCell]()

    ///
    private var _netCells = [KeyValueTableViewCell]()
    
    ///
    private var _deviceCells = [KeyValueTableViewCell]()

    private var _measurement: SpeedMeasurementResultResponse = SpeedMeasurementResultResponse()
    ///
    private var measurement: SpeedMeasurementResultResponse {
        //
        get {
            return _measurement
        }
        //
        set {
            _measurement = newValue
            titleLabel?.text = newValue.timeString
            
            // measurement cells
            if let cmdl = newValue.classifiedMeasurementDataList {
                _measurementCells.append(contentsOf: cmdl.map { item in
                    let cell = ClassifyableKeyValueTableViewCell(style: .value1, reuseIdentifier: nil)
                    //cell.keyLabel?.text = item.title
                    cell.textLabel?.text = item.title
                    //cell.valueLabel?.text = item.value
                    cell.detailTextLabel?.text = item.value
                    
                    // All except NKOM
                    if !RMBTConfig.sharedInstance.RMBT_VERSION_NEW {
                        cell.classification = item.classification
                    }
                    
                    return cell
                })
            }
/////////////////////////
//            // ONT
//            if let jpl = newValue.jpl {
//                
//                let jCell = ClassifyableKeyValueTableViewCell(style: .value1, reuseIdentifier: nil)
//                jCell.textLabel?.text = L("RBMT-BASE-JITTER")
//                jCell.classification = jpl.classification_jitter as? Int
//                
//                if var theJitter = jpl.voip_result_jitter {
//                    jCell.detailTextLabel?.text = theJitter.addMsString()
//                }
//
//                //
//                _measurementCells.append(jCell)
//                ///
//                let plCell = ClassifyableKeyValueTableViewCell(style: .value1, reuseIdentifier: nil)
//                plCell.textLabel?.text = L("RBMT-BASE-PACKETLOSS")
//                plCell.classification = jpl.classification_packet_loss as? Int
//                
//                if var thePackeLoss = jpl.voip_result_packet_loss {
//                    plCell.detailTextLabel?.text = thePackeLoss.addPercentageString()
//                }
//                
//                //
//                _measurementCells.append(plCell)
//            }
/////////////////////////
            // net cells
            if let ndl = newValue.networkDetailList {
                _netCells.append(contentsOf: ndl.map { item in
                    let cell = KeyValueTableViewCell(style: .value1, reuseIdentifier: nil)
                    //cell.keyLabel?.text = item.title
                    cell.textLabel?.text = item.title
                    //cell.valueLabel?.text = item.value
                    cell.detailTextLabel?.text = item.value

                    return cell
                })
            }
            
            // device cells 
            if let device = newValue.device {
                _deviceCells.append(contentsOf: device.map { item in
                    let cell = KeyValueTableViewCell(style: .value1, reuseIdentifier: nil)
                        cell.textLabel?.text = item.title
                        cell.detailTextLabel?.text = item.value
                    
                    return cell
                })
                
            }

            //logger.debug("\(_measurementCells)")
            //logger.debug("\(_netCells)")

            tableView.reloadData()

            frameHeight = tableView.contentSize.height
        }
    }

    var height: CGFloat {
        return self.tableView.contentSize.height
    }
    //

    ///
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    ///
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    ///
    class func calloutViewWithMeasurement(_ measurement: SpeedMeasurementResultResponse) -> RMBTMapCalloutView {
        if let view = Bundle.main.loadNibNamed("RMBTMapCalloutView", owner: self, options: nil)?.first as? RMBTMapCalloutView {
        
            view.measurement = measurement
            
            return view
        }
        
        return RMBTMapCalloutView()
    }

    ///
    @IBAction func getMoreDetails() {
        self.delegate?.mapCalloutView(self, didShowDetails: self.measurement)
        // NSNotificationCenter.defaultCenter().postNotificationName("RMBTTrafficLightTappedNotification", object: self)
        logger.debug("Got link: \(String(describing: measurement.openTestUuid))") // never while beeing as content of a Gooogle Maps marker
    }

    ///
    func setup() {
        tableView.dataSource = self
        tableView.delegate = self
    }

    ///
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }

    ///
    override func layoutSubviews() {
        super.layoutSubviews()
        self.applyMask()
    }

    ///
    func applyMask() {
        let bottom = frameHeight - kTriangleSize.height
        let path: CGMutablePath = CGMutablePath()
        
        path.move(to: CGPoint(x: kRoundedCornerRadius, y: 0.0))
        path.addLine(to: CGPoint(x: frameWidth - kRoundedCornerRadius, y: 0.0))
        path.addArc(tangent1End: CGPoint(x: frameWidth, y: 0.0), tangent2End: CGPoint(x: frameWidth, y: kRoundedCornerRadius),
                    radius: kRoundedCornerRadius)
        path.addLine(to: CGPoint(x: frameWidth, y: bottom - kRoundedCornerRadius))
        path.addArc(tangent1End: CGPoint(x: frameWidth, y: bottom), tangent2End: CGPoint(x: frameWidth - kRoundedCornerRadius, y: bottom), radius: kRoundedCornerRadius)
        path.addLine(to: CGPoint(x: frame.midX + kTriangleSize.width / 2.0, y: bottom))
        path.addLine(to: CGPoint(x: frame.midX, y: frameHeight))
        path.addLine(to: CGPoint(x: frame.midX - kTriangleSize.width / 2.0, y: bottom))
        path.addLine(to: CGPoint(x: kRoundedCornerRadius, y: bottom))
        path.addArc(tangent1End: CGPoint(x: 0.0, y: bottom), tangent2End: CGPoint(x: 0.0, y: bottom - kRoundedCornerRadius),
                    radius: kRoundedCornerRadius)
        path.addLine(to: CGPoint(x: 0.0, y: kRoundedCornerRadius))
        path.addArc(tangent1End: CGPoint(x: 0.0, y: 0.0), tangent2End: CGPoint(x: kRoundedCornerRadius, y: 0.0),
                    radius: kRoundedCornerRadius)

        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path
        shapeLayer.fillColor = UIColor.red.cgColor
        shapeLayer.strokeColor = nil
        shapeLayer.lineWidth = 0.0
        shapeLayer.bounds = self.bounds
        shapeLayer.anchorPoint = CGPoint(x: 0.0, y: 0.0)
        shapeLayer.position = CGPoint(x: 0.0, y: 0.0)

        let borderLayer = NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: shapeLayer)) as! CAShapeLayer
        borderLayer.fillColor = nil
        borderLayer.strokeColor = RMBT_DARK_COLOR.withAlphaComponent(0.75).cgColor
        borderLayer.lineWidth = 3.0

        layer.addSublayer(borderLayer)
        layer.mask = shapeLayer
    }

// MARK: Table delegte

    ///
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        case 0: return _measurementCells[indexPath.row]
        case 1: return _netCells[indexPath.row]
        default: return _deviceCells[indexPath.row]
        }
    }

    ///
    func numberOfSections(in tableView: UITableView) -> Int {
        return _deviceCells.count > 0 ? 3 : 2
    }

    ///
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0: return _measurementCells.count
        case 1: return _netCells.count
        default: return _deviceCells.count
        }
    }

    ///
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case 0: return L("map.callout.measurement")
        case 1: return L("map.callout.network")
        default: return L("device")
        }
    }

    ///
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25.0
    }

    ///
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //let cell = self.tableView(tableView, cellForRowAtIndexPath: indexPath)

        /*if let dtl = cell.detailTextLabel { // TODO: improve. Maybe because there are no meassurements (Got 0 measurements) no text is set
            if let t = dtl.text {
                let textSize: CGSize = t.sizeWithAttributes(["NSFontAttributeName": dtl.font]) // !!!
                return (textSize.width >= 130.0) ? 50.0 : 30.0
            }
        }*/

        return 30.0
    }

}
