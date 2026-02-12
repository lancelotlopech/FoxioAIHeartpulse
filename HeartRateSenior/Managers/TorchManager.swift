//
//  TorchManager.swift
//  HeartRateSenior
//
//  独立的手电筒管理器 - 完全独立于相机会话
//  解决手电筒闪烁问题
//

import Foundation
import AVFoundation

/// 独立的手电筒管理器
/// 使用单独的设备引用，不依赖相机会话
class TorchManager {
    
    // MARK: - Singleton
    static let shared = TorchManager()
    
    // MARK: - Properties
    private var torchDevice: AVCaptureDevice?
    private let torchLevel: Float = 0.8
    private var isOn: Bool = false
    
    // MARK: - Initialization
    private init() {
        // 获取后置摄像头设备
        torchDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
    }
    
    // MARK: - Public Methods
    
    /// 开启手电筒
    /// - Returns: 是否成功开启
    @discardableResult
    func turnOn() -> Bool {
        print("🔦 [TorchManager] turnOn() called")
        
        guard let device = torchDevice else {
            print("🔦 [TorchManager] ❌ No device")
            return false
        }
        
        guard device.hasTorch else {
            print("🔦 [TorchManager] ❌ Device has no torch")
            return false
        }
        
        do {
            try device.lockForConfiguration()
            try device.setTorchModeOn(level: torchLevel)
            device.unlockForConfiguration()
            isOn = true
            print("🔦 [TorchManager] ✅ ON at level \(torchLevel)")
            return true
        } catch {
            print("🔦 [TorchManager] ❌ Failed: \(error)")
            return false
        }
    }
    
    /// 关闭手电筒
    func turnOff() {
        print("🔦 [TorchManager] turnOff() called")
        
        guard let device = torchDevice, device.hasTorch else {
            print("🔦 [TorchManager] ❌ No device or torch")
            return
        }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = .off
            device.unlockForConfiguration()
            isOn = false
            print("🔦 [TorchManager] ✅ OFF")
        } catch {
            print("🔦 [TorchManager] ❌ Failed: \(error)")
        }
    }
    
    /// 检查手电筒是否开启
    var isTorchOn: Bool {
        return torchDevice?.torchMode == .on
    }
    
    /// 确保手电筒开启（如果已经开启则不做任何事）
    func ensureOn() {
        guard let device = torchDevice, device.hasTorch else { return }
        
        if device.torchMode != .on {
            print("🔦 [TorchManager] ensureOn() - torch was off, turning on...")
            turnOn()
        }
    }
    
    /// 刷新设备引用（在相机会话启动后调用）
    func refreshDevice() {
        torchDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        print("🔦 [TorchManager] Device refreshed")
    }
}
