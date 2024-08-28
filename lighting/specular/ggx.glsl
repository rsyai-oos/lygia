#include "../common/ggx.glsl"
#include "../common/smithGGXCorrelated.glsl"
#include "../../math/saturate.glsl"
#include "../../math/saturateMediump.glsl"
#include "../fresnel.glsl"

#ifndef FNC_SPECULAR_GGX
#define FNC_SPECULAR_GGX

float specularGGX(const in vec3 _L, const in vec3 _N, const in vec3 _V, float _NoV, float _NoL, float _roughness, float _fresnel) {
    float NoV = max(_NoV, 0.0);
    float NoL = max(_NoL, 0.0);

    vec3 H = normalize(_L + _V);
    float LoH = saturate(dot(_L, H));
    float NoH = saturate(dot(_N, H));

    // float NoV, float NoL, float roughness
    float linearRoughness =  _roughness * _roughness;
    float D = GGX(NoH, linearRoughness);

#if defined(PLATFORM_RPI)
    float V = smithGGXCorrelated_Fast(_NoV, NoL,linearRoughness);
#else
    float V = smithGGXCorrelated(_NoV, NoL,linearRoughness);
#endif
    
    float F = fresnel(vec3(_fresnel), LoH).r;

    return (D * V) * F;
}

float specularGGX(ShadingData shadingData) {
    return specularGGX(shadingData.L, shadingData.N, shadingData.V, shadingData.NoV, shadingData.NoL, shadingData.linearRoughness, shadingData.fresnel);
}

#endif