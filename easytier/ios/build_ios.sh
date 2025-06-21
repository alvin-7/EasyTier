#!/bin/bash

# EasyTier iOS 构建脚本
set -e

# 配置
RUST_TARGET="aarch64-apple-ios"
FFI_DIR="../easytier-contrib/easytier-ffi"
OUTPUT_DIR="EasyTierApp/Frameworks"

echo "🚀 开始构建 EasyTier iOS 库..."

# 检查 Rust 工具链
if ! command -v cargo &> /dev/null; then
    echo "❌ 错误: 未找到 cargo，请先安装 Rust"
    exit 1
fi

# 添加 iOS 目标
echo "📱 添加 iOS 目标..."
rustup target add $RUST_TARGET

# 构建 FFI 库
echo "🔨 构建 FFI 库..."
cd $FFI_DIR

# 清理之前的构建
cargo clean

# 构建静态库
echo "📦 构建静态库..."
cargo build --target $RUST_TARGET --release --lib

# 创建输出目录
mkdir -p ../../ios/$OUTPUT_DIR

# 复制库文件
echo "📋 复制库文件..."
cp target/$RUST_TARGET/release/libeasytier_ffi.a ../../ios/$OUTPUT_DIR/

# 复制头文件
echo "📋 复制头文件..."
cp ../../ios/EasyTierApp/easytier_ffi.h ../../ios/$OUTPUT_DIR/

echo "✅ 构建完成！"
echo "📁 输出文件位置: ios/$OUTPUT_DIR/"

# 显示文件信息
echo "📊 构建信息:"
ls -la ../../ios/$OUTPUT_DIR/

echo ""
echo "🎉 EasyTier iOS 库构建成功！"
echo "💡 现在可以在 Xcode 项目中链接 libeasytier_ffi.a 库" 
