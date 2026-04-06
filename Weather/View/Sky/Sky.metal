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

#define RAIN 1

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

constexpr sampler sampler2d(min_filter::linear, mag_filter::linear, address::repeat);

static float noise(float2 p, texture2d<half> noiseMap)
{
    half4 tex = noiseMap.sample(sampler2d, p/32.0);
    return tex.r;
}

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


float3 skyGradient(float y, float timeOfDay)
{
    float3 dayTop = float3(0.2, 0.4, 0.8);
    float3 dayBottom = float3(0.6, 0.8, 1.0);
    
    float3 nightTop = float3(10.0/255, 8.0/255, 32.0/255);
    float3 nightBottom = float3(40.0/255, 60.0/255, 100.0/255);
    
    float t = smoothstep(0.0, 1.0, sin(timeOfDay));
    
    float3 top = mix(nightTop, dayTop, t);
    float3 bottom = mix(nightBottom, dayBottom, t);
    
    return mix(bottom, top, y);
}

fragment float4 skyFragmentShader
(
    VertexOut in [[stage_in]],
    constant SkyUniforms &uniforms [[ buffer(0) ]],
    texture2d<half> noiseMap [[ texture(0) ]]
)
{
    float2 uv = in.texCoord * 2.0 - 1.0;
    uv.x *= uniforms.iResolution.x / uniforms.iResolution.y;
    
    float3 viewDir = normalize(float3(uv, 1.0));

    
    float3 sky = skyGradient(viewDir.y * 0.5 + 0.5, uniforms.sunHeight);
    
    {
        float s = stars(uv, uniforms.time);
        float horizonFade = smoothstep(-0.5, 0.5, viewDir.y);
        float3 starColor = float3(1.0);
        float dayFactor = smoothstep(-0.1, 0.2, uniforms.sunHeight);
        float starMask = 1.0 - dayFactor;
        sky += starColor * s * horizonFade * starMask * 5;
    }
    
    if (uniforms.sunHeight <= 0)
    {
        float2 sundir = float2(0.25, 0.65);
        float2 moonPos = uv - sundir;
        
        float glow = 0.95 * exp(-length(moonPos) * 6.0);
        sky += glow;
        
        float moon = smoothstep(0.09, 0.08, length(moonPos));
        float col = 0.5 + fbm(16.0 * moonPos + 1.2);
        sky = mix(sky, float3(col), moon);
        sky = saturate(sky);
    }
    
    {
        float3 color = clouds(sky, uv, uniforms.time, noiseMap);
        half horizonFade = smoothstep(-0.2, 0.3, viewDir.y);
        sky = mix(sky, color, uniforms.cloudiness * horizonFade);
    }
    
#if RAIN
    {
        const float rain = uniforms.raininess * uniforms.raininess;
        const float angle = 0.57;
        const float intensity = 1.1;
        const float smooth = 0.15;
        const float bright = 0.8;
        
        float2 st = (uv - angle) * float2(0.5 + (uv.y + 0.1) * 0.31, 0.02) + float2(uniforms.time * 0.5 + uv.y * 0.2, uniforms.time * 0.2);
        float f = noise(st * 200.5) * noise(st * 120.5) * intensity;
        f = pow(abs(f), 15.0) * 625.0 * rain;
        f = clamp(f, 0.0, uv.y * smooth);
        sky = mix(sky, float3(bright), f);
    }
#endif
    
//    float fogOffset = 0.7;
//    float fogIntensity = 0.8;
//    float fog = exp(-max(viewDir.y + fogOffset, 0.0) * 1.2) * fogIntensity;
//    float3 fogColor = float3(0.6, 0.8, 0.9);
//    sky = mix(sky, fogColor, fog);
    
//    sky = toneMapped(sky, 1);
//    sky *= 0.8;
    
//    half4 tex = noiseMap.sample(sampler2d, uv);
//    sky = float3(tex.rgb);
    
    return float4(sky, 1.0);
}
