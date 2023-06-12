Shader "LearningShader/Masking"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _MaskTex("Mask Texture",2D)="white" {}
        [Enum(UnityEngine.Rendering.BlendMode)]
        _SrcFactor("Src Factor", Float)=5
        [Enum(UnityEngine.Rendering.BlendMode)]
        _DstFactor("Dst Factor", Float)=10
        [Enum(UnityEngine.Rendering.BlendOp)]
        _Opp("Operation",Float)=5

        _RevealValue("Reveal",float)=0
        _Feather("Feather",float)=0
        _ErodeColor("Erode Color",Color)=(1,1,1,1)

    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Blend [_SrcFactor] [_DstFactor]
        BlendOp [_Opp]

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
                float4 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _MaskTex;
            float4 _MaskTex_ST;
            float _RevealValue;
            float _Feather;
            float4 _ErodeColor;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv, _MaskTex);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                
                fixed4 col=tex2D(_MainTex,i.uv.xy);
                fixed4 mask=tex2D(_MaskTex,i.uv.zw);
                // float revealAmount=smoothstep(mask.r-_Feather,mask.r+_Feather,_RevealValue);
                float revealAmountTop=step(mask.r,_RevealValue+_Feather);
                float revealAmountBottom=step(mask.r,_RevealValue-_Feather);
                float revealDifference=revealAmountTop-revealAmountBottom;
                float3 finalCol=lerp(col.rgb,_ErodeColor,revealDifference);
                // return fixed4(revealDifference.xxx,1);
                return fixed4(finalCol.rgb,col.a*revealAmountTop);
            }
            ENDCG
        }
    }
}
