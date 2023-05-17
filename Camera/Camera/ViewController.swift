import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!
    let captureDevice = AVCaptureDevice.default(for: .video)
    var isFlashOn = false
    var originalPosition: CGRect?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        view.backgroundColor = .black
    }
    
    private lazy var cameraButton: UIButton = {
        let cameraButton = UIButton(type: .system)
        cameraButton.translatesAutoresizingMaskIntoConstraints = false
        cameraButton.setTitle("Câmera", for: .normal)
        cameraButton.addTarget(self, action: #selector(startCamera), for: .touchUpInside)
        return cameraButton
    }()
    
    private lazy var flashOnButton: UIButton = {
        let flashOnButton = UIButton(type: .system)
        flashOnButton.translatesAutoresizingMaskIntoConstraints = false
        flashOnButton.setTitle("Ligar Flash", for: .normal)
        flashOnButton.addTarget(self, action: #selector(turnOnFlash), for: .touchUpInside)
        return flashOnButton
    }()
    
    private lazy var flashOffButton: UIButton = {
        let flashOffButton = UIButton(type: .system)
        flashOffButton.translatesAutoresizingMaskIntoConstraints = false
        flashOffButton.setTitle("Desligar flash", for: .normal)
        flashOffButton.addTarget(self, action: #selector(turnOffFlash), for: .touchUpInside)
        return flashOffButton
    }()
    
    private lazy var returnButton: UIButton = {
        let returnButton = UIButton(type: .system)
        returnButton.translatesAutoresizingMaskIntoConstraints = false
        returnButton.backgroundColor = .white
        returnButton.layer.cornerRadius = 25
        returnButton.addTarget(self, action: #selector(returnToCamera), for: .touchUpInside)
        returnButton.isHidden = true
        return returnButton
    }()
    
    func configureUI(){
        
        view.addSubview(cameraButton)
        cameraButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        cameraButton.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        
        view.addSubview(flashOnButton)
        flashOnButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        flashOnButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        
        view.addSubview(flashOffButton)
        flashOffButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
        flashOffButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        view.addSubview(returnButton)
        returnButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        returnButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        returnButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        returnButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
    }
    
    @objc func startCamera() {
        guard let captureDevice = captureDevice else { return }
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            if let currentVideoInput = captureSession.inputs.first(where: { $0 is AVCaptureDeviceInput }) {
                captureSession.removeInput(currentVideoInput)
            }
            
            captureSession.addInput(input)
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.videoGravity = .resizeAspectFill
            
            let safeAreaInsets = view.safeAreaInsets
            let previewHeight = view.frame.height - safeAreaInsets.top - safeAreaInsets.bottom
            previewLayer.frame = CGRect(x: 0, y: safeAreaInsets.top, width: view.frame.width, height: previewHeight)
            
            view.layer.addSublayer(previewLayer)
            view.addSubview(returnButton)
            captureSession.startRunning()
            
            cameraButton.isHidden = true
            originalPosition = previewLayer.frame
            
            flashOnButton.isHidden = !isFlashOn
            flashOffButton.isHidden = isFlashOn
            
            returnButton.isHidden = false
        } catch {
            print(error)
        }
    }
    
    @objc func turnOnFlash() {
        // Liga o flash
        print("ligar flash")
        guard let device = captureDevice else { return }
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                device.torchMode = .on
                device.unlockForConfiguration()
                isFlashOn = true
            } catch {
                print(error)
            }
        }
    }
    
    @objc func turnOffFlash() {
        // Desliga o flash
        print("desligar flash")
        
        guard let device = captureDevice else { return }
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                device.torchMode = .off
                device.unlockForConfiguration()
                isFlashOn = false
            } catch {
                print(error)
            }
        }
    }
    
    @objc func returnToCamera() {
        captureSession.stopRunning()
        previewLayer.removeFromSuperlayer()
        cameraButton.isHidden = false
        flashOnButton.isHidden = false
        flashOffButton.isHidden = false
        returnButton.isHidden = true
    }
}

