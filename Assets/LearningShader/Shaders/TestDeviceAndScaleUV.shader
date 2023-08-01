Shader "Unlit/TestDeviceAndScaleUV"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _ScaleUV("ScaleUV",Range(1, 10)) = 3
        _ScaleUVElement("ScaleUVElement",Range(1, 10)) = 3 
        _Color("Color", Color) = (0,0,0)
        _CenterX("Center",Range(0,0.9))=0.1
        _CenterY("Center",Range(0,0.9))=0.1

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
            float _CenterX;
            float _CenterY;
            float _ScaleUVElement;
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
                i.uv.x = (i.uv.x - _CenterX);
                i.uv.y = (i.uv.y - _CenterY);
                i.uv*= _ScaleUV;
                
                 
                if((i.uv.x>0.0 && i.uv.x<1.0) && (i.uv.y>0.0 && i.uv.y<1.0) && col1.a>0.0)
                {
                    i.uv*=_ScaleUVElement;
                    fixed4 col2 = tex2D(_MainTex, i.uv);
                    float4 baseColorCol2 = tex2D(_MainTex, i.uv) * i.color;
                    fixed4 finishedCol=fixed4(baseColorCol1.rgb,testalpha(col1.a));
                    return finishedCol;
                }
                else if((i.uv.x>1.0 && i.uv.x<2.0) && (i.uv.y>1.0 && i.uv.y<2.0) && col1.a>0)
                {
                    i.uv*=_ScaleUVElement;
                    fixed4 col2 = tex2D(_MainTex, i.uv);
                    float4 baseColorCol2 = tex2D(_MainTex, i.uv) * i.color;
                    fixed4 finishedCol=fixed4(baseColorCol1.rgb,testalpha(col1.a));
                    return finishedCol;
                    
                }
                else if((i.uv.x>2.0 && i.uv.x<3.0) && (i.uv.y>2.0 && i.uv.y<3.0) && col1.a>0)
                {
                    i.uv*=_ScaleUVElement;
                    fixed4 col2 = tex2D(_MainTex, i.uv);
                    float4 baseColorCol2 = tex2D(_MainTex, i.uv) * i.color;
                    fixed4 finishedCol=fixed4(baseColorCol1.rgb,testalpha(col1.a));
                    return finishedCol;
                    
                } 
                else
                {
                    return 0;
                }
            }
            ENDCG
        }
    }
}
