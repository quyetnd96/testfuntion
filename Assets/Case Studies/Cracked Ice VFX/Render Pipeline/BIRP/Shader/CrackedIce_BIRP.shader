Shader "Jettelly/CrackedIce"
{
    Properties
    {        
        _MainTex ("Texture", 2D) = "white" {}

        [Header(Ambient color)]
        _Diffuse ("Diffuse Factor", Range(0, 1)) = 1
        _AmbientFactor ("Ambien Factor", Range(0, 1)) = 1
        _EmissionPower ("Emission Power", Range(0, 1)) = 0

        [Header(Specular)]
        _SpecularFactor ("Specular Factor", Range(0, 1)) = 1
        _SpecularPower ("Specular Power", Range(1, 200)) = 1          

        [Header(Fresnel)]
        _FresnelFactor ("Fresnel Factor", Range(0, 1)) = 1
        _FresnelPower ("Fresnel Power", Range(0, 10)) = 3 

        [Header(Reflection)]
        _ReflectionFactor ("Reflection Factor", Range(0, 1)) = 1        
        _Cube ("Reflection Map", Cube) = "" {}
        _Detail ("Reflection Detail", Range(1, 9)) = 1.0
        _ReflectionExposure ("Reflection Exposure", Range(1, 2)) = 1.0        

        [Header(Parallax)]
        _ColorBase ("Base", Color) = (1, 1, 1, 1)
        _ColorLight ("Light", Color) = (1, 1, 1, 1)
        _Iterations("Iterations", Range(1, 50)) = 30
        _OffsetScale("Offset scale", Range(0, 0.2)) = 0.1

    }
    SubShader
    {
        Tags { "Queue"="Geometry" "RenderType"="Opaque" }       
		Cull Back		

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #pragma target 3.0

            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 positionWS : TEXCOORD1;
                float3 normalWS : NORMAL;
                float4 surfaceColor : COLOR0;
                float4 tangentWS : TEXCOORD2;
                float3 viewDirTG : TEXCOORD3;
                float3 viewDirWS : TEXCOORD4;
            };            
            
            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _Diffuse; 
            float _AmbientFactor;  

            float _SpecularFactor; 
            float _SpecularPower;  

            float _FresnelPower;
            float _FresnelFactor;

            samplerCUBE _Cube;
            float _Detail;
            float _ReflectionExposure;
            float _ReflectionFactor;
            float _EmissionPower;

            float _Iterations;
            float _OffsetScale;
            float4 _ColorBase;
            float4 _ColorLight;

            void DiffuseColor_float(float3 WorldNormal, float3 LightDir, float3 LightColor, float DiffuseFactor, float Attenuation, out float3 Out)
            {
                Out = LightColor * DiffuseFactor * Attenuation * max(0, dot(normalize(WorldNormal), normalize(LightDir)));
            }

            void FresnelEffect_float(float3 WorldNormal, float3 ViewDir, float Power, out float Out)
            {
                Out = pow((1.0 - saturate(dot(normalize(WorldNormal), normalize(ViewDir)))), Power);
            }

            void SpecularPhong_float(float3 NormalDir, float3 LightDir, float3 ViewDir, float3 SpecularColor, float SpecularFactor, float Attenuation, float SpecularPower, out float3 Out)
            {
                float3 halfwayDir = normalize(LightDir + ViewDir);
                Out = SpecularColor * SpecularFactor * Attenuation * pow(max(0, dot(normalize(NormalDir), normalize(halfwayDir))), SpecularPower);
            }  

            void ReflectionColor_float(samplerCUBE CubeMap, float Detail, float3 WorldReflection, float Exposure, float ReflectionFactor, out float3 Out)
            {
                float4 cubeMapColor = texCUBElod(CubeMap, float4(WorldReflection, Detail)).rgba;
                Out = ReflectionFactor * cubeMapColor.rgb * (cubeMapColor.a * Exposure);
            }            

            v2f vert (appdata v)
            {
                v2f o;     
                UNITY_INITIALIZE_OUTPUT (v2f, o);                  
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                o.normalWS = UnityObjectToWorldNormal(v.normal);
                o.positionWS = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.tangentWS = (normalize(mul(unity_ObjectToWorld, v.tangent.xyz)) * v.tangent.w);
                o.viewDirWS = UnityWorldSpaceViewDir(mul(unity_ObjectToWorld, v.vertex.xyz));

                float4 cameraOS = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1.0));
                float3 viewDirOS = v.vertex.xyz - cameraOS.xyz;                

                float tangetnSign = v.tangent.w * unity_WorldTransformParams.w;
                float3 bitangent = cross(v.normal.xyz, v.tangent.xyz) * tangetnSign;                
                o.viewDirTG = float3(dot(viewDirOS, v.tangent.xyz), dot(viewDirOS, bitangent.xyz), dot(viewDirOS, v.normal.xyz));

                return o;
            }            

            half4 frag (v2f i) : SV_Target
            {    
                float3 lightDirWS = _WorldSpaceLightPos0.xyz;
                float3 lightColor = _LightColor0.xyz;

                float3 normalWS = i.normalWS;
                float3 viewDirWS = i.viewDirWS;
                
                // diffuse -------------------------------------------------------------------
                float3 diffuseColor = 0;
                DiffuseColor_float(normalWS, lightDirWS, lightColor, _Diffuse, 1, diffuseColor);
                float3 ambientColor = _AmbientFactor * UNITY_LIGHTMODEL_AMBIENT;  

                // specular ---------------------------------------------------------------------------
                float3 specularColor = 0;                                  
                SpecularPhong_float(normalWS, lightDirWS, viewDirWS, float3(2, 2, 2), _SpecularFactor, 1, _SpecularPower, specularColor);                

                // fresnell ---------------------------------------------------------------------------
                float fresnel = 0;
                FresnelEffect_float(normalWS, viewDirWS, _FresnelPower, fresnel);  
                fresnel *= _FresnelFactor;

                // reflection -------------------------------------------------------------------------
                float3 reflectionColor = 0;
                float3 worldReflection = reflect(-viewDirWS, normalWS);
                ReflectionColor_float(_Cube, _Detail, worldReflection, _ReflectionExposure, _ReflectionFactor, reflectionColor);                

                // parallax -------------------------------------------------------------------------
                float parallax = 0;
                half4 col = 0;
                
                for (int j = 0; j < _Iterations; j++)
                {
                    float ratio = (float)j / _Iterations;  
                    parallax += tex2D(_MainTex, i.uv + lerp(0, _OffsetScale, ratio) * normalize(i.viewDirTG)) * lerp(1, 0, ratio);                    
                }

                parallax /= _Iterations;  
                float4 sinColor = sin(float4(0.36, 0.74, 0.78, 1) * 50) * 0.5 + 0.5;
                half4 colorLerp = lerp(_ColorBase, _ColorLight, parallax); 
                col += parallax;
                
                // Emission -------------------------------------------------------------------------
                diffuseColor += _EmissionPower;
                col.rgb *= diffuseColor;
                col.rgb += reflectionColor;
                col.rgb += specularColor;
                col.rgb += fresnel;
                col.rgb += colorLerp;
                col.rgb += ambientColor;

                return col;
            }
            ENDHLSL
        }
    }
}
