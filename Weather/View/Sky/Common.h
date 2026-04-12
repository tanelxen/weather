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


struct VertexOut {
    float4 position [[position]];
    float2 texCoord;
};

struct SkyUniforms {
    float2 iResolution;
    float time;
    float dayTime;
    float cloudiness;
    float raininess;
    uint snowiness;
};

#endif
