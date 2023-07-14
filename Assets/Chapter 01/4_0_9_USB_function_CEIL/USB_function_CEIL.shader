Shader "USB/USB_function_CEIL"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Zoom ("Zoom", Range(0, 1)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
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
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Zoom;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {   
                // let's center the U coordinate and ceil it
                float u = ceil(i.uv.x) * 0.5;
                // let's center the V coordinate and ceil it
                float v = ceil(i.uv.y) * 0.5;
                // then we lerp between the default coordinate and ceil ones
                float uLerp = lerp(u, i.uv.x, _Zoom);
                float vLerp = lerp(v, i.uv.y, _Zoom);

                // sample the texture and use the new coordinates
                fixed4 col = tex2D(_MainTex, float2(uLerp, vLerp));
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
