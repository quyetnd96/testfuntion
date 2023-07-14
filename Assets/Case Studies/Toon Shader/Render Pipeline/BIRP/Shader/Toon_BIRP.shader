Shader "Jettelly/Toon"
{
    Properties
    {
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
        _MainColor ("Texture Color", Color) = (1, 1, 1, 1)
        _MainExposure ("Texture Exposure", Range(0, 1)) = 0.3
        _ShaStrength ("Shadow Strength", Range(0, 1)) = 0.5
        [Space(10)]
        _FresColor ("Fresnel Color", Color) = (1, 1, 1, 1)
        _FresPower ("Fresnel Power", Range(1, 3)) = 1.5
        _FresStrength ("Fresnel Strength", Range(0, 1)) = 0
    }
    SubShader
    {
        Pass
        {
            Tags {"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
            #include "AutoLight.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                SHADOW_COORDS(1) // put shadows data into TEXCOORD1
                fixed3 diff : COLOR0;
                fixed3 ambient : COLOR1;
                float4 pos : SV_POSITION;
                float3 normalWS : TEXCOORD2;
                float3 viewDirWS : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _MainColor;
            float _MainExposure;
            float _ShaStrength;
            float4 _FresColor;
            float _FresPower;
            float _FresStrength;

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                o.normalWS = UnityObjectToWorldNormal(v.normal);
                o.viewDirWS = UnityWorldSpaceViewDir(mul(unity_ObjectToWorld, v.vertex.xyz));

                half nl = max(0, dot(o.normalWS, _WorldSpaceLightPos0.xyz));
                o.diff = nl * _LightColor0.rgb;
                o.ambient = ShadeSH9(half4(o.normalWS,1));

                TRANSFER_SHADOW(o)
                return o;
            }

            half FresnelEffect_float(float3 normalWS, float3 viewDirWS, float power)
            {
                return pow((1.0 - saturate(dot(normalize(normalWS), normalize(viewDirWS)))), power);                
            }            

            fixed4 frag (v2f i) : SV_Target
            {    
                half4 col = tex2D(_MainTex, i.uv);
                half shadow = SHADOW_ATTENUATION(i);                
                half lighting = i.diff * shadow;

                half3 toonCol = 1 - smoothstep((lighting) - 0.01, (lighting) + 0.01, 0.5);
                half3 diffCol = lerp(toonCol, lighting, _ShaStrength) + i.ambient;

                half fresnel = FresnelEffect_float(i.normalWS, i.viewDirWS, _FresPower);
                half4 freCol = 1 - smoothstep(fresnel - 0.05, fresnel + 0.05, 0.9);
                freCol *= _FresColor;
                freCol *= _FresStrength;

                diffCol += _MainExposure;     
                col.rgb *= diffCol;
                col.rgb += freCol;

                return col;
            }
            ENDCG
        }

        // shadow casting support
        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}