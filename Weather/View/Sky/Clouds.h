//
//  Clouds.h
//  Weather
//
//  Created by Fedor Artemenkov on 01.04.26.
//

#pragma once

#include "Common.h"

float clouds(float2 uv, float time)
{
    float2 p = uv * 2.0;
    p += float2(time * 0.1, 0.0);
    float n = fbmCloud(p * 3.0);
    return smoothstep(0.4, 0.7, n);
}

static float cloudShape(float2 uv, float time)
{
    float2 p = uv * 2.0;
    float2 wind = float2(time * 0.2, 0.0);
    
    float2 warp;
    warp.x = fbmCloud(p + wind);
    warp.y = fbmCloud(p + float2(5.2, 1.3) + wind);
    
    p += warp + 1;
    
    float base = fbmCloud(p);
    
    return smoothstep(0.45, 0.75, base);
}

float layeredClouds(float2 uv, float time)
{
    float c1 = cloudShape(uv * 1.0, time);
    float c2 = cloudShape(uv * 1.8 + 10.0, time * 1.2);
    float c3 = cloudShape(uv * 0.6 - 5.0, time * 0.7);
    
    float combined = c1 * 0.6 + c2 * 0.3 + c3 * 0.5;
    
    return smoothstep(0.3, 0.8, combined);
}

float3 cloudLighting(float cloud, float3 viewDir, float3 sunDir)
{
    float mu = dot(viewDir, sunDir);
    
    float light = smoothstep(0.0, 1.0, mu);
    
    float3 warmLight = float3(1.0, 0.85, 0.7);
    float3 coolShadow = float3(0.65, 0.7, 0.8);
    
    float3 base = mix(coolShadow, warmLight, light);
    
    float edge = pow(1.0 - cloud, 6.0) * pow(max(mu, 0.0), 2.0);
    
    base += warmLight * edge * 2.5;
    
    return base * cloud;
}

float cloudAlpha(float cloud, float viewY)
{
    float horizonFade = smoothstep(-0.2, 0.3, viewY);
    return cloud * horizonFade * 0.6;
}
