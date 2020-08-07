//
//  LeggTilVareStrekkodeMetodeKontroller.swift
//  MatSpar
//
//  Created by Eskil Sviggum on 03/08/2020.
//

import UIKit
import AVFoundation
import CoreImage
import Verdensrommet

class LeggTilVareStrekkodeMetodeKontroller: UIViewController, LeggTilVareMetodeKontroller, AVCaptureMetadataOutputObjectsDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    
    @IBOutlet var statusLabel: UILabel!
    
    var navBarHøgd: CGFloat!
    var delegat: LeggTilVareMetodeKontrollerDelegat?
    
    var statusBarHogd: CGFloat!
    var knappFlyt: CGFloat = 20
    
    var skalSyneHjelp: Bool = NO
    var kanScanneKodar = YES
    var erIPowerdown: Bool = NO
    
    var captureOkt: AVCaptureSession!
    var forhandsvisninsLayer: AVCaptureVideoPreviewLayer!
    var captureDeviss: AVCaptureDevice!
    
    let videoKø = DispatchQueue(label: "vidio", qos: .background)
    
    var harTilgangTilKamera = YES
    
    let focusPointView = UIView(frame: CGRect(x: 0, y: 0, width: 55, height: 55))

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.captureOkt = AVCaptureSession()
        self.captureDeviss = AVCaptureDevice.default(for: .video)
        
        if captureDeviss == nil { return }
        
        statusBarHogd = (UIApplication.shared.connectedScenes.first! as? UIWindowScene)?.statusBarManager?.statusBarFrame.height
        
        self.setOppFocusview()
        self.view.addSubview(focusPointView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if captureDeviss == nil { return }
        self.setOppCaptureøkt()
        
    }
    
    func skalByteView() {
        stoppØkta()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        stoppØkta()
    }
    
    func setOppCaptureøkt() {
        do {
            try captureDeviss.lockForConfiguration()
            captureDeviss.exposureMode = .continuousAutoExposure
            captureDeviss.unlockForConfiguration()
        }catch {
            print("Kunne ikkje låse “vidioEining” for konfigurering til kontiunerleg autoeksponering, feilmelding : \(error). „HovudController.swift”")
        }
        
        let vidioInput : AVCaptureDeviceInput
        
        do {
            vidioInput = try AVCaptureDeviceInput(device: captureDeviss)
        } catch {
            print(error)
            //Brukaren har ikkje godtatt å nytte kameraet.
            harTilgangTilKamera = NO
            return
        }
        
        if captureOkt.canAddInput(vidioInput) {
            captureOkt.addInput(vidioInput)
        } else {
            mislukkast()
            return
        }
        
        let lysOutput = AVCaptureVideoDataOutput()
        lysOutput.setSampleBufferDelegate(self, queue: DispatchQueue.main)
        
        if #available(iOS 12.0, *) {
            if captureOkt.canAddOutput(lysOutput) { captureOkt.addOutput(lysOutput)
            }
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if captureOkt.canAddOutput(metadataOutput) {
            captureOkt.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [ .ean13, .ean8]
        } else {
            mislukkast()
            return
        }
        
        DispatchQueue.main.async {
            self.forhandsvisninsLayer = AVCaptureVideoPreviewLayer(session: self.captureOkt)
            
            let bounds = self.view.bounds
            let diff = bounds.width - UIScreen.main.bounds.width
            let statHei = (UIApplication.shared.connectedScenes.first! as? UIWindowScene)!.statusBarManager!.statusBarFrame.height
            self.forhandsvisninsLayer.frame = CGRect(x: bounds.minX, y: bounds.minY + statHei, width: bounds.width - diff, height: bounds.height)
            self.forhandsvisninsLayer.masksToBounds = YES
            
            self.forhandsvisninsLayer.connection?.videoOrientation = UIDevice.current.orientation.toVideoOrientation()
            self.forhandsvisninsLayer.videoGravity = .resizeAspectFill
            self.view.layer.insertSublayer(self.forhandsvisninsLayer, at: 0)
        }
        
        captureOkt.startRunning()
    }
    
    func setOppFocusview() {
        //focusPointView.layer.cornerRadius = focusPointView.frame.height/5
        focusPointView.backgroundColor = .clear
        //focusPointView.layer.borderWidth = 1
        focusPointView.alpha = 0
        focusPointView.isMultipleTouchEnabled = false
        
        let image = UIImage(systemName: "viewfinder", withConfiguration: UIImage.SymbolConfiguration(pointSize: 100, weight: .thin))
        let imageView = UIImageView(image: image)
        imageView.tintColor = .celle
        focusPointView.addSubview(imageView)
        imageView.center = focusPointView.center
        
        /*let pointer = CAShapeLayer()
        pointer.frame = focusPointView.bounds
        let lengd: CGFloat = 20
        
        let sti = UIBezierPath(roundedRect: focusPointView.bounds, cornerRadius: 12)
        
        let maske = CALayer()
        let poses = [CGPoint(x: 4, y: 4), CGPoint(x: 0, y: focusPointView.frame.height), CGPoint(x: focusPointView.frame.width, y: 0), CGPoint(x: focusPointView.frame.width, y: focusPointView.frame.height)]
        for pos in poses {
            let altMask = CAShapeLayer()
            let maskesti = UIBezierPath(rect: CGRect(origin: pos, size: CGSize(width: lengd, height: lengd)))
            altMask.path = maskesti.cgPath
            altMask.fillMode = .both
            maske.addSublayer(altMask)
        }
        
        pointer.path = sti.cgPath
        pointer.mask = maske
        
        focusPointView.layer.borderColor = UIColor.celle.cgColor

        pointer.lineWidth = 1
        pointer.strokeColor = focusPointView.layer.borderColor
        focusPointView.layer.addSublayer(pointer)*/
    }
    
    let minimumLysstyrke: CGFloat = 0.1
    let maksimumLysstyrke: CGFloat = 0.9
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        videoKø.async {
            let ciBilde = CIImage(cvImageBuffer: CMSampleBufferGetImageBuffer(sampleBuffer)!)
            let farge = self.finnGjennomsnittsfargeI(ciBilde: ciBilde)
            
            var lysstyrke: CGFloat = 0.5
            farge?.getHue(nil, saturation: nil, brightness: &lysstyrke, alpha: nil)
            
            DispatchQueue.main.async {
                //Om lysmengden i rommet
                /*var melding = StatusData(id: "Lysadvarsel", melding: "", image: #imageLiteral(resourceName: "round_wb_sunny_black_48pt"))
                if lysstyrke < self.minimumLysstyrke {
                    melding.melding = Localized("Gå til eit lysare område.")
                    self.statusView.synMelding(melding)
                } else if lysstyrke > self.maksimumLysstyrke {
                    melding.melding = Localized("Gå til eit mørkare område.")
                    self.statusView.synMelding(melding)
                } else {
                    self.statusView.lukkMelding(med: "Lysadvarsel")
                }*/
            }
        }
    }
    
    func finnGjennomsnittsfargeI(ciBilde: CIImage) -> UIColor? {
        let extentVector = CIVector(x: ciBilde.extent.origin.x, y: ciBilde.extent.origin.y, z: ciBilde.extent.size.width, w: ciBilde.extent.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: ciBilde, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        
        return UIColor(red: CGFloat(bitmap[0]) / 255, green: CGFloat(bitmap[1]) / 255, blue: CGFloat(bitmap[2]) / 255, alpha: CGFloat(bitmap[3]) / 255)
    }
    
    /*func finnGjennomsnittsfargeI(ciBilde: CIImage) -> UIColor? {
     let average = ciBilde.averageColor()
     return average
     }*/
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        
        if erIPowerdown { return }
        if !kanScanneKodar { return }
        guard let metadataaObjekt = metadataObjects.first else { return }
        
        stoppØkta()
        
        var statusMelding = ("Fann strekkoden")
        var statusVarigheit: Double = 3
        #if DEBUG
        statusMelding += ", type: \(metadataaObjekt.type.rawValue)"
        statusVarigheit = 10
        #endif
        
        //statusView.lukkMelding(med: "Tips")
        
        //let melding = StatusData(melding: statusMelding, image: #imageLiteral(resourceName: "round_receipt_black_36pt"))
        //statusView.synMelding(melding, i: statusVarigheit)
        
        guard let lesbartObjekt = metadataaObjekt as? AVMetadataMachineReadableCodeObject else { return }
        let verdi = lesbartObjekt.stringValue!
        AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate, nil)
        
        DispatchQueue.main.async { [self] in
            fannStrekkode(verdi)
            powerdown()
        }
    }
    
    func startØkta() {
        if self.captureOkt.isRunning == NO {
            videoKø.async {
                self.captureOkt.startRunning()
            }
        }
    }
    
    func stoppØkta() {
        if self.captureOkt.isRunning == YES {
            videoKø.async {
                self.captureOkt.stopRunning()
            }
        }
    }
    
    func powerdown() {
        erIPowerdown = YES
    }
    
    func fannStrekkode(_ verdi: String) {
        if erIPowerdown { return }
        let butikk = butikkManager.spar
        butikk.hentVare(fråStrekkode: verdi) { (resultat) in
            if let resultat = resultat {
                DispatchQueue.main.async {
                    let vare = resultat.contentData._source.vare()
                    self.erIPowerdown = NO
                    self.delegat?.brukarLaTilVare(vare: vare, kanLeggeTilFleire: NO)
                }
            }else if butikk.feilmelding?.localizedDescription == dataFeil.ingenTreff.localizedDescription {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Fann ikkje vara i databasen.", message: "Prøv å scanne ei anna vare.", preferredStyle: .alert)
                    self.present(alert, animated: YES) {
                        Timer.scheduledTimer(withTimeInterval: 4, repeats: NO) { (_) in
                            alert.dismiss(animated: YES) {
                                self.erIPowerdown = NO
                                self.startØkta()
                            }
                        }
                    }
                }
            }else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "Ein feil oppstod", message: "\(butikk.feilmelding)", preferredStyle: .alert)
                    self.present(alert, animated: YES) {
                        Timer.scheduledTimer(withTimeInterval: 3, repeats: NO) { (_) in
                            alert.dismiss(animated: YES) {
                                self.erIPowerdown = NO
                                self.startØkta()
                            }
                        }
                    }
                }
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let tapp = touches.first!
        
        let loc = tapp.location(in: self.view)
        
        let tappaPunkt = forhandsvisninsLayer?.captureDevicePointConverted(fromLayerPoint: loc)
        
        do {
            
            try captureDeviss?.lockForConfiguration()
            if let tapp = tappaPunkt {
                captureDeviss?.focusPointOfInterest = tapp
                captureDeviss?.exposurePointOfInterest = tapp
                captureDeviss?.exposureMode = .continuousAutoExposure
                captureDeviss?.focusMode = .continuousAutoFocus
                focusPointView.frame.origin = loc - CGPoint(x: 25, y: 25)
                
                UIView.animate(withDuration: 0.4, animations: {
                    self.focusPointView.alpha = 1
                }) { (t) in
                    UIView.animate(withDuration: 0.3) {
                        self.focusPointView.alpha = 0
                    }
                }
            }
            captureDeviss?.unlockForConfiguration()
            
        }catch {
            print(error)
        }
    }
    
    func mislukkast() {
        //Då kan du jo og gå autmatisk til manuell inntasting…
        statusLabel.isHidden = NO
        statusLabel.text = "Kunne ikkje sette opp kameraet."
    }


}

extension CGPoint {
    static func - (_ lhs: CGPoint,_ rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}
