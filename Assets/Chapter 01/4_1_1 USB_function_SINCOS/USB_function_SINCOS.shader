Shader "USB/USB_function_SINCOS"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Speed ("Rotation Speed", Range(0, 3)) = 1
        [KeywordEnum(RX, RY, RZ)] _Axis ("Axis", float) = 0
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
            #pragma multi_compile _AXIS_RX _AXIS_RY _AXIS_RZ

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
            float _Speed;

            // let's add the rotation function
            float3 rotation(float3 vertex)
            {
                float c = cos(_Time.y * _Speed);
                float s = sin(_Time.y * _Speed);

#if _AXIS_RX    
                // it allow us to rotate the object in the X axis
                float3x3 m = float3x3
                (
                    1,  0,  0,
                    0,  c,  -s,
                    0,  s,  c
                );            
#elif _AXIS_RY
                // it allow us to rotate the object in the Y axis
                float3x3 m = float3x3
                (
                    c,  0,  s,
                    0,  1,  0,
                    -s, 0,  c
                );
#elif _AXIS_RZ
                // it allow us to rotate the object in the Z axis
                float3x3 m = float3x3
                (
                    c,  -s, 0,
                    s,  c,  0,
                    0,  0,  1
                );
#endif

                return mul(m, vertex);
            }

            v2f vert (appdata v)
            {
                v2f o;
                // let's rotate the vertices before the clip transformation
                float3 rotVertex = rotation(v.vertex);
                // then we transform to clip-space
                o.vertex = UnityObjectToClipPos(rotVertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
