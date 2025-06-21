import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var configTextView: UITextView!
    
    private var networkInstance: EasyTierWrapper.NetworkInstance?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadDefaultConfig()
    }
    
    private func setupUI() {
        statusLabel.text = "状态: 未启动"
        startButton.setTitle("启动", for: .normal)
        stopButton.setTitle("停止", for: .normal)
        stopButton.isEnabled = false
        
        // 设置按钮样式
        startButton.backgroundColor = .systemGreen
        startButton.setTitleColor(.white, for: .normal)
        startButton.layer.cornerRadius = 8
        
        stopButton.backgroundColor = .systemRed
        stopButton.setTitleColor(.white, for: .normal)
        stopButton.layer.cornerRadius = 8
    }
    
    private func loadDefaultConfig() {
        let defaultConfig = """
        inst_name = "ios_app"
        network = "test_network"
        
        [peers]
        # 在这里添加对等节点配置
        
        [tunnels]
        # 在这里添加隧道配置
        """
        
        configTextView.text = defaultConfig
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        startNetwork()
    }
    
    @IBAction func stopButtonTapped(_ sender: UIButton) {
        stopNetwork()
    }
    
    private func startNetwork() {
        guard let config = configTextView.text, !config.isEmpty else {
            showAlert(title: "错误", message: "请先输入配置")
            return
        }
        
        do {
            // 验证配置
            try EasyTierWrapper.validateConfig(config)
            
            // 创建网络实例
            networkInstance = try EasyTierWrapper.createNetworkInstance(config: config)
            
            // 启动网络
            try networkInstance?.start()
            
            // 更新 UI
            updateStatus(.running)
            showAlert(title: "成功", message: "网络已启动")
            
        } catch EasyTierWrapper.EasyTierError.configurationError(let message) {
            showAlert(title: "配置错误", message: message)
        } catch EasyTierWrapper.EasyTierError.networkError(let message) {
            showAlert(title: "网络错误", message: message)
        } catch {
            showAlert(title: "错误", message: error.localizedDescription)
        }
    }
    
    private func stopNetwork() {
        do {
            try networkInstance?.stop()
            networkInstance = nil
            updateStatus(.stopped)
            showAlert(title: "成功", message: "网络已停止")
        } catch {
            showAlert(title: "错误", message: "停止网络时发生错误: \(error.localizedDescription)")
        }
    }
    
    private func updateStatus(_ status: EasyTierWrapper.NetworkStatus) {
        DispatchQueue.main.async {
            switch status {
            case .running:
                self.statusLabel.text = "状态: 运行中"
                self.statusLabel.textColor = .systemGreen
                self.startButton.isEnabled = false
                self.stopButton.isEnabled = true
            case .stopped:
                self.statusLabel.text = "状态: 已停止"
                self.statusLabel.textColor = .systemGray
                self.startButton.isEnabled = true
                self.stopButton.isEnabled = false
            case .error:
                self.statusLabel.text = "状态: 错误"
                self.statusLabel.textColor = .systemRed
                self.startButton.isEnabled = true
                self.stopButton.isEnabled = false
            case .unknown:
                self.statusLabel.text = "状态: 未知"
                self.statusLabel.textColor = .systemOrange
                self.startButton.isEnabled = true
                self.stopButton.isEnabled = false
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "确定", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    // 定期检查网络状态
    private func startStatusMonitoring() {
        Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            if let instance = self.networkInstance {
                let status = instance.getStatus()
                self.updateStatus(status)
            }
        }
    }
} 