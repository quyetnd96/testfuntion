Shader "USB/USB_function_FRAC"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Size ("Size", Range(0.0, 0.5)) = 0.3
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
            float _Size;

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
                // increase the UV tiling
                i.uv *= 3;
                float2 fuv = frac(i.uv);
                // let's generate the circle
                float circle = length(fuv - 0.5);
                // invert the colors
                float wCircle  = floor(_Size / circle);
                // sample the texture
                // fixed4 col = tex2D(_MainTex, fuv);
                // apply fog
                // UNITY_APPLY_FOG(i.fogCoord, col);

                return float4(wCircle.xxx, 1);
            }
            ENDCG
        }
    }
}
