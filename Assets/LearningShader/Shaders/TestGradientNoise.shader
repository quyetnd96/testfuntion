Shader "LearningShader/TreeMovingVertex"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Speed("Speed", Float)=0.5
        _WaveScale("_WaveScale", Vector) = (0, 0, 0, 0)
        _wave_direction("wave direction", Vector) = (0, 0, 0, 0)
        _RangeYBeAffect("RangeYBeAffect", Range(0, 1))=0.2
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha

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
                Out = unity_gradientNoise(UV * Scale);
            }
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float2 _WaveScale;
            float _Speed;
            float2 _wave_direction;
            float _RangeYBeAffect;
            
            v2f vert (appdata v)
            {
                v2f i;
                i.uv=v.uv;
                float2 variable=i.uv;
                variable.x+=_Speed*_wave_direction.x*_Time.yy;
                variable.y+=_Speed*_wave_direction.y*_Time.yy;
                Unity_GradientNoise_float(variable.xy,_WaveScale.x,variable.x);
                Unity_GradientNoise_float(variable.xy,_WaveScale.y,variable.y);
                float magniture=sqrt(pow(variable.x,2)+pow(variable.y,5));
                variable.x*=magniture;
                variable.y*=magniture;
                if(i.uv.y>_RangeYBeAffect)
                {
                v.vertex.x+=v.vertex.x*(variable.x);
                v.vertex.y+= v.vertex.y*(variable.y);
                }
                i.vertex = UnityObjectToClipPos(v.vertex);
                return i;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 main=tex2D(_MainTex, i.uv.xy);
                return main;
            }
            ENDCG
        }
    }
}
