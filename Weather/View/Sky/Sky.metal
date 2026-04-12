//
//  Sky.metal
//  Weather
//
//  Created by Fedor Artemenkov on 01.04.26.
//

#include "Common.h"

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

static float fbm(float2 p)
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

static float starts_noise(float2 x)
{
    float xhash = cos( x.x * 37.0 );
    float yhash = cos( x.y * 47.0 );
    return fract( 415.92653 * ( xhash + yhash ) );
}

float stars(float2 uv, float time)
{
    float2 grid = uv * 200.0;
    float2 id = floor(grid);
    float2 gv = fract(grid) - 0.5;
    
    float n = starts_noise(id);
    
    float star = smoothstep(0.995, 1.0, n);
    
    float d = length(gv);
    float shape = smoothstep(0.5, 0.0, d);
    
    float speed = mix(0.5, 2.0, starts_noise(id + 1.23));
    float phase = starts_noise(id + 4.56) * 6.2831;
    
    float twinkle = sin(time * speed + phase) * sin(time * speed * 0.37 + phase * 1.7);
    twinkle = twinkle * 0.5 + 0.5;
    twinkle = pow(twinkle, 2.0);
    
    return star * shape * twinkle;
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
