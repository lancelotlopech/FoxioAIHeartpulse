//
//  CameraPreviewView.swift
//  HeartRateSenior
//
//  Camera preview for heart rate measurement
//  V3.0: 使用全局单例 PreviewLayer，避免 SwiftUI 重建导致系统重置
//

import SwiftUI
import AVFoundation

// MARK: - 全局 PreviewLayer 管理器（单例）
class PreviewLayerManager {
    static let shared = PreviewLayerManager()
    
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var isConnected = false
    
    private init() {}
    
    /// 获取或创建 PreviewLayer
    func getPreviewLayer(for session: AVCaptureSession) -> AVCaptureVideoPreviewLayer {
        if let existing = previewLayer, existing.session === session {
            print("📹 [PREVIEW-MGR] Returning existing layer")
            return existing
        }
        
        // 创建新的 PreviewLayer
        let layer = AVCaptureVideoPreviewLayer(session: session)
        layer.videoGravity = .resizeAspectFill
        self.previewLayer = layer
        self.isConnected = true
        print("📹 [PREVIEW-MGR] ✅ Created new PreviewLayer")
        
        // 通知 HeartRateManager PreviewLayer 已连接
        NotificationCenter.default.post(name: .previewLayerConnected, object: nil)
        
        return layer
    }
    
    /// 检查是否已连接
    var hasConnected: Bool {
        return isConnected && previewLayer?.session != nil
    }
    
    /// 重置（用于测试）
    func reset() {
        previewLayer = nil
        isConnected = false
    }
}

// MARK: - Notification Name
extension Notification.Name {
    static let previewLayerConnected = Notification.Name("previewLayerConnected")
}

// MARK: - Camera Preview View
struct CameraPreviewView: UIViewRepresentable {
    let session: AVCaptureSession?
    
    func makeUIView(context: Context) -> CameraPreviewUIView {
        print("📹 [PREVIEW] makeUIView called")
        let view = CameraPreviewUIView()
        view.backgroundColor = .black
        
        // 使用全局 PreviewLayer 管理器
        if let session = session {
            let layer = PreviewLayerManager.shared.getPreviewLayer(for: session)
            view.setPreviewLayer(layer)
        }
        return view
    }
    
    func updateUIView(_ uiView: CameraPreviewUIView, context: Context) {
        // 使用全局管理器，不需要在 updateUIView 中做任何事
        // PreviewLayer 已经在 makeUIView 中设置
    }
}

// MARK: - UIKit Camera Preview
class CameraPreviewUIView: UIView {
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    /// 设置 PreviewLayer（从全局管理器获取）
    func setPreviewLayer(_ layer: AVCaptureVideoPreviewLayer) {
        // 移除旧的 layer
        previewLayer?.removeFromSuperlayer()
        
        // 添加新的 layer
        layer.frame = bounds
        self.layer.addSublayer(layer)
        self.previewLayer = layer
        print("📹 [PREVIEW-VIEW] ✅ PreviewLayer added to view")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }
}
