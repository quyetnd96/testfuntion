Shader "Jettelly/Cristal"
{
    Properties
    {
        _Color ("Main Color", Color) = (1, 1, 1 , 1)
        _SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
        [HideInInspector]_MainTex ("Texture", 2D) = "white" {}
        _Sides ("Sides", Range(3, 5)) = 3

        [Header(Specular)]
        _SpecularFactor ("Specular %", Range(0, 1)) = 1
        _SpecularPower ("Specular Power", Range(1, 200)) = 20  

        [Header(Fresnel)]
        _FresnelFactor ("Fresnel %", Range(0, 1)) = 1
        _FresnelPower ("Fresnel Power", Range(0, 10)) = 1

        [Header(Inner Fresnel)]
        _InnerFresnelFactor ("Inner Fresnel %", Range(0, 1)) = 0.9
        _InnerFresnelPower ("Inner Fresnel Power", Range(0, 10)) = 1

        [Header(Reflection)]
        _ReflectionFactor ("Reflection %", Range(0, 1)) = 1        
        _Cube ("Cube Map", Cube) = "" {}
        _Detail ("Reflection Detail", Range(1, 9)) = 1.0
        _ReflectionExposure ("Reflection Exposure", Range(1, 2)) = 1.0

        [Header(Anisoptropic Specular)]
        _TangentMap ("Tangent Map", 2D) = "black"{}
        _AnisoFactor ("Aniso %", Range(0, 1)) = 1
        _AnisoU ("Aniso U", Range(1, 200)) = 1
        _AnisoV ("Aniso V", Range(1, 200)) = 200
    }
    SubShader
    {      
        Pass
        {
            Tags { "Queue"="Geometry" "RenderType"="Opaque" }    
            Cull Back

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv_render : TEXCOORD1;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float2 uv_render : TEXCOORD1;
                float3 positionWS : TEXCOORD2;
                float3 normal : NORMAL;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;
            int _Sides;

            float _InnerFresnelFactor;
            float _InnerFresnelPower;

            samplerCUBE _Cube;
            float _Detail;
            float _ReflectionExposure;
            float _ReflectionFactor;
            float _EmissionPower;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv_render = v.uv_render;
                o.normal = v.normal;  
                o.positionWS = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            float unity_noise_randomValue (float2 uv)
            {
                return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
            }

            float4 unity_triangle(float2 uv, float size)
            {
                float d = 0;
                float4 color = 0;
                float2 st = 0;
                int n = _Sides;

                st = uv;
                st = st * 2 - 1;
                float a = atan2(st.x, st.y) + 3.14159265359;
                float r = 6.28318530718 / float(n);
                d = cos(floor(0.5 + a / r) * r - a) * length(st);

                color = (1.0 - smoothstep(size, size + 0.1, d));
                return color;
            }

            float3 ReflectionColor_float(samplerCUBE CubeMap, float Detail, float3 WorldReflection, float Exposure, float ReflectionFactor)
            {
                float4 cubeMapColor = texCUBElod(CubeMap, float4(WorldReflection, Detail)).rgba;
                return ReflectionFactor * cubeMapColor.rgb * (cubeMapColor.a * Exposure);
            }

            float Fresnel (float3 WorldNormal, float3 ViewDir, float Power)
            {
                return pow((1.0 - saturate(dot(normalize(WorldNormal), normalize(ViewDir)))), Power);
            }

            fixed4 frag (v2f i) : SV_Target
            {    
                i.uv_render *= 32;      
                i.uv_render += _WorldSpaceCameraPos.xy; // movement  

                float2 uvFrac = float2(frac(i.uv_render.x), frac(i.uv_render.y));
                float2 id = floor(i.uv_render);
                float y = 0;
                float x = 0; 
                fixed4 col = 0;

                float3 normalWS = normalize(mul(unity_ObjectToWorld, float4(i.normal, 0))).xyz; 
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.positionWS.xyz);                

                for(y = -1; y <= 1; y++)
                {
                    for(x = -1; x <= 1; x++)
                    {
                        float2 offset = float2(x, y);
                        float noise = unity_noise_randomValue(id + offset);    
                        float size = frac(noise * 123.32);                       
                        float warp = unity_triangle(uvFrac - offset - float2(noise, frac(noise * 23.12)), size * 1.5);                          

                        warp *= (sin(noise * ((_WorldSpaceCameraPos.x - (i.positionWS.x * 5) + noise) * 20)));
                        warp *= (cos(noise * ((_WorldSpaceCameraPos.y - (i.positionWS.y * 5) + noise) * 20)));          
                        warp *= (sin(noise * ((_WorldSpaceCameraPos.z - (i.positionWS.z * 5) + noise) * 20)));

                        col += warp;
                    }
                }                

                float fresnel = Fresnel (normalWS, viewDir, _InnerFresnelPower);                  
                fresnel *= _InnerFresnelFactor;
                fresnel = 1 - fresnel;                
                
                float3 worldReflection = reflect(-viewDir, normalWS);
                float3 reflectionColor = ReflectionColor_float(_Cube, _Detail, worldReflection, _ReflectionExposure, _ReflectionFactor); 
                
                float4 sinColor = sin(float4(0.36, 0.74, 0.78, 1) * fresnel * 10) * 0.5 + 0.5;
                return (float4(reflectionColor, 1) + clamp(col, 0, 1)) * sinColor * _Color;
            }
            ENDCG
        }

        ///////////////////////////////////////////////////////////////////////////////////////////////////////
               
        Pass
        {
            Tags { "Queue"="Transparent" "RenderType"="Opaque" }   
            Blend One One
            Cull back

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "UnityLightingCommon.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;
                float3 positionWS : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;

            float _SpecularFactor; 
            float _SpecularPower;  
            float4 _SpecularColor;

            float _FresnelPower;
            float _FresnelFactor;

            sampler2D _TangentMap;
            float _AnisoU;
            float _AnisoV;
            float _AnisoFactor;

            float _ReflectionExposure;
            float _ReflectionFactor;

            float3 Specular (float3 NormalDir, float3 LightDir, float3 ViewDir, float3 SpecularColor, float SpecularFactor, float Attenuation, float SpecularPower)
            {
                float3 halfwayDir = normalize(LightDir + ViewDir);
                return SpecularColor * SpecularFactor * Attenuation * pow(max(0, dot(normalize(NormalDir), normalize(halfwayDir))), SpecularPower);
            } 

            float Fresnel (float3 WorldNormal, float3 ViewDir, float Power)
            {
                return pow((1.0 - saturate(dot(normalize(WorldNormal), normalize(ViewDir)))), Power);
            }

            float3 AnisoSpecular (float nU, float nV, float3 tangentDir, float3 normalDir, float3 lightDir, float3 viewDir, float reflectionFactor, float anisoFactor)
            {
                float pi = 3.141592;
                float3 halfwayVector = normalize(lightDir + viewDir);
                float3 NdotH = dot(normalDir, halfwayVector);
                float3 HdotT = dot(halfwayVector, tangentDir);
                float3 HdotB = dot(halfwayVector, cross(tangentDir, normalDir));
                float3 VdotH = dot(viewDir, halfwayVector); // here
                float3 NdotL = dot(normalDir, lightDir);
                float3 NdotV = dot(normalDir, viewDir);

                float power = nU * pow(HdotT, 2) + nV * pow(HdotB, 2);
                power /= 1.0 - pow(NdotH, 2);

                float spec = sqrt((nU + 1) * (nV + 1)) * pow(NdotH, power);
                spec /= 8.0 * pi * VdotH * max(NdotL, NdotV);

                float fresnel = reflectionFactor + (1.0 - reflectionFactor) * pow(1.0 - VdotH, 5.0);
                spec *= fresnel;
                return clamp(spec * anisoFactor, 0, 1);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = v.normal;  
                o.positionWS = mul(unity_ObjectToWorld, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {    
                float3 lightDir = _WorldSpaceLightPos0.xyz;
                float3 lightColor = _LightColor0.xyz;
                float attenuation = 1;

                float3 normalWS = normalize(mul(unity_ObjectToWorld, float4(i.normal, 0))).xyz; 
                float3 viewDir = normalize(_WorldSpaceCameraPos.xyz - i.positionWS.xyz);

                float3 specularColor = Specular (normalWS, lightDir, viewDir, float3(2, 2, 2), _SpecularFactor, attenuation, _SpecularPower);                

                float fresnel = Fresnel(normalWS, viewDir, _FresnelPower);                  
                fresnel *= _FresnelFactor;                
                
                float4 tangentMap = tex2D(_TangentMap, i.uv);
                float3 specularAnisoColor = AnisoSpecular(_AnisoU, _AnisoV, UnpackNormal(tangentMap), normalWS, lightDir, viewDir, _ReflectionFactor, _AnisoFactor);                

                float4 main_texture = tex2D(_MainTex, i.uv);
                return float4(specularAnisoColor + specularColor + floor(fresnel + 0.25), 1) * _SpecularColor;
            }

            ENDCG
        }        
    }
}
