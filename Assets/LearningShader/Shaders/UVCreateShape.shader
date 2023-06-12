Shader "LearningShader/UVCreateShape"
{
    Properties
    {
        _UVTex ("UVTex", 2D) = "white" {}
        _MinusTexUV("MinusTexUV", 2D)="white" {}
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

            sampler2D _UVTex;
            float4 _UVTex_ST;
            sampler2D _MinusTexUV;
            float4 _MinusTexUV_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _UVTex);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col1 = tex2D(_MinusTexUV, i.uv);
                if(col1.a==0)
                {
                    return 0;
                }
                else
                {
                    fixed4 col = tex2D(_UVTex, i.uv);
                return col;
                }
                
            }
            ENDCG
        }
    }
}
