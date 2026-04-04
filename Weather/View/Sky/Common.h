//
//  Common.metal
//  Weather
//
//  Created by Fedor Artemenkov on 01.04.26.
//

#ifndef COMMON_H
#define COMMON_H

#include <metal_stdlib>
using namespace metal;

float hash(float2 p)
{
    return fract(sin(dot(p, float2(127.1, 311.7))) * 43758.5453);
}

float noise(float2 p)
{
    float2 i = floor(p);
    float2 f = fract(p);
    
    float a = hash(i);
    float b = hash(i + float2(1, 0));
    float c = hash(i + float2(0, 1));
    float d = hash(i + float2(1, 1));
    
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

//float fbmCloud(float2 p)
//{
//    float value = 0.0;
//    float amp = 0.5;
//    
//    for (int i = 0; i < 8; i++)
//    {
//        value += noise(p) * amp;
//        p *= 2.0;
//        amp *= 0.5;
//    }
//    
//    return value;
//}
//
//float3 rayleigh(float3 viewDir, float3 sunDir)
//{
//    float mu = dot(viewDir, sunDir);
//    float r = 0.5 + 0.5 * mu;
//    
//    float3 sky = float3(0.3, 0.5, 1.0) * (0.5 + 0.5 * r);
//    return sky;
//}

float3 toneMapped(float3 color, float exposure)
{
    color *= exposure;
    return color / (color + float3(1.0));
}

#endif
