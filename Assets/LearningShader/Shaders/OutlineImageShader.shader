Shader "Unlit/OutlineImageShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ScaleUV("ScaleUV",Range(1, 2)) = 1.1 
        _Color("Color", Color) = (0,0,0)
        _Emission("Emission",Range(1,100))=1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100
        Alphatomask On

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
                 float4 color : COLOR;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _ScaleUV;
            fixed4 _Color;
            float _Emission;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color=v.color;
                return o;
            }
            float testalpha(float alpha)
            {
                float alphaFull=alpha>0?1:0;
                return alphaFull;
            }
            fixed4 frag (v2f i) : SV_Target
            {
                float4 baseColorCol1 = tex2D(_MainTex, i.uv) * i.color;
                fixed4 col1 = tex2D(_MainTex, i.uv);
                i.uv = (i.uv - 0.5) * _ScaleUV + 0.5;
                fixed4 col2 = tex2D(_MainTex, i.uv);
                float4 baseColorCol2 = tex2D(_MainTex, i.uv) * i.color;
                 
                if((i.uv.x>0 && i.uv.x<1) && (i.uv.y>0 && i.uv.y<1) && col2.a>0)
                {
                    fixed4 finishedCol=fixed4(baseColorCol2.rgb,testalpha(col2.a));
                    return finishedCol;
                }
                else
                {
                   if((i.uv.x>-_ScaleUV && i.uv.x<_ScaleUV) && (i.uv.y>-_ScaleUV && i.uv.y< _ScaleUV) && col1.a>0)
                    {
                        fixed4 finishedCol=fixed4(_Color.rgb,testalpha(col1.a));
                        return finishedCol;
                    }
                    else
                    {
                        return 0;
                    }
                } 
            }
            ENDCG
        }
    }
}
