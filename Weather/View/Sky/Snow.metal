//
//  Snow.metal
//  Weather
//
//  Created by Fedor Artemenkov on 07.04.26.
//

#include "Common.h"

float snowing(float2 uv, float time, int count)
{
    const float3x3 p = float3x3(13.323122,23.5112,21.71123,21.1212,28.7312,11.9312,21.8112,14.7212,61.3934);
    
    float depth = 2.5;
    float width = 0.1;
    float speed = 2.0;
    float acc = 0.0;
    
    for (int i = 0; i < count; i++)
    {
        float fi = float(i);
        float2 q = uv * (1.0 + fi*depth);
        float w = width * fmod(fi*7.238917,1.0)-width*0.1*sin(time*2.+fi);
        q += float2(q.y*w, speed*time / (1.0+fi*depth*0.03));
        float3 n = float3(floor(q),31.189+fi);
        float3 m = floor(n)*0.00001 + fract(n);
        float3 mp = (31415.9+m) / fract(p*m);
        float3 r = fract(mp);
        float2 s = abs(fmod(q,1.0) -0.5 +0.9*r.xy -0.45);
        s += 0.01*abs(2.0*fract(10.*q.yx)-1.);
        float d = 0.6*max(s.x-s.y,s.x+s.y)+max(s.x,s.y)-.01;
        float edge = 0.05 +0.05*min(.5*abs(fi-5.0),1.);
        acc += smoothstep(edge,-edge,d)*(r.x/(1.+.02*fi*depth));
    }
    
    return acc;
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
