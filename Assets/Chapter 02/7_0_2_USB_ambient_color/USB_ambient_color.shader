Shader "USB/USB_ambient_color"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        // let's add a property to dinamically modify the ambient color
        _Ambient ("Ambient Color", Range(0, 1)) = 1
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
            // we need to connect the property with an internal variable
            float _Ambient;

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
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // UNITY_LIGHTMODEL_AMBIENT contains the ambient color
                // the ambient can be modified from Lighting Window / Environment / Ambient Color
                fixed3 ambient_color = UNITY_LIGHTMODEL_AMBIENT * _Ambient;
                // we add ambient color to the texture color RGB
                col.rgb += ambient_color;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
