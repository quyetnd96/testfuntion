float3 Refract(in float3 i, in float3 n, in float eta)
{
    float cosi = dot(-i, n);
    float cost2 = 1.0 - eta * eta * (1.0 - cosi * cosi);
    float3 t = eta * i + ((eta * cosi - sqrt(abs(cost2))) * n);
    
    return t * (float3)(cost2 > 0);
}

void GlassCube_float (in float3 ViewDir, in float3 Normal, in float index, in float detail, in float CA, out float3 Out)
{     
    float3 r = Refract(normalize(-ViewDir), normalize(Normal), 1/index);
    float3 worldRefl = Refract(r, Normal, 1);

    float R = DecodeHDREnvironment(SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, worldRefl + CA, detail), unity_SpecCube0_HDR).r;
    float G = DecodeHDREnvironment(SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, worldRefl, detail), unity_SpecCube0_HDR).g;
    float B = DecodeHDREnvironment(SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, worldRefl - CA, detail), unity_SpecCube0_HDR).b;

    Out = float4(R, G, B, 1);
}