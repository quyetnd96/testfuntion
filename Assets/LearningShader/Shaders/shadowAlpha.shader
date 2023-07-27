Shader "Unlit/shadowAlpha"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Alpha ("Alpha", float)=0.1
        _Color ("Color", Color)=(1,1,1,1)
        [IntRange] _Sections ("Sections", Range(2, 10)) = 5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite On
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
            float4 _Color;
            float _FillY;
            float _Alpha;
            float _Sections;

             v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv, _MainTex);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float fv = (i.uv.y * _Sections) * (_Sections / 100.0);
                fixed4 col = tex2D(_MainTex, i.uv.xy)*fv;
        
                return fixed4(0,0,0,col.a*_Alpha);
            }
            ENDCG
        }
    }
}
