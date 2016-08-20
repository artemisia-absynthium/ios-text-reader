//
//  ViewController.swift
//  TextReader
//
//  Created by Cristina De Rito on 18/08/16.
//  Copyright © 2016 Cristina De Rito. All rights reserved.
//

import UIKit
import AVFoundation
import TesseractOCR

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, G8TesseractDelegate {
    @IBOutlet var cameraPreview: UIView!
    @IBOutlet var recognizedText: UITextView!
    
    let tesseract = G8Tesseract(language: "eng+ita")
    var recognizing = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraPreview.contentMode = UIViewContentMode.scaleAspectFit
        
        tesseract?.delegate = self
        tesseract?.charWhitelist = "ABCDEFGHILMNOPQRSTUVXZabcdefghilmnopqrstuvxzìèéòàù',.?"
        tesseract?.pageSegmentationMode = .auto
        
        setupCaptureSession()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Tesseract
    
    func performRecognition(_ image: UIImage) -> String {
        tesseract?.image = image
        print("performRecognition - recognition start...")
        tesseract?.recognize()
        print("performRecognition - recognition complete")
        let text = tesseract?.recognizedText
        print("text='" + (text == nil ? "nil" : text!) + "'")
        return text!
    }
    
    func shouldCancelImageRecognition(for tesseract: G8Tesseract!) -> Bool {
        return false; // return true if you need to interrupt tesseract before it finishes
    }

    // MARK: Technical Q&A QA1702
    // How to capture video frames from the camera as images using AV Foundation on iOS
    // Original: https://developer.apple.com/library/ios/qa/qa1702/_index.html
    // Swift: https://gist.github.com/thatseeyou/caa8db15f39963dc1060
    
    func setupCaptureSession() {
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        do {
            let device = AVCaptureDevice .defaultDevice(withMediaType: AVMediaTypeVideo)
            let input = try AVCaptureDeviceInput(device: device)
            captureSession.addInput(input)
        } catch {
            print("Can't access camera")
            return
        }
        
        // To display camera preview
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        let viewLayer = cameraPreview.layer
        viewLayer.masksToBounds = true
        previewLayer?.frame = cameraPreview.bounds
        viewLayer.addSublayer(previewLayer!)
        
        let output = AVCaptureVideoDataOutput()
        if captureSession.canAddOutput(output) {
            captureSession.addOutput(output)
        }
        let connection = output.connection(withMediaType: AVMediaTypeVideo)
        if (connection?.isVideoOrientationSupported)! {
            connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        }
        let queue = DispatchQueue(label: "MyQueue", attributes: [])
        output.setSampleBufferDelegate(self, queue: queue)
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable : UInt(kCVPixelFormatType_32BGRA)]
        
        captureSession.startRunning()
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) {
        if recognizing {
            return
        }
        recognizing = true
        print("Extract image from capture buffer")
        let image = self.imageFromSampleBuffer(sampleBuffer)
        print("Trying to recognize image")
        let text = self.performRecognition(image)
        print("Recognition complete")
        DispatchQueue.main.async(execute: {
            self.recognizedText.text = text
        })
        recognizing = false
    }
    
    func imageFromSampleBuffer(_ sampleBuffer: CMSampleBuffer!) -> UIImage {
        let imageBuffer:CVImageBuffer! = CMSampleBufferGetImageBuffer(sampleBuffer)
        
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
        
        let baseAddress: UnsafeMutableRawPointer = CVPixelBufferGetBaseAddress(imageBuffer)!
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        // Create a bitmap graphics context with the sample buffer data
        let context = CGContext(data: baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
        let quartzImage = context?.makeImage()
        
        CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
        
        // Create an image object from the Quartz image
        let image = UIImage(cgImage: quartzImage!)
        
        return (image);
    }
}

