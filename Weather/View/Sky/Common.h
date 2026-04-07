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

float fbm(float2 p)
{
    float value = 0.0;
    float amp = 0.5;
    
    for (int i = 0; i < 3; i++)
    {
        value += noise(p) * amp;
        p *= 2.1;
        amp *= 0.55;
    }
    
    return value;
}

float3 clouds(float3 col, float2 uv, float time, texture2d<half> map);
float stars(float2 uv, float time);
float snowing(float2 uv, float time, int count);

#endif
