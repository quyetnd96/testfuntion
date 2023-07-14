Shader "USB/USB_drawers"
{
    Properties
    {
        // all the drawers can be seen from the Inspector 
        // the implementation of each depends on its chartacteristics.
        [Header(HEADER PROPERTIES)]
        _MainTex ("Texture", 2D) = "white" {}
        [Toggle] _Toggle ("Toggle", Float) = 0        
        [KeywordEnum (Off, Red, Blue)] _KeywordEnum ("KeywordEnum", Float) = 0
        [Enum(Off, 0, On, 1)] _Enum ("Enum", Float) = 0
        [PowerSlider(3.0)] _PowerSlider ("PowerSlider", Range(0, 1)) = 0
        [IntRange] _IntRange ("IntRange", Range(0, 255)) = 0        
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
            // use shader variants to compile more than one feature for a shader
            #pragma shader_feature _TOGGLE_ON
            #pragma multi_compile _KEYWORDENUM_OFF _KEYWORDENUM_RED _KEYWORDENUM_BLUE

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
            // in the case of PowerSlider and IntRange, they need connection variables
            float _PowerSlider;
            int _IntRange;

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
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
