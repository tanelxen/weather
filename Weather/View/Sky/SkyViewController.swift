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
    var raininess: Float { set get }
    var snowiness: Float { set get }
}

final class SkyViewController: UIViewController, SkyViewProtocol {

    private let mtkView = MTKView()
    private var commandQueue: MTLCommandQueue!
    private var pipelineState: MTLRenderPipelineState!
    
    private var textureLoader: MTKTextureLoader!
    private var noiseTexture: MTLTexture?
    
    private var renderSize: CGSize = .init(width: 1, height: 1)
    private var startTime: TimeInterval = 0
    
    var sunHeight: Float = 0.0
    var cloudiness: Float = 1.0
    var raininess: Float = 0.5
    var snowiness: Float = 0.0
    
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
        mtkView.preferredFramesPerSecond = 30
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
        
//        mtkView.colorPixelFormat = .rgba8Unorm
        
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
        
        noiseTexture = NoiseTextureGenerator.generateWhiteNoise(device: device, width: 64, height: 64, bytesPerPixel: 1)
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
            iResolution: .init(Float(renderSize.width), Float(renderSize.height)),
            time: Float(currentTime),
            sunHeight: sunHeight,
            cloudiness: cloudiness,
            raininess: raininess
        )
        
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setFragmentBytes(&uniforms, length: MemoryLayout<SkyUniforms>.stride, index: 0)
        renderEncoder.setFragmentTexture(noiseTexture, index: 0)
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
    var iResolution: SIMD2<Float>
    var time: Float
    var sunHeight: Float
    var cloudiness: Float
    var raininess: Float
}
