Shader "USB/USB_shadow_map_NDC"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Pass
        {
            Name "Shadow Caster"
            Tags 
            {
                "RenderType"="Opaque"
                "LightMode"="ShadowCaster"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            struct v2f
            {
                V2F_SHADOW_CASTER;
            };

            v2f vert (appdata_full v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }

            ENDCG
        }

        Pass
        {
            Name "Shadow Map Texture"
            Tags
            {
                "RenderType"="Opaque"
                "LightMode"="ForwardBase"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 shadowCoord : TEXCOORD2;
            };

            sampler2D _MainTex;
            sampler2D _ShadowMapTexture;
            float4 _MainTex_ST;

            float4 NDC (float4 pos) 
            {
                float4 o = pos * 0.5f;
                #if defined(UNITY_HALF_TEXEL_OFFSET)
                o.xy = float2(o.x, o.y *_ProjectionParams.x) + o.w * _ScreenParams.zw;
                #else
                o.xy = float2(o.x, o.y *_ProjectionParams.x) + o.w;
                #endif
            
                o.zw = pos.zw;
                return o;
            }

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.shadowCoord = NDC(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.shadowCoord.xy / i.shadowCoord.w;
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed shadow = tex2D(_ShadowMapTexture, uv).a;
                col *= shadow;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
