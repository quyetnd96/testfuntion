Shader "Jettelly/Item Box/Box"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _RampTex ("Ramp Texture", 2D) = "white" {}
        _SpeedColor ("Speed Color", Range(0, 1)) = 0.8

        [Space(10)]
        _SpecularInt ("Specular", Range(0, 1)) = 1
        _SpecularPow ("_SpecularPow", Range(1, 128)) = 10
        _SpecularColor ("SpecularColor", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Pass
        {
            Name "COLOR PASS"

            Tags { "RenderType"="Opaque" "Queue"="Geometry"}
            Cull Front

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uv_ramp : TEXCOORD1; 
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float2 uv_ramp : TEXCOORD1; 
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _RampTex;
            float4 _RampTex_ST;
            float _SpeedColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv_ramp = TRANSFORM_TEX(v.uv_ramp, _RampTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed c = tex2D(_MainTex, i.uv).r;
                float t = _Time.y * _SpeedColor;
                float2 uv_ramp = float2(c + t, 0);
                fixed4 rampTex = tex2D(_RampTex, i.uv_ramp + uv_ramp);  

                return rampTex;
            }
            ENDCG
        }

        // ------------------------------------------------------------------------

        Pass
        {
            Name "LIGHT PASS"

            Tags { "RenderType"="Transparent" "Queue"="Transparent+1"}
            Blend One One
            ZWrite Off
            Cull Back

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

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
                float3 normal_world : TEXCOORD1;
                float3 vertex_world : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _SpecularInt;
            float _SpecularPow;
            float4 _SpecularColor;
            float4 _LightColor0; 

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal_world = UnityObjectToWorldNormal(v.normal);
                o.vertex_world = mul(unity_ObjectToWorld, v.vertex);

                return o;
            }

            float3 SpecularShading (float3 colorRefl, float specularInt, float3 normal, float3 lightDir, float3 viewDir, float specularPow)
            {                    
                float3 h = normalize(lightDir + viewDir);
                return colorRefl * specularInt * pow(max(0, dot(normal, h)), specularPow);
            }

            float unity_FresnelEffect_float (in float3 normal, in float3 viewDir, in float power)
            {
                return pow((1 - saturate(dot(normal, viewDir))), power);
            }


            fixed4 frag (v2f i) : SV_Target
            {    
                half3 normal = i.normal_world;
                half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                half3 colorRefl = _LightColor0.rgb * _SpecularColor;
                half3 viewDir = normalize(_WorldSpaceCameraPos - i.vertex_world);
                
                half3 specular = SpecularShading(colorRefl, _SpecularInt, normal, lightDir, viewDir, _SpecularPow);  
                half fresnel = unity_FresnelEffect_float(i.normal_world, viewDir, 3) * _SpecularColor;
                
                half3 light = max(specular, fresnel);

                return float4(light, 1);
            }
            ENDCG
        }
    }
}
