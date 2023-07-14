Shader "Unlit/USB_simple_color"
{
    Properties
    {   [Header(Specular properties)]
        _MainTex("Maintex", 2D)= "white"{}
        _Color("Tint",Color)=(1,1,1,1)
        [KeywordEnum(Off,Red,Blue)]
        _Options("Color Option", Float)=0
        [Enum(Off, 0, Front,1,Back, 2)]
        _Face("Face Culling",Float)=0
        [PowerSlider(3.0)] _Brightness("Brightness", Range (0.01,1))=0.08
        [Space(20)]
        [Header(Texture properties)]
        [IntRange]
        _Samples("Samples",Range (0,255))=100
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #pragma multi_compile _OPTIONS_OFF _OPTIONS_RED _OPTIONS_BLUE

            struct appdata
            {
                float4 vertex: POSITION;
                float2 uv : TEXCOORD0;
            };  
            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };
            float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Brightness;
            int _Samples;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }
            half4 frag (v2f i):SV_Target
            {
                half4 col=tex2D(_MainTex,i.uv);
            #if _OPTIONS_OFF
            return col;
            #elif _OPTIONS_RED
            return col*float4(1,0,0,1);
            #elif _OPTIONS_BLUE
            return col*float4(0,0,1,1);
            #endif
            }
            ENDCG
        }
    }
}
