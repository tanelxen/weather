//
//  NoiseTextureGenerator.swift
//  Weather
//
//  Created by Fedor Artemenkov on 03.04.26.
//


import Metal
import MetalKit

class NoiseTextureGenerator {
    
    static func generateWhiteNoise(device: MTLDevice, width: Int, height: Int, bytesPerPixel: Int) -> MTLTexture? {

        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .r8Unorm,
            width: width,
            height: height,
            mipmapped: true
        )
        textureDescriptor.usage = [.shaderRead]
        
        guard let texture = device.makeTexture(descriptor: textureDescriptor) else {
            return nil
        }
        
        let bytesPerRow = width * bytesPerPixel
        var noiseData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        
        for y in 0..<height {
            
            for x in 0..<width {
                
                let index = (y * width + x) * bytesPerPixel
                
                for i in 0..<bytesPerPixel {
                    noiseData[index + i] = UInt8.random(in: 0...255)
                }
            }
        }
        
        let region = MTLRegionMake2D(0, 0, width, height)
        texture.replace(region: region,
                       mipmapLevel: 0,
                       withBytes: noiseData,
                       bytesPerRow: bytesPerRow)
        
        let commandQueue = device.makeCommandQueue()
        let commandBuffer = commandQueue?.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeBlitCommandEncoder()
        
        commandEncoder?.generateMipmaps(for: texture)
        commandEncoder?.endEncoding()
        commandBuffer?.commit()
        
        return texture
    }
}
