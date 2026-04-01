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

//#define SUN
#define STARS

struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct SkyUniforms {
    float time;
    float aspect;
    float sunHeight;
    float cloudiness;
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
    uv.x *= uniforms.aspect;
    
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
    
#ifdef STARS
    {
        float s = stars(uv, uniforms.time);
        float horizonFade = smoothstep(-0.5, 0.5, viewDir.y);
        float3 starColor = float3(1.0);
        float starMask = 1.0 - dayFactor;
        sky += starColor * s * horizonFade * starMask * 5;
    }
#endif
    
    {
        float cloud = layeredClouds(in.texCoord, uniforms.time);
        float alpha = cloudAlpha(cloud, viewDir.y);
        float3 cloudCol = cloudLighting(cloud, viewDir, sunDir);
        sky = mix(sky, sky + cloudCol, alpha * uniforms.cloudiness);
    }
    
    {
        float cloud = clouds(uv, uniforms.time);
        float alpha = cloudAlpha(cloud, viewDir.y);
        float3 cloudCol = cloudLighting(cloud, viewDir, sunDir);
        sky = mix(sky, sky + cloudCol, alpha * uniforms.cloudiness);
    }

    
#ifdef SUN
    {
        float2 p = uv;
        float3 ww = normalize(float3(0.0, -0.1, 1.0));
        float3 uu = normalize(cross( float3(0.0,1.0,0.0), ww));
        float3 vv = normalize(cross(ww,uu));
        float3 rd = normalize(p.x*uu + p.y*vv + 0.5*ww);
        
        const float3 sunCol1 = float3(1.0, 0.5, 0.4);
        const float3 sunCol2 = float3(1.0, 0.8, 0.7);
        float sunDot = max(dot(rd, sunDir), 0.0);
        
        sky += 0.5 * sunCol1 * pow(sunDot, 30.0);
        sky += 4.0 * sunCol2 * pow(sunDot, 300.0);
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
