void CustomLight_float(out half3 direction)
{
    #ifdef SHADERGRAPH_PREVIEW
        // In Shader Graph Preview we will assume a default light direction and white color
        direction = half3(0, 1, 0);
        //endifcolor = half3(1, 1, 1);
        //endifdistanceAttenuation = 1.0;
        //shadowAttenuation = 1.0;
    #else

        // Universal Render Pipeline
        #if defined(UNIVERSAL_LIGHTING_INCLUDED)
        
            // GetMainLight defined in Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl
            Light mainLight = GetMainLight();
            direction = mainLight.direction;
            //color = mainLight.color;
            //distanceAttenuation = mainLight.distanceAttenuation;
            //shadowAttenuation = mainLight.shadowAttenuation;        
        #endif

    #endif
}



