Shader "Unlit/ScaleUVAndVertex"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _SupportTex ("SupportTex", 2D) = "white" {}
        _TransformX("TransformX", Float)=0.5
        _ExpendXFromRoof("_ExpendXBound", Range(1, 10))=1.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        // Blend SrcAlpha OneMinusSrcAlpha
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
            sampler2D _SupportTex;
            float4 _SupportTex_ST;
            float _ExpendXFromRoof;
            float _TransformX;

            v2f vert (appdata v)
            {
                v2f i;
                i.uv=v.uv;
                i.uv.x= (i.uv.x-0.5)*_ExpendXFromRoof+0.5;
                float3 vert=v.vertex;
                vert.x=(v.vertex.x)*_ExpendXFromRoof;
                vert.x+=_TransformX*_MainTex_ST.x;
                i.vertex = UnityObjectToClipPos(vert);
                return i;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                
                fixed4 main=tex2D(_MainTex, i.uv.xy);
                fixed4 board=tex2D(_SupportTex,i.uv.xy);
                // if(main.a<=0)
                // {
                //     return fixed4(0,0,0,0);
                // }
                // else
                // {
                    return main;
                // }
            }
            ENDCG
        }
    }
}
