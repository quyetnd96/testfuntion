Shader "Jettelly/Toxic Pipe/Water"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Lines ("Lines", 2D) = "white" {}
        [Space(10)]
        [HideInInspector]_CU ("CU", Range(0, 1.0)) = 0.5 
        [HideInInspector]_CV ("CU", Range(0, 1.0)) = 0.5 
        _Smooth ("Edge Smooth", Range(0, 0.5)) = 0.5
        _Amount ("Distortion Amount", Range(0, 1)) = 0.5
        _Displacement ("Displacement", Range(0, 1)) = 1
        [Space(10)]
        _ColorB ("Color Background", Color) = (1, 1, 1, 1)
        _ColorT ("Color Tint", Color) = (1, 1, 1, 1)
        
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
                float2 uv_noise : TEXCOORD1;
                float4 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float2 uv_noise : TEXCOORD1;
            };

            sampler2D _MainTex;       
            sampler2D _Lines; 
            float4 _MainTex_ST;
            float4 _Lines_ST;
            float _CU;
            float _CV;
            float _Smooth;
            float4 _ColorB;
            float4 _ColorT;
            float _Amount;
            float _Displacement;

            v2f vert (appdata v)
            {
                v2f o;  
                o.uv = TRANSFORM_TEX(v.uv, _Lines);

                float2 delta = o.uv - float2(_CU, _CV);
                float radius = length(delta);
                float angle = atan2(delta.x, delta.y) * 2 / UNITY_TWO_PI;

                float ux = angle;
                float vy = radius;

                float d = tex2Dlod(_Lines, float4(float2(ux, vy + _Time.x), 0, 0)).r;
                v.normal = normalize(v.normal);
                v.vertex += v.normal * d * _Displacement;

                o.vertex = UnityObjectToClipPos(v.vertex);                
                o.uv_noise = v.uv_noise;
                return o;
            }            

            float sides (float2 p, float s)
            {
                float r = 0.001;

                float ls = 1 - smoothstep(p.x - s, p.x + s, r);
                float rs = 1 - smoothstep(1 - p.x - s, 1 - p.x + s, r);
                float us = 1 - smoothstep(p.y - s, p.y + s, r);
                float ds = 1 - smoothstep(1 - p.y - s, 1 - p.y + s, r);

                float u = min(ls, rs);
                float v = min(us, ds);

                return min(u, v);
            }

            float circle (float2 p, float r, float s, float2 center)
            {
                float c = length(p - center);
                return smoothstep(c - s, c + s, r);
            }

            float2 Unity_PolarCoordinates_float(float2 UV, float2 Center, float RadialScale, float LengthScale)
            {
                float2 delta = UV - Center;
                float radius = length(delta) * RadialScale;
                float angle = atan2(delta.x, delta.y) * 1.0 / UNITY_TWO_PI * LengthScale;
                return float2(radius, angle);
            }

            inline float unity_noise_randomValue (float2 uv)
            {
                return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
            }

            inline float unity_noise_interpolate (float a, float b, float t)
            {
                return (1.0 - t) * a + ( t * b);
            }

            inline float unity_valueNoise (float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                f = f * f * (3.0 - 2.0 * f);

                uv = abs(frac(uv) - 0.5);
                float2 c0 = i + float2(0.0, 0.0);
                float2 c1 = i + float2(1.0, 0.0);
                float2 c2 = i + float2(0.0, 1.0);
                float2 c3 = i + float2(1.0, 1.0);
                float r0 = unity_noise_randomValue(c0);
                float r1 = unity_noise_randomValue(c1);
                float r2 = unity_noise_randomValue(c2);
                float r3 = unity_noise_randomValue(c3);

                float bottomOfGrid = unity_noise_interpolate(r0, r1, f.x);
                float topOfGrid = unity_noise_interpolate(r2, r3, f.x);
                float t = unity_noise_interpolate(bottomOfGrid, topOfGrid, f.y);
                return t;
            }

            float Unity_SimpleNoise_float(float2 UV, float Scale)
            {
                float t = 0.0;

                float freq = pow(2.0, float(0));
                float amp = pow(0.5, float(3-0));
                t += unity_valueNoise(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

                freq = pow(2.0, float(1));
                amp = pow(0.5, float(3-1));
                t += unity_valueNoise(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

                freq = pow(2.0, float(2));
                amp = pow(0.5, float(3-2));
                t += unity_valueNoise(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;

                return t;
            }            

            fixed4 frag (v2f i) : SV_Target
            {                             
                float4 light = circle(i.uv, 0.05, 0.1, float2(_CU, _CV));

                float t = sides(i.uv, _Smooth);
                float c = circle(i.uv, 0.35, 0.25, 0.5);                
               
                float2 polar = Unity_PolarCoordinates_float(i.uv, float2(_CU, _CV), 1, 2);  
                
                float u = polar.y;
                float v = (1 - polar.x) * t;

                float noise = Unity_SimpleNoise_float(i.uv_noise, 30);  
                noise *= _Amount;

                float2 coords = float2(u + noise, v + noise);
                float speed = _Time.y;

                float4 col = tex2D(_MainTex, float2(coords.x + speed * 0.1, coords.y + speed * 0.20));
                float4 lin = tex2D(_Lines, float2(coords.x + speed * 0.1, coords.y + speed * 0.15)) * 0.2;
                col += lin;

                return (col * c + light) * _ColorB + _ColorT;
            }
            ENDCG
        }
    }
}
