//
//  SkyViewController.swift
//  Weather
//
//  Created by Fedor Artemenkov on 01.04.26.
//

import UIKit
import MetalKit

protocol SkyViewProtocol: AnyObject {
    var dayTime: Float { set get }
    var cloudiness: Float { set get }
    var raininess: Float { set get }
    var snowiness: Float { set get }
}

final class SkyViewController: UIViewController, SkyViewProtocol {

    private let mtkView = MTKView()
    private var commandQueue: MTLCommandQueue!
    
    private var skyPipelineState: MTLRenderPipelineState!
    private var rainPipelineState: MTLRenderPipelineState!
    private var snowPipelineState: MTLRenderPipelineState!
    private var cloudsPipelineState: MTLRenderPipelineState!
    
    private var textureLoader: MTKTextureLoader!
    private var noiseTexture: MTLTexture?
    
    private var renderSize: CGSize = .init(width: 1, height: 1)
    private var startTime: TimeInterval = 0
    
    var dayTime: Float = 0.0
    var cloudiness: Float = 0.0
    var raininess: Float = 0.0
    var snowiness: Float = 0.0
    
    override func loadView() {
        super.loadView()
        view = mtkView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRender()
        
        // Секретное меню
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(showSettings))
        tap.minimumPressDuration = 1.0
        
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(tap)
    }
    
    @objc private func showSettings() {
        let vc = SkySettingsViewController(delegate: self)
        
        if let sheet = vc.sheetPresentationController {
            sheet.largestUndimmedDetentIdentifier = .medium
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
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
        
        do {
            let descriptor = MTLRenderPipelineDescriptor()
            descriptor.vertexFunction = vertexFunction
            descriptor.fragmentFunction = library.makeFunction(name: "skyFragmentShader")
            descriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
            descriptor.label = "Base Sky"
            
            skyPipelineState = try device.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            print("Ошибка создания pipeline state: \(error)")
        }
        
        do {
            let descriptor = MTLRenderPipelineDescriptor()
            descriptor.vertexFunction = vertexFunction
            descriptor.fragmentFunction = library.makeFunction(name: "cloudsFragmentShader")
            descriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
            descriptor.colorAttachments[0].isBlendingEnabled = true
            descriptor.label = "Clouds"
            
            descriptor.colorAttachments[0].rgbBlendOperation = .add
            descriptor.colorAttachments[0].alphaBlendOperation = .add
            descriptor.colorAttachments[0].sourceRGBBlendFactor = .one
            descriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
            descriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
            descriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha

            cloudsPipelineState = try device.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            print("Ошибка создания pipeline state: \(error)")
        }
        
        do {
            let descriptor = MTLRenderPipelineDescriptor()
            descriptor.vertexFunction = vertexFunction
            descriptor.fragmentFunction = library.makeFunction(name: "rainFragmentShader")
            descriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
            descriptor.colorAttachments[0].isBlendingEnabled = true
            descriptor.label = "Rain"
            
            descriptor.colorAttachments[0].rgbBlendOperation = .add
            descriptor.colorAttachments[0].alphaBlendOperation = .add
            descriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
            descriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
            descriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
            descriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
            
            rainPipelineState = try device.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            print("Ошибка создания pipeline state: \(error)")
        }
        
        do {
            let descriptor = MTLRenderPipelineDescriptor()
            descriptor.vertexFunction = vertexFunction
            descriptor.fragmentFunction = library.makeFunction(name: "snowFragmentShader")
            descriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
            descriptor.colorAttachments[0].isBlendingEnabled = true
            descriptor.label = "Snow"
            
            descriptor.colorAttachments[0].rgbBlendOperation = .add
            descriptor.colorAttachments[0].alphaBlendOperation = .add
            descriptor.colorAttachments[0].sourceRGBBlendFactor = .sourceAlpha
            descriptor.colorAttachments[0].sourceAlphaBlendFactor = .sourceAlpha
            descriptor.colorAttachments[0].destinationRGBBlendFactor = .oneMinusSourceAlpha
            descriptor.colorAttachments[0].destinationAlphaBlendFactor = .oneMinusSourceAlpha
            
            snowPipelineState = try device.makeRenderPipelineState(descriptor: descriptor)
        } catch {
            print("Ошибка создания pipeline state: \(error)")
        }
        
        noiseTexture = NoiseTextureGenerator.generateWhiteNoise(device: device, width: 64, height: 64, bytesPerPixel: 1)
        
//        do {
//            let options: [MTKTextureLoader.Option: Any] = [
//                .generateMipmaps: true,
//                .SRGB: true
//            ]
//            
//            textureLoader = MTKTextureLoader(device: device)
//            noiseTexture = try textureLoader.newTexture(name: "kek_noise", scaleFactor: 1.0, bundle: nil, options: options)
//        } catch {
//            print("Ошибка загрузки текстуры: \(error)")
//        }
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
            dayTime: dayTime,
            cloudiness: cloudiness,
            raininess: raininess,
            snowiness: Int32(snowiness * 8)
        )
        
        renderEncoder.setFragmentBytes(&uniforms, length: MemoryLayout<SkyUniforms>.stride, index: 0)
        
        do {
            renderEncoder.setRenderPipelineState(skyPipelineState)
            renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        }
        
        if cloudiness > 0 {
            renderEncoder.setRenderPipelineState(cloudsPipelineState)
            renderEncoder.setFragmentTexture(noiseTexture, index: 0)
            renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        }
        
        if raininess > 0 {
            renderEncoder.setRenderPipelineState(rainPipelineState)
            renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        }
        
        if snowiness > 0 {
            renderEncoder.setRenderPipelineState(snowPipelineState)
            renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
        }
        
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
    var dayTime: Float
    var cloudiness: Float
    var raininess: Float
    var snowiness: Int32
}
