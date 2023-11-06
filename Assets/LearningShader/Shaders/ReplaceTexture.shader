Shader "LearningShader/ReplaceTexture"
{
    Properties
    {
        _Tex1 ("Texture1", 2D) = "white" {}
        _Tex2 ("Texture2", 2D) = "white" {}
        
        _Paste("Paste", Range(0,1))=0
        _Reveal("Reveal",Range(0,1))=0
        _Smoothness("Smoothness",Range(0,1))=0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        AlphaToMask On

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
                float4 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _Tex1;
            float4 _Tex1_ST;
            sampler2D _Tex2;
            float4 _Tex2_ST;
            float _Paste,_Reveal,_Smoothness;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _Tex1);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col1 = tex2D(_Tex1, i.uv.xy);
                fixed4 col2 = tex2D(_Tex2,i.uv.xy);
                float reveal=step(col1.r,_Reveal);
                return fixed4(col1.rgb*reveal+col2.rgb*(1-reveal),1);
            }
            ENDCG
        }
    }
}
