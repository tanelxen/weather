//
//  Clouds.metal
//  Weather
//
//  Created by Fedor Artemenkov on 04.04.26.
//

#include <metal_stdlib>
using namespace metal;

float cloudAlpha(float cloud, float viewY)
{
    float horizonFade = smoothstep(-0.2, 0.3, viewY);
    return cloud * horizonFade * 0.6;
}

constexpr sampler sampler2d(min_filter::linear, mag_filter::linear, address::repeat);

static float noise(float2 p, texture2d<half> noiseMap)
{
    return noiseMap.sample(sampler2d, p/64.0).r;
}

static float fbm(float2 p, texture2d<half> map)
{
    float s = 0.0;
    float a = 0.5;
    
    for(int i = 0; i < 5; i++)
    {
        s += a * noise(p, map);
        p *= 2.0;
        a *= 0.5;
    }
    
    return s;
}

static float2 flow(float2 p, float t, texture2d<half> map)
{
    float e = 0.1;
    float n1 = fbm(p * 1.6 + float2(0.0, t * 0.1), map);
    float n2 = fbm(p * 2.6 + float2(t * 0.1, 0.0), map);
    return float2(n1 - fbm(p + float2(e, 0.0), map), n2 - fbm(p + float2(0.0, e), map));
}

static float cloudDensity(float2 uv, float scale, float t, float coverage, float softness, texture2d<half> map)
{
    // wind direction and speed
    float2 wind = float2(0.25, 0.0);
    float2 p = uv * scale + wind * t;
    
    // Flow warp for billowy motion
    // сильно бьет по производительности
//    float2 w = flow(p * 0.35, t, map) * 0.8;
//    p += w;
    
    float n = fbm(p, map);
    
    // Accentuate billows
    n = smoothstep(coverage, coverage + softness, n);
    return n;
}

static float2 densityGrad(float2 p, float s, float t, texture2d<half> map)
{
    float e = 1.5/s; // scale-aware step
//    float c = cloudDensity(p, s, t, 0.5, 0.2, map);
    float c = 0.0;// fbm(p, map)
    float cx = cloudDensity(p + float2(e,0.0), s, t, 0.5, 0.2, map) - c;
    float cy = cloudDensity(p + float2(0.0,e), s, t, 0.5, 0.2, map) - c;
    return float2(cx, cy);
}

float3 clouds(float3 col, float2 uv, float time, texture2d<half> map)
{
    // center-correct aspect for sampling
    float2 p = uv * 0.75;
    
    float t = time * 4.0;
    
    // Parallax cloud layers (near, mid, far)
    // tuneable params
    float covFar = 0.353;   // coverage (lower = more clouds)
    float covMid = 0.552;
    float covNear= 0.550;
    
    // scales (bigger = smaller features)
    float sFar  = 1.6;
    float sMid  = 2.4;
    float sNear = 3.2;
    
    // Densities
    float dFar  = cloudDensity(p, sFar,  t*0.10, covFar,  0.26, map);
    float dMid  = cloudDensity(p, sMid,  t*0.25, covMid,  0.23, map);
    float dNear = cloudDensity(p, sNear, t*0.40, covNear, 0.20, map);
    
    // Layer opacities
    float oFar  = 0.45;
    float oMid  = 0.855;
    float oNear = 0.865;
    
    // Lighting direction (soft, from top-left)
    float3 L = normalize(float3(-0.6, 0.7, 0.35));
    
    // Compute simple lighting per layer
    // Using screen-space gradient as a pseudo-normal
    float3 cloudAlbedo = float3(0.93, 0.94, 0.96); // soft white
    float3 cloudShadow = float3(0.26, 0.29, 0.33); // bluish gray shadows
    
    // FAR
    float2 gF = densityGrad(p, sFar,  t*0.30, map);
    float ndlF = clamp(0.5 + 0.5*dot(normalize(float3(-gF,1.0)), L), 0.0, 1.0);
    float3 cF = mix(cloudShadow, cloudAlbedo, ndlF);
    col = mix(col, cF, dFar * oFar);
    
    // MID
    float2 gM = densityGrad(p, sMid,  t*0.35, map);
    float ndlM = clamp(0.45 + 0.55*dot(normalize(float3(-gM,1.0)), L), 0.0, 1.0);
    float3 cM = mix(cloudShadow*0.96, cloudAlbedo, ndlM);
    col = mix(col, cM, dMid * oMid);
    
    // NEAR
    float2 gN = densityGrad(p, sNear, t*0.40, map);
    float ndlN = clamp(0.42 + 0.58*dot(normalize(float3(-gN,1.0)), L), 0.0, 1.0);
    float3 cN = mix(cloudShadow*0.92, cloudAlbedo, ndlN);
    col = mix(col, cN, dNear * oNear);
    
    return col;
}
