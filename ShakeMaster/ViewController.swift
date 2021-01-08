import UIKit
import CoreMotion


class ViewController: UIViewController {
    var count: Int!
    let motionManager = CMMotionManager()
    let timeInterval = 0.1
    var timer: Timer!
    
    var x: Double?
    var y: Double?
    var z: Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialise
        readyMessage()
        count = 0
        setupAccelerometer()
    }
    
    func setupAccelerometer() {
        print("setting up accelerometer")
        motionManager.startAccelerometerUpdates()
        motionManager.startGyroUpdates()
        motionManager.startMagnetometerUpdates()
        motionManager.startDeviceMotionUpdates()
        
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    func readyMessage() {
        print("Ready")
    }
    
    @objc
    func update() {
        if let accelerometerData = motionManager.accelerometerData {
            let x = accelerometerData.acceleration.x
            let y = accelerometerData.acceleration.y
            let z = accelerometerData.acceleration.z
            if (getMagnitude(x, y, z) > 1) {
                count += 1
                print("shaking \(count!)")
            }
            setXYZ(x, y, z)
        } else {
            print("no data")
        }
    }
    
    func setXYZ(_ x: Double, _ y: Double, _ z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    func getMagnitude(_ x: Double, _ y: Double, _ z: Double) -> Double {
        guard let prevX = self.x else {
            return 0
        }
        guard let prevY = self.y else {
            return 0
        }
        guard let prevZ = self.z else {
            return 0
        }
        let dx = x - prevX
        let dy = y - prevY
        let dz = z - prevZ
        return (dx * dx + dy * dy + dz * dz) / timeInterval
    }

}

