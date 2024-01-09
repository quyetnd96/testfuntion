Shader "LearningShader/SmokeLine"
{
    Properties
    {
        _MainTexure ("Main Texture", 2D) = "white" {}
        _Animate("Animate", Float)=0.5
        _Color("Color", Color)=(0,0,0,0)
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

            sampler2D _MainTexure;
            float4 _MainTexure_ST;
            float _Animate;
            float4 _Color;
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv,_MainTexure);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uvCache=i.uv;
                i.uv.x+=frac(_Animate*_MainTexure_ST.x*_Time.yy);
                float fv=(1-2*uvCache.x);
                fixed4 textureColor=tex2D(_MainTexure,i.uv);
                textureColor*=_Color*fv;
                if(textureColor.a<=0)
                {
                    return fixed4(0,0,0,0);
                }
                else
                {
                    return textureColor;
                }
            }
            ENDCG
        }
    }
}
