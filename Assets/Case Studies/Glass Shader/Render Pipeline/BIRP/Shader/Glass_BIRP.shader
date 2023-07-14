Shader "Jettelly/Glass"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _ChromAberration ("Chromatic Aberration", Range(0.001, 0.01)) = 0.01

        [Space(10)]     // reflection and refraction
        _RefIndex ("Refraction Index", Range(1.1, 2.0)) = 1.45
        _RefDetail ("Reflection Detail", Range(0, 1)) = 0.0   

        [Space(10)]     // fresnel
        _FresPower ("Fresnel Power", Range(1, 3)) = 2
        _FresExposure ("Fresnel Exposure", Range(0, 1)) = 0.4
        
        [Space(10)]     // specular
        _SpecFactor ("Specular Factor", Range(0, 1)) = 1
        _SpecPower ("Specular Power", Range(1, 200)) = 200
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f 
            {
                half3 worldRefl : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD1;
                float3 worldViewDir : TEXCOORD2;
            };

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT (v2f, o);
                o.pos = UnityObjectToClipPos(v.vertex);
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            float4 _Color;
            float _ChromAberration;
            float _RefDetail;
            float _RefIndex;
            float _FresPower;
            float _FresExposure;
            float _SpecFactor;
            float _SpecPower;

            void FresnelEffect_float(float3 WorldNormal, float3 ViewDir, float Power, out float Out)
            {
                Out = pow((1.0 - saturate(dot(normalize(WorldNormal), normalize(ViewDir)))), Power) * _FresExposure;
            }

            void SpecularPhong_float(float3 WorldNormal, float3 LightDir, float3 ViewDir, float SpecFactor, float Attenuation, float SpecPower, out float3 Out)
            {
                float3 halfwayDir = normalize(LightDir + ViewDir);
                Out = SpecFactor * Attenuation * pow(max(0, dot(normalize(WorldNormal), normalize(halfwayDir))), SpecPower);
            } 
        
            fixed4 frag (v2f i) : SV_Target
            {    
                half fresnel = 0;
                FresnelEffect_float(i.worldNormal, i.worldViewDir, _FresPower, fresnel);

                half3 specular = 0;
                float3 lightDir = _WorldSpaceLightPos0.xyz;
                SpecularPhong_float(i.worldNormal, lightDir, i.worldViewDir, _SpecFactor, 1, _SpecPower, specular);

                float3 r = refract(-i.worldViewDir, i.worldNormal, 1/_RefIndex);
                float3 worldRefl = refract(r, i.worldNormal, 1);

                half R = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, worldRefl + _ChromAberration, _RefDetail).r;
                half G = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, worldRefl, _RefDetail).g;
                half B = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, worldRefl - _ChromAberration, _RefDetail).b;
                half A = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, worldRefl, _RefDetail).a;

                half4 skyData = half4(R, G, B, A);
                half3 skyColor = DecodeHDR (skyData, unity_SpecCube0_HDR) * _Color;
                half4 col = 0;

                col.rgb = skyColor + fresnel + specular;
                return col;
            }
            ENDCG
        }
    }
}