import Foundation

// Swift 包装器，提供更友好的接口
class EasyTierWrapper {
    
    // 错误类型
    enum EasyTierError: Error {
        case invalidInstance
        case configurationError(String)
        case networkError(String)
        case unknownError(String)
        
        init(from iosError: IosError?) {
            guard let error = iosError else {
                self = .unknownError("Unknown error")
                return
            }
            
            let message = String(cString: error.message)
            switch error.code {
            case -1:
                self = .invalidInstance
            case -2:
                self = .configurationError(message)
            case -3:
                self = .networkError(message)
            default:
                self = .unknownError(message)
            }
        }
    }
    
    // 网络状态
    enum NetworkStatus: Int {
        case stopped = 0
        case running = 1
        case error = 2
        case unknown = -1
    }
    
    // 网络实例类
    class NetworkInstance {
        private var instance: OpaquePointer?
        
        init?(config: String) throws {
            let cConfig = config.cString(using: .utf8)!
            let result = ios_create_network_instance(cConfig)
            
            if result == nil {
                throw EasyTierError.configurationError("Failed to create network instance")
            }
            
            self.instance = result
        }
        
        deinit {
            if let instance = instance {
                ios_free_network_instance(instance)
            }
        }
        
        func start() throws {
            guard let instance = instance else {
                throw EasyTierError.invalidInstance
            }
            
            let error = ios_start_network_instance(instance)
            if error != nil {
                throw EasyTierError(from: error)
            }
        }
        
        func stop() throws {
            guard let instance = instance else {
                throw EasyTierError.invalidInstance
            }
            
            let error = ios_stop_network_instance(instance)
            if error != nil {
                throw EasyTierError(from: error)
            }
        }
        
        func getStatus() -> NetworkStatus {
            guard let instance = instance else {
                return .unknown
            }
            
            let status = ios_get_network_status(instance)
            return NetworkStatus(rawValue: status) ?? .unknown
        }
        
        func getInfo() throws -> [String: Any] {
            guard let instance = instance else {
                throw EasyTierError.invalidInstance
            }
            
            var infoPtr: UnsafePointer<Int8>?
            let error = ios_get_network_info(instance, &infoPtr)
            
            if error != nil {
                throw EasyTierError(from: error)
            }
            
            guard let infoPtr = infoPtr else {
                throw EasyTierError.unknownError("Failed to get network info")
            }
            
            let infoString = String(cString: infoPtr)
            free_string(infoPtr)
            
            guard let data = infoString.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw EasyTierError.unknownError("Failed to parse network info")
            }
            
            return json
        }
    }
    
    // 配置验证
    static func validateConfig(_ config: String) throws {
        let cConfig = config.cString(using: .utf8)!
        let error = ios_validate_config(cConfig)
        
        if error != nil {
            throw EasyTierError(from: error)
        }
    }
    
    // 创建网络实例
    static func createNetworkInstance(config: String) throws -> NetworkInstance {
        return try NetworkInstance(config: config)!
    }
}

// C 函数声明
private func ios_create_network_instance(_ config: UnsafePointer<Int8>) -> OpaquePointer? {
    // 这里需要通过桥接头文件调用实际的 C 函数
    return nil
}

private func ios_start_network_instance(_ instance: OpaquePointer?) -> UnsafeMutablePointer<IosError>? {
    return nil
}

private func ios_stop_network_instance(_ instance: OpaquePointer?) -> UnsafeMutablePointer<IosError>? {
    return nil
}

private func ios_get_network_status(_ instance: OpaquePointer?) -> Int32 {
    return 0
}

private func ios_free_network_instance(_ instance: OpaquePointer?) {
    // 释放实例
}

private func ios_validate_config(_ config: UnsafePointer<Int8>) -> UnsafeMutablePointer<IosError>? {
    return nil
}

private func ios_get_network_info(_ instance: OpaquePointer?, _ info: UnsafeMutablePointer<UnsafePointer<Int8>?>) -> UnsafeMutablePointer<IosError>? {
    return nil
}

private func free_string(_ str: UnsafePointer<Int8>) {
    // 释放字符串
}

// C 结构体定义
private struct IosError {
    let code: Int32
    let message: UnsafePointer<Int8>
} 