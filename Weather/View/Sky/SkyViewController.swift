//
//  SkyViewController.swift
//  Weather
//
//  Created by Fedor Artemenkov on 01.04.26.
//

import UIKit
import MetalKit

final class SkyViewController: UIViewController {

    private let mtkView = MTKView()
    private var commandQueue: MTLCommandQueue!
    private var pipelineState: MTLRenderPipelineState!
    
    private var uniforms = SkyUniforms(time: 0, aspect: 1.0, sunHeight: 0.0, cloudy: 0.5)
    private var startTime: TimeInterval = 0
    
    override func loadView() {
        super.loadView()
        view = mtkView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRender()
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
        uniforms.time = Float(currentTime)
        
        renderEncoder.setRenderPipelineState(pipelineState)
        
        var uniformsData = uniforms
        renderEncoder.setFragmentBytes(&uniformsData, length: MemoryLayout<SkyUniforms>.stride, index: 0)
        renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        
        renderEncoder.endEncoding()
        
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}

extension SkyViewController: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        uniforms.aspect = Float(size.width / size.height)
    }
    
    func draw(in view: MTKView) {
        render()
    }
}

private struct SkyUniforms {
    var time: Float
    var aspect: Float
    
    // 0...1, 0 - ночь, 1 - полдень
    var sunHeight: Float
    var cloudy: Float
}
