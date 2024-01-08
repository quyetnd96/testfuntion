Shader "LearningShader/Flow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FlowTex ("FlowTex", 2D) = "white" {}
        _UVTex ("UVTex", 2D) = "white" {}
        _MinusTexUV("MinusTexUV", 2D)="white" {}
        _FlowSpeed_Tile("FLow Speed/ Tile",vector)=(0,0,0,0)
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
                float4 uv : TEXCOORD0;
                
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _FlowTex;
            sampler2D _UVTex;
            sampler2D _MinusTexUV;
            float4 _MinusTexUV_ST;
            float4 _FlowSpeed_Tile;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.uv, _MinusTexUV);
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col_uv1=tex2D(_MinusTexUV, i.uv.xy);
                fixed4 col_uv2 = tex2D(_UVTex, i.uv.xy);
                fixed4 uv=(0,0,0,0);
                if(col_uv1.a==0)
                {
                    uv=0;
                    fixed4 main = tex2D(_MainTex, i.uv.xy);
                    return fixed4(main.rgb,0);
                }
                else
                {
                    uv = tex2D(_UVTex, i.uv.xy);
                    uv.rg*=_FlowSpeed_Tile.zw;
                    uv.rg+= frac(_Time.y*_FlowSpeed_Tile.xy);
                    fixed4 flow = tex2D(_FlowTex, uv.rg)*uv.a;
                    fixed4 main = tex2D(_MainTex, i.uv.xy)*(1-uv.a*flow.a);
                    return flow+main;
                } 
            }
            ENDCG
        }
    }
}
