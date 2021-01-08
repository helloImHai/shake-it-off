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

    @IBOutlet var nameTextView: UITextView!
    @IBOutlet var groupIDTextView: UITextView!

    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var groupIDTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialise
        readyMessage()
        count = 0
        setupAccelerometer()

        nameTextField.delegate = self
        groupIDTextField.delegate = self

        nameTextView.text = "Please input your name below"
        groupIDTextView.text = "Please input your Group ID below"
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
            if getMagnitude(x, y, z) > 10 {
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

    @IBAction func onUpdateButtonClicked(_ sender: Any) {
        let ac = UIAlertController(title: title, message: "Confirm update?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Yes!", style: .default, handler: updateFields))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }

    func updateFields(action: UIAlertAction) {
        guard let name = nameTextField.text else { return }
        guard let groupID = groupIDTextField.text else { return }

        if name == "" || groupID == "" {
            let ac = UIAlertController(title: title, message: "Both fields must be filled up!", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Dismiss", style: .default))
            present(ac, animated: true)
            return
        }

        nameTextView.text = "Hello, \(name)!"
        groupIDTextView.text = "Your current group ID is: \(groupID)"
    }

    func sendPostRequest(action: UIAlertAction!) {
        let host = "api.telegram.org"
        let token = "1582533456:AAFswg2spaHuwD0x6O3pG3ajSx4wjBuQL4s"

        guard var urlComponents = URLComponents(string: "https://\(host)/bot\(token)/sendMessage") else {
            print("Error cannot URL")
            return
        }

        let queryItems = [URLQueryItem(name: "text", value: "Christian, stop shaking your legs"),
                          URLQueryItem(name: "chat_id", value: "-384824098")]
        urlComponents.queryItems = queryItems

        urlComponents.percentEncodedQuery = urlComponents.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        var request = URLRequest(url: urlComponents.url!)

        request.httpMethod = "POST"

        URLSession.shared.dataTask(with: request) 

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else { // check for fundamental networking error
                print("error", error ?? "Unknown error")
                return
            }

            guard (200 ... 299) ~= response.statusCode else { // check for http errors
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }

            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(String(describing: responseString))")
        }

        task.resume()

        print("After task.resume()")
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

