//
//  Stars.h
//  Weather
//
//  Created by Fedor Artemenkov on 01.04.26.
//

#pragma once

#include "Common.h"

float stars(float2 uv, float time)
{
    float2 grid = uv * 100.0;
    float2 id = floor(grid);
    float2 gv = fract(grid) - 0.5;
    
    float n = hash(id);
    
    float star = smoothstep(0.995, 1.0, n);
    
    float d = length(gv);
    float shape = smoothstep(0.5, 0.0, d);
    
    float speed = mix(0.5, 2.0, hash(id + 1.23));
    float phase = hash(id + 4.56) * 6.2831;
    
    float twinkle = sin(time * speed + phase) * sin(time * speed * 0.37 + phase * 1.7);
    twinkle = twinkle * 0.5 + 0.5;
    twinkle = pow(twinkle, 2.0);
    
    return star * shape * twinkle * 2;
}
