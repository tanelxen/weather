//
//  Common.metal
//  Weather
//
//  Created by Fedor Artemenkov on 01.04.26.
//

#pragma once

#include <metal_stdlib>
using namespace metal;

float hash(float2 p)
{
    p = fract(p * float2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float noise(float2 p)
{
    float2 i = floor(p);
    float2 f = fract(p);
    
    float a = hash(i);
    float b = hash(i + float2(1.0, 0.0));
    float c = hash(i + float2(0.0, 1.0));
    float d = hash(i + float2(1.0, 1.0));
    
    float2 u = f * f * (3.0 - 2.0 * f);
    
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float fbmCloud(float2 p)
{
    float value = 0.0;
    float amp = 0.5;
    
    for (int i = 0; i < 8; i++)
    {
        value += noise(p) * amp;
        p *= 2.0;
        amp *= 0.5;
    }
    
    return value;
}

float3 rayleigh(float3 viewDir, float3 sunDir)
{
    float mu = dot(viewDir, sunDir);
    float r = 0.5 + 0.5 * mu;
    
    float3 sky = float3(0.3, 0.5, 1.0) * (0.5 + 0.5 * r);
    return sky;
}

float3 toneMapped(float3 color, float exposure)
{
    color *= exposure;
    return color / (color + float3(1.0));
}
