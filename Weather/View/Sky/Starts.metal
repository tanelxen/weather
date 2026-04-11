//
//  Starts.metal
//  Weather
//
//  Created by Fedor Artemenkov on 04.04.26.
//

#include <metal_stdlib>
using namespace metal;

static float hash(float2 p)
{
    return fract(sin(dot(p, float2(127.1, 311.7))) * 43758.5453);
}

static float noise(float2 x)
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
    
    float n = noise(id);
    
    float star = smoothstep(0.995, 1.0, n);
    
    float d = length(gv);
    float shape = smoothstep(0.5, 0.0, d);
    
    float speed = mix(0.5, 2.0, noise(id + 1.23));
    float phase = noise(id + 4.56) * 6.2831;
    
    float twinkle = sin(time * speed + phase) * sin(time * speed * 0.37 + phase * 1.7);
    twinkle = twinkle * 0.5 + 0.5;
    twinkle = pow(twinkle, 2.0);
    
    return star * shape * twinkle;
}
