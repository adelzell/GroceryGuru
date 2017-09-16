//
//  ViewController.swift
//  BarcodeScanner
//
//  Created by Amelia Delzell on 3/26/17.
//  Code adapted from Matthew Maher's online tutorial: https://www.appcoda.com/simple-barcode-reader-app-swift/
//
//

import UIKit
import AVFoundation
import os.log

class BarcodeReaderViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    var session: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var item: Item?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a session object.
        
        session = AVCaptureSession()
        
        //change preset; trying to get lower quality barcodes
        session.sessionPreset = AVCaptureSessionPresetHigh
        
        // Set the captureDevice.
        
        let videoCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        //change zoom resolution of video
        //videoCaptureDevice?.videoZoomFactor = (videoCaptureDevice?.activeFormat.videoZoomFactorUpscaleThreshold)!;
        
        // Create input object.
        
        let videoInput: AVCaptureDeviceInput?
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        // Add input to the session.
        
        if (session.canAddInput(videoInput)) {
            session.addInput(videoInput)
        } else {
            scanningNotPossible()
        }
        
        // Create output object.
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        // Add output to the session.
        
        if (session.canAddOutput(metadataOutput)) {
            session.addOutput(metadataOutput)
            
            // Send captured data to the delegate object via a serial queue.
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            // Set barcode type for which to scan: EAN-13.
            
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeUPCECode]
            
        } else {
            scanningNotPossible()
        }
        
        // Add previewLayer and have it show the video data.
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session);
        previewLayer.frame = view.layer.bounds;
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        view.layer.addSublayer(previewLayer);
        
        // Begin the capture session.
        
        session.startRunning()
        
        //updateSaveButtonState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (session?.isRunning == false) {
            session.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (session?.isRunning == true) {
            session.stopRunning()
        }
    }
    
    func scanningNotPossible() {
        
        // Let the user know that scanning isn't possible with the current device.
        
        let alert = UIAlertController(title: "Can't Scan.", message: "Let's try a device equipped with a camera.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        session = nil
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        
        // Get the first object from the metadataObjects array.
        
        if let barcodeData = metadataObjects.first {
            
            // Turn it into machine readable code
            
            let barcodeReadable = barcodeData as? AVMetadataMachineReadableCodeObject;
            
            if let readableCode = barcodeReadable {
                
                
                // Send the barcode as a string to barcodeDetected()
                
                barcodeDetected(readableCode.stringValue);
            }
            
            // Vibrate the device to give the user some feedback.
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            
            // Avoid a very buzzy device.
            
            session.stopRunning()
        }
    }
    
    func barcodeDetected(_ code: String) {
        
        // Let the user know we've found something.
        
        let alert = UIAlertController(title: "Found a Barcode!", message: code, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Search", style: UIAlertActionStyle.destructive, handler: { action in
            
            // Remove the spaces.
            
            let trimmedCode = code.trimmingCharacters(in: CharacterSet.whitespaces)
            
            // EAN or UPC?
            // Check for added "0" at beginning of code.
            
            let trimmedCodeString = "\(trimmedCode)"
            var trimmedCodeNoZero: String
            
            if (trimmedCodeString.characters.count==8){
                DataService.searchAPI(codeNumber: trimmedCodeString)
                //DataService.generateBarcode(string: trimmedCodeString)
            }
                
            else if trimmedCodeString.hasPrefix("0") && trimmedCodeString.characters.count > 1 {
                trimmedCodeNoZero = String(trimmedCodeString.characters.dropFirst())
                
                // Send the doctored UPC to DataService.searchAPI()
                
                DataService.searchAPI(codeNumber: trimmedCodeNoZero)
                //DataService.generateBarcode(string: trimmedCodeNoZero)
            } else {
                
                // Send the doctored EAN to DataService.searchAPI()
                
                DataService.searchAPI(codeNumber: trimmedCodeString)
                // DataService.generateBarcode(string: trimmedCodeString)
            }
            
            self.performSegue(withIdentifier: "display2", sender: self)
            
            // self.navigationController?.popViewController(animated: true)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
}
