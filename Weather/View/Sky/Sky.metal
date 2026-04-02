//
//  Sky.metal
//  Weather
//
//  Created by Fedor Artemenkov on 01.04.26.
//

#include <metal_stdlib>

#include "Common.h"
#include "Clouds.h"
#include "Stars.h"

using namespace metal;

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct SkyUniforms {
    float2 iResolution;
    float time;
    float sunHeight;
    float cloudiness;
    float raininess;
};

vertex VertexOut skyVertexShader(uint vertexID [[vertex_id]])
{
    float2 pos[6] =
    {
        float2(-1, -1),
        float2( 1, -1),
        float2(-1,  1),
        
        float2(-1,  1),
        float2( 1, -1),
        float2( 1,  1)
    };
    
    VertexOut out;
    out.position = float4(pos[vertexID], 0, 1);
    out.texCoord = pos[vertexID] * 0.5 + 0.5;
    
    return out;
}

fragment float4 skyFragmentShader(VertexOut in [[stage_in]], constant SkyUniforms &uniforms [[buffer(0)]])
{
    float2 uv = in.texCoord * 2.0 - 1.0;
    uv.x *= uniforms.iResolution.x / uniforms.iResolution.y;
    
    float3 viewDir = normalize(float3(uv, 1.0));
    
    float3 sunDir = normalize(float3(0, uniforms.sunHeight, 0.8));
    float dayFactor = smoothstep(-0.1, 0.2, uniforms.sunHeight);
    
    float3 horizonColor = float3(1.0, 0.6, 0.3);
    float3 zenithColor  = float3(0.2, 0.4, 0.9);
    float3 nightColor   = float3(0.02, 0.02, 0.05);
    
    float t = viewDir.y * 0.5 + 0.5;
    float3 daySky = mix(horizonColor, zenithColor, t);
    float3 sky = mix(nightColor, daySky, dayFactor);
    
    float3 ray = rayleigh(viewDir, sunDir);
    sky += ray * dayFactor * 0.5;
    
    {
        float s = stars(uv, uniforms.time);
        float horizonFade = smoothstep(-0.5, 0.5, viewDir.y);
        float3 starColor = float3(1.0);
        float starMask = 1.0 - dayFactor;
        sky += starColor * s * horizonFade * starMask * 5;
    }
    
    {
        float cloud = simpleClouds(uv, uniforms.time);
        float alpha = cloudAlpha(cloud, viewDir.y);
        float3 cloudCol = cloudLighting(cloud, viewDir, sunDir);
        sky = mix(sky, sky + cloudCol, alpha * uniforms.cloudiness);
    }
    
#ifdef RAIN
    {
        const float rain = uniforms.raininess * uniforms.raininess;
        const float angle = 0.57;
        const float intensity = 1.0;
        const float smooth = 0.15;
        const float bright = 0.85;
        
        float2 st = (uv - angle) * float2(0.5 + (uv.y + 0.1) * 0.31, 0.02) + float2(uniforms.time * 0.5 + uv.y * 0.2, uniforms.time * 0.2);
        float f = noise(st * 200.5) * noise(st * 120.5) * intensity;
        f = pow(abs(f), 15.0) * 5.0 * (rain * 125.0);
        f = clamp(f, 0.0, (uv.y + 0.05) * smooth);
        sky = mix(sky, float3(bright), f);
    }
#endif
    
    float fogOffset = 0.7;
    float fogIntensity = 0.8;
    float fog = exp(-max(viewDir.y + fogOffset, 0.0) * 1.2) * fogIntensity;
    float3 fogColor = float3(0.6, 0.8, 0.9);
    sky = mix(sky, fogColor, fog);
    
//    sky = toneMapped(sky, 1);
    sky *= 0.8;
    
    return float4(sky, 1.0);
}
