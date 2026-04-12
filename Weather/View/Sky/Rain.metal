//
//  Rain.metal
//  Weather
//
//  Created by Fedor Artemenkov on 10.04.26.
//

#include "Common.h"

static float hash(float2 p)
{
    return fract(sin(dot(p, float2(127.1, 311.7))) * 43758.5453);
}

static float noise(float2 p)
{
    float2 i = floor(p);
    float2 f = fract(p);
    
    float a = hash(i);
    float b = hash(i + float2(1, 0));
    float c = hash(i + float2(0, 1));
    float d = hash(i + float2(1, 1));
    
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float rain(float2 uv, float time, float raininess)
{
    const float smooth = 0.4;
    
    float2 st = uv * float2(5.5, 0.1) + float2(0.0, time * 0.2);
    
    float f = noise(st * 200.5) * noise(st * 180.5);
    f = pow(abs(f), 15.0) * 625.0 * pow(raininess, 2);
    
//    float f = noise(st * 50.0);
//    f = smoothstep((1.0 - raininess * 0.2), 1.0, f) * 0.5;
    
    f = clamp(f, 0.0, (1.0 - uv.y) * smooth);
    f += uv.y * raininess * 0.05;
    
    return f;
}

fragment float4 rainFragmentShader
(
 VertexOut in [[stage_in]],
 constant SkyUniforms &uniforms [[ buffer(0) ]]
)
{
    float2 uv = in.texCoord;
    uv.x *= uniforms.iResolution.x / uniforms.iResolution.y;
    
    float value = rain(uv, uniforms.time, uniforms.raininess);
    
    return float4(1, 1, 1, value);
}
