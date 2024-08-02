#include "normal.hlsl"
#include "cast.hlsl"
#include "ao.hlsl"
#include "softShadow.hlsl"

/*
contributors: Patricio Gonzalez Vivo
description: |
    Material Constructor. Designed to integrate with GlslViewer's defines https://github.com/patriciogonzalezvivo/glslViewer/wiki/GlslViewer-DEFINES#material-defines
use:
    - void raymarchMaterial(in <float3> ro, in <float3> rd, out material _mat)
    - material raymarchMaterial(in <float3> ro, in <float3> rd)
options:
    - LIGHT_POSITION: in glslViewer is u_light
    - LIGHT_DIRECTION
    - LIGHT_COLOR
    - RAYMARCH_AMBIENT
    - RAYMARCH_SHADING_FNC(RAY, POSITION, NORMAL, ALBEDO)
license:
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Prosperity License - https://prosperitylicense.com/versions/3.0.0
    - Copyright (c) 2021 Patricio Gonzalez Vivo under Patron License - https://lygia.xyz/license
*/

#ifndef LIGHT_POSITION
#define LIGHT_POSITION float3(0.0, 10.0, -50.0)
#endif

#ifndef LIGHT_COLOR
#define LIGHT_COLOR float3(1.0, 1.0, 1.0)
#endif

#ifndef RAYMARCH_AMBIENT
#define RAYMARCH_AMBIENT float3(1.0, 1.0, 1.0)
#endif

#ifndef RAYMARCH_SHADING_FNC
#define RAYMARCH_SHADING_FNC raymarchDefaultShading
#endif

#ifndef FNC_RAYMARCHDEFAULTSHADING
#define FNC_RAYMARCHDEFAULTSHADING

float4 raymarchDefaultShading(Material m) {
    float3  env = RAYMARCH_AMBIENT;

    float3 ref = reflect(-m.V, m.normal);
    float occ = raymarchAO(m.position, m.normal);

    #if defined(LIGHT_DIRECTION)
    float3 lig = normalize(LIGHT_DIRECTION);
    #else
    float3 lig = normalize(LIGHT_POSITION - m.position);
    #endif
    
    float3 hal = normalize(lig + m.V);
    float amb = saturate(0.5 + 0.5 * m.normal.y);
    float dif = saturate(dot(m.normal, lig));
    float bac = saturate(dot(m.normal, normalize(float3(-lig.x, 0.0, -lig.z)))) * saturate(1.0 - m.position.y);
    float dom = smoothstep( -0.1, 0.1, ref.y );
    float fre = pow(saturate(1.0 + dot(m.normal, -m.V)), 2.0);
    
    dif *= raymarchSoftShadow(m.position, lig);
    dom *= raymarchSoftShadow(m.position, ref);

    float3 light = float3(0.0, 0.0, 0.0);
    light += 1.30 * dif * LIGHT_COLOR;
    light += 0.40 * amb * occ * env;
    light += 0.50 * dom * occ * env;
    light += 0.50 * bac * occ * 0.25;
    light += 0.25 * fre * occ;

    return float4(m.albedo.rgb * light, m.albedo.a);
}

#endif