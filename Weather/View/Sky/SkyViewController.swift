//
//  SkyViewController.swift
//  Weather
//
//  Created by Fedor Artemenkov on 01.04.26.
//

import UIKit
import MetalKit

protocol SkyViewProtocol: AnyObject {
    var sunHeight: Float { set get }
    var cloudiness: Float { set get }
}

final class SkyViewController: UIViewController, SkyViewProtocol {

    private let mtkView = MTKView()
    private var commandQueue: MTLCommandQueue!
    private var pipelineState: MTLRenderPipelineState!
    
    private var renderSize: CGSize = .init(width: 1, height: 1)
    private var startTime: TimeInterval = 0
    
    private let settingsButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "gearshape.fill")
        button.tintColor = .white.withAlphaComponent(0.5)
        button.configuration = config
        return button
    }()
    
    var sunHeight: Float = 0.0
    var cloudiness: Float = 0.0
    
    override func loadView() {
        super.loadView()
        view = mtkView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRender()
        
        view.addSubview(settingsButton)
        settingsButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(22)
            $0.trailing.equalToSuperview().inset(16)
            $0.size.equalTo(32)
        }
        
        settingsButton.addTarget(self, action: #selector(showSettings), for: .touchUpInside)
    }
    
    @objc private func showSettings() {
        let vc = SkySettingsViewController(delegate: self)
        
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
            sheet.largestUndimmedDetentIdentifier = .medium
        }
        
        present(vc, animated: true)
    }
    
    private func setupRender() {

        mtkView.device = MTLCreateSystemDefaultDevice()
        mtkView.clearColor = MTLClearColor(red: 0, green: 0, blue: 0, alpha: 1)
        mtkView.preferredFramesPerSecond = 60
        mtkView.enableSetNeedsDisplay = false
        mtkView.framebufferOnly = false
        mtkView.delegate = self
        
        commandQueue = mtkView.device!.makeCommandQueue()
        setupPipeline(device: mtkView.device!)
        
        startTime = CACurrentMediaTime()
    }
    
    private func setupPipeline(device: MTLDevice) {
        guard let library = device.makeDefaultLibrary() else {
            print("Не удалось создать Metal library")
            return
        }
        
        let vertexFunction = library.makeFunction(name: "skyVertexShader")
        let fragmentFunction = library.makeFunction(name: "skyFragmentShader")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            print("Ошибка создания pipeline state: \(error)")
        }
    }
    
    private func render() {
        guard let drawable = mtkView.currentDrawable,
              let renderPassDescriptor = mtkView.currentRenderPassDescriptor,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        else {
            return
        }
        
        
        let currentTime = CACurrentMediaTime() - startTime
        
        var uniforms = SkyUniforms(
            time: Float(currentTime),
            aspect: 1,
            sunHeight: sunHeight,
            cloudiness: cloudiness
        )
        
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setFragmentBytes(&uniforms, length: MemoryLayout<SkyUniforms>.stride, index: 0)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

extension SkyViewController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        renderSize = size
    }
    
    func draw(in view: MTKView) {
        render()
    }
}

private struct SkyUniforms {
    var time: Float
    var aspect: Float
    var sunHeight: Float
    var cloudiness: Float
}
