//
//  ViewController.swift
//  FypTest_APP
//
//  Created by TLok  on 19/9/2021.
//

import UIKit
import AVFoundation
import AudioToolbox

class ViewController: UIViewController {

    
    let videoCapture = VideoCapture()
    var previewLayer: AVCaptureVideoPreviewLayer?
    var Actioncount: Int = 0
    var  pointLayer = CAShapeLayer()
    private let AcLabel: UILabel = {
        let Label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        Label.layer.borderWidth = 10
        Label.layer.borderColor = UIColor.white.cgColor
        return Label }()


    
    @IBOutlet var actionCountLabel: UILabel!
    var isThrowDetected = false
    

    func ActionCountlabelSelect(){
        var tempAC: String
        tempAC = String(Actioncount)
        actionCountLabel.text = tempAC;
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
 
        
        setupVideoPreview()
        
        videoCapture.predictor.delegate = self
    }
    private func setupVideoPreview(){
        videoCapture.startCaptureSession()
        previewLayer = AVCaptureVideoPreviewLayer(session: videoCapture.captureSession)
        
        guard let previewLayer = previewLayer else {
            return }
        
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        view.layer.addSublayer(pointLayer)
        pointLayer.frame = view.frame
        pointLayer.strokeColor = UIColor.green.cgColor
        
        
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 21))
               label.center = CGPoint(x: 160, y: 285)
               label.textAlignment = .center
               label.text = "I'm a test label"
        
        label.bringSubviewToFront(<#T##view: UIView##UIView#>)
            
            view.addSubview(label)
    }

}

extension ViewController: PredictorDelegte{
    func predictor(predictor: Predictor, didLableAction action: String, with confience: Double) {
        if action == "Throw" && confience > 0.95 && isThrowDetected == false{
            Actioncount += 1;
            print("Throw detected")
            isThrowDetected = true
            
            DispatchQueue.main.asyncAfter(deadline: .now()+3){
                self.isThrowDetected = false
            }
            DispatchQueue.main.async {
                AudioServicesPlayAlertSound(SystemSoundID(1322))
            }
            
        }
    }
    
    func predictor(predictor: Predictor, didFindNewRecognizedPoints point: [CGPoint]) {
        guard let previewLayer = previewLayer else {return}
        
        let convertedPoint = point.map{
            previewLayer.layerPointConverted(fromCaptureDevicePoint: $0)
    }
        let combinedPath = CGMutablePath()
        for point in convertedPoint{
            let dotPath = UIBezierPath(ovalIn: CGRect(x: point.x, y: point.y, width:10 , height: 10))
            combinedPath.addPath(dotPath.cgPath)
        }
        
        pointLayer.path = combinedPath
        
        DispatchQueue.main.async {
            self.pointLayer.didChangeValue(for: \.path)
        }
    }
}

