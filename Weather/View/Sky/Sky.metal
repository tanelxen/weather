//
//  Sky.metal
//  Weather
//
//  Created by Fedor Artemenkov on 01.04.26.
//

#include <metal_stdlib>
#include "Common.h"

using namespace metal;

#define RAIN 0
#define SNOW 0



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


float3 skyGradient(float2 uv, float hour)
{
    float dayFraction = fract(hour / 24.0);
    
    const float sunraiseTime = (6.0 / 24.0);
    const float sunsetTime = (18.0 / 24.0);
    const float duration = (2.0 / 24.0);
    
    float3 dayTop = float3(0.2, 0.4, 0.8);
    float3 dayBottom = float3(0.6, 0.8, 1.0);
    float3 sunsetColor = float3(1.0, 0.0, 0.0);
    
    float sunraiseScatter = 1.0 - smoothstep(sunraiseTime - duration * 0.5, sunraiseTime + duration * 0.5, dayFraction);
    float sunsetScatter = smoothstep(sunsetTime - duration * 0.5, sunsetTime + duration * 0.5, dayFraction);
    float scatter = (sunraiseScatter + sunsetScatter) * 0.5;
    
    float3 scatterColor = mix(dayBottom, sunsetColor, scatter);
    
    float atmosphere = pow(uv.y, 2);
    float3 day = mix(dayTop, scatterColor, atmosphere);
    
    float3 nightTop = float3(0.04, 0.03, 0.13);
    float3 nightBottom = float3(0.16, 0.24, 0.39);
    float3 night = mix(nightTop, nightBottom, uv.y);
    
    float sunrise = smoothstep(sunraiseTime - duration * 0.5, sunraiseTime, dayFraction);
    float sunset = 1.0 - smoothstep(sunsetTime, sunsetTime + duration * 0.5, dayFraction);
    float t = sunrise * sunset;
    
    return mix(night, day, t);
}

fragment float4 skyFragmentShader
(
 VertexOut in [[stage_in]],
 constant SkyUniforms &uniforms [[ buffer(0) ]]
)
{
    float2 uv = in.position.xy / uniforms.iResolution;
    
    float3 sky = skyGradient(uv, uniforms.dayTime);
    
    uv.y *= uniforms.iResolution.y / uniforms.iResolution.x;
    
    {
        float s = stars(uv, uniforms.time);
        s += stars(uv * 0.5 + 0.4, uniforms.time * 0.9);
        
        float horizonFade = 1.0 - smoothstep(0.5, 2.0, uv.y);
        
        float dayFraction = fract(uniforms.dayTime / 24.0);
        float beforeSunraise = 1.0 - smoothstep(0.2, 0.25, dayFraction);
        float afterSunset = smoothstep(0.75, 0.8, dayFraction);
        float t = beforeSunraise + afterSunset;
        
        sky += float3(1.0) * s * horizonFade * t * 2;
        sky = saturate(sky);
    }
    
    float dayFraction = fract(uniforms.dayTime / 24.0);
    
    {
        float a = dayFraction * 2 * 3.14 + 3.14;
        float x = 0.5 + sin(a) * 1.0;
        float y = 1.75 - cos(a) * 1.5;
        
        float2 sunPos = float2(x, y);
        float2 sunDir = uv - sunPos;
        
        float d = length(sunDir) * 13.0;
        float sun = 1.0 / (d * d);
        
        sky = mix(sky, float3(1.0, 1.0, 0.9), sun);
    }
    
    {
        float a = dayFraction * 2 * 3.14;
        float x = 0.5 + sin(a) * 1.0;
        float y = 1.75 - cos(a) * 1.5;
        
        float2 moonPos = float2(x, y);
        float2 moonDir = uv - moonPos;
        
        float glow = 0.95 * exp(-length(moonDir) * 6.0);
        sky += glow;
        
        float moon = smoothstep(0.09, 0.08, length(moonDir));;
        float col = 0.5 + fbm(16.0 * moonDir + 1.2);
        sky = mix(sky, float3(col), moon);
        sky = saturate(sky);
    }
    
    return float4(sky, 1.0);
}


fragment float4 cloudsFragmentShader
(
 VertexOut in [[stage_in]],
 constant SkyUniforms &uniforms [[ buffer(0) ]],
 texture2d<half> noiseMap [[ texture(0) ]]
)
{
    float2 uv = in.texCoord;
    uv.y *= uniforms.iResolution.y / uniforms.iResolution.x;
    
    float horizonFade = smoothstep(0.8, 1.5, uv.y);
    float4 color = clouds(float4(0), uv * 3, uniforms.time, noiseMap);
    
    color *= horizonFade * uniforms.cloudiness;
    
    color += float4(0.1, 0.1, 0.1, 0.2 * uniforms.cloudiness);
    color = saturate(color);
    
    return color;
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

fragment float4 snowFragmentShader
(
 VertexOut in [[stage_in]],
 constant SkyUniforms &uniforms [[ buffer(0) ]]
)
{
    float2 uv = in.texCoord;
    uv.y *= uniforms.iResolution.y / uniforms.iResolution.x;
    
    float snow = snowing(uv, uniforms.time, uniforms.snowiness);
    
    return float4(1, 1, 1, snow * 1.5);
}
