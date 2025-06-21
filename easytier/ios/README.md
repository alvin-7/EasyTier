# EasyTier iOS 集成指南

本指南将帮助你将 EasyTier 的 core 功能集成到 iOS 应用中。

## 📋 前置要求

- **Rust 工具链**: 安装 Rust 和 Cargo
- **Xcode**: 最新版本的 Xcode
- **iOS 开发环境**: 配置好的 iOS 开发环境
- **Apple Developer Account**: 用于代码签名和部署

## 🚀 快速开始

### 1. 构建 Rust 库

```bash
# 进入 iOS 目录
cd easytier/ios

# 运行构建脚本
chmod +x build_ios.sh
./build_ios.sh
```

### 2. 在 Xcode 中集成

1. **打开 Xcode 项目**
   ```bash
   open EasyTierApp/EasyTierApp.xcodeproj
   ```

2. **添加库文件**
   - 将 `EasyTierApp/Frameworks/libeasytier_ffi.a` 拖拽到 Xcode 项目中
   - 将 `EasyTierApp/Frameworks/easytier_ffi.h` 拖拽到 Xcode 项目中

3. **配置项目设置**
   - 在 Build Settings 中设置 Library Search Paths: `$(PROJECT_DIR)/Frameworks`
   - 在 Build Settings 中设置 Header Search Paths: `$(PROJECT_DIR)/Frameworks`

4. **链接库**
   - 在 Build Phases 的 Link Binary With Libraries 中添加 `libeasytier_ffi.a`

### 3. 使用 Swift 包装器

```swift
import Foundation

// 创建网络实例
let config = """
inst_name = "ios_app"
network = "test_network"

[peers]
# 对等节点配置

[tunnels]
# 隧道配置
"""

do {
    // 验证配置
    try EasyTierWrapper.validateConfig(config)
    
    // 创建并启动网络实例
    let instance = try EasyTierWrapper.createNetworkInstance(config: config)
    try instance.start()
    
    // 检查状态
    let status = instance.getStatus()
    print("网络状态: \(status)")
    
    // 获取网络信息
    let info = try instance.getInfo()
    print("网络信息: \(info)")
    
} catch {
    print("错误: \(error)")
}
```

## 📁 项目结构

```
easytier/ios/
├── EasyTierApp/
│   ├── EasyTierApp.xcodeproj/     # Xcode 项目文件
│   ├── EasyTierApp/
│   │   ├── ViewController.swift   # 示例视图控制器
│   │   ├── EasyTierWrapper.swift  # Swift 包装器
│   │   └── easytier_ffi.h        # C 头文件
│   └── Frameworks/
│       ├── libeasytier_ffi.a     # 静态库
│       └── easytier_ffi.h        # 头文件
├── build_ios.sh                   # 构建脚本
└── README.md                      # 本文档
```

## 🔧 配置选项

### 基本配置

```toml
inst_name = "ios_app"
network = "your_network_name"

[peers]
# 对等节点配置

[tunnels]
# 隧道配置
```

### 高级配置

```toml
inst_name = "ios_app"
network = "your_network_name"

[peers]
# 添加对等节点
peer1 = { url = "tcp://192.168.1.100:11010" }
peer2 = { url = "udp://example.com:11010" }

[tunnels]
# 配置隧道
tunnel1 = { 
    protocol = "wireguard"
    local_port = 51820
    remote_port = 51820
}

[features]
# 启用特定功能
wireguard = true
quic = false
websocket = true
```

## 🛠️ API 参考

### EasyTierWrapper

#### 类方法

- `validateConfig(_ config: String) throws` - 验证配置
- `createNetworkInstance(config: String) throws -> NetworkInstance` - 创建网络实例

#### NetworkInstance

- `start() throws` - 启动网络
- `stop() throws` - 停止网络
- `getStatus() -> NetworkStatus` - 获取状态
- `getInfo() throws -> [String: Any]` - 获取网络信息

#### NetworkStatus

- `.stopped` - 已停止
- `.running` - 运行中
- `.error` - 错误状态
- `.unknown` - 未知状态

#### EasyTierError

- `.invalidInstance` - 无效实例
- `.configurationError(String)` - 配置错误
- `.networkError(String)` - 网络错误
- `.unknownError(String)` - 未知错误

## 🔍 调试和故障排除

### 常见问题

1. **链接错误**
   - 确保库文件路径正确
   - 检查架构匹配 (arm64)

2. **运行时错误**
   - 检查配置格式
   - 验证网络权限

3. **权限问题**
   - 确保应用有网络访问权限
   - 检查 VPN 配置权限

### 调试技巧

```swift
// 启用详细日志
#if DEBUG
print("调试信息: \(debugInfo)")
#endif

// 错误处理
do {
    try someOperation()
} catch EasyTierWrapper.EasyTierError.configurationError(let message) {
    print("配置错误: \(message)")
} catch {
    print("其他错误: \(error)")
}
```

## 📱 部署注意事项

1. **代码签名**: 确保使用正确的开发者证书
2. **权限配置**: 在 Info.plist 中添加必要的权限
3. **网络配置**: 配置 App Transport Security 设置
4. **VPN 权限**: 如果使用 VPN 功能，需要特殊权限

## 🤝 贡献

欢迎提交 Issue 和 Pull Request 来改进 iOS 集成。

## 📄 许可证

本项目遵循 EasyTier 的许可证条款。 