Shader "LearningShader/GradientNoise"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _GradientX("GradientX", Float)=0.5
        _GradientY("GradientY", Float)=0.5
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

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
            float2 unity_gradientNoise_dir(float2 p)
            {
                p = p % 289;
                float x = (34 * p.x + 1) * p.x % 289 + p.y;
                x = (34 * x + 1) * x % 289;
                x = frac(x / 41) * 2 - 1;
                return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
            }
            float unity_gradientNoise(float2 p)
            {
                float2 ip = floor(p);
                float2 fp = frac(p);
                float d00 = dot(unity_gradientNoise_dir(ip), fp);
                float d01 = dot(unity_gradientNoise_dir(ip + float2(0, 1)), fp - float2(0, 1));
                float d10 = dot(unity_gradientNoise_dir(ip + float2(1, 0)), fp - float2(1, 0));
                float d11 = dot(unity_gradientNoise_dir(ip + float2(1, 1)), fp - float2(1, 1));
                fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
                return lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x);
            }

            void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
            {
                Out = unity_gradientNoise(UV * Scale) + 0.5;
            }
            sampler2D _MainTex;
            float _GradientX;
            float _GradientY;
            v2f vert (appdata v)
            {
                
                v2f i;
                i.uv=v.uv;
                float3 vert=v.vertex;
                vert.x=i.uv.x;
                vert.y=i.uv.y;
                i.vertex = UnityObjectToClipPos(v.vertex);
                return i;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                Unity_GradientNoise_float(i.uv.xy,_GradientX,i.uv.x);
                Unity_GradientNoise_float(i.uv.xy,_GradientY,i.uv.y);
                fixed4 col_uv1=tex2D(_MainTex, i.uv.xy);
                return col_uv1;
            }
            ENDCG
        }
    }
}
