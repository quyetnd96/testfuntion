Shader "Unlit/USB_simple_color_URP"
{
    Properties
    {   
        _MainTex("Maintex", 2D)= "white"{}
        _Color("Tint",Color)=(1,1,1,1)
        
    }
    SubShader
    {
        Tags { 
            "RenderType"="Opaque" 
            "Queue"="Geometry" 
            "RenderPipeline"="UniversalRenderPipeline"
        }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "HLSLSupport.cginc"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata
            {
                float4 vertex: POSITION;
                float2 uv : TEXCOORD0;
            };  
            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
            float4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }
            fixed4 frag (v2f i):SV_Target
            {
                fixed4 col=tex2D(_MainTex,i.uv);
                return col*_Color;
            }
            ENDHLSL
        }
    }
}
