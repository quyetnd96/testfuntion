Shader "LearningShader/TestRGB"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Rotation("Rotation", Range(0,10))=0
        _Variable("Variable", Range(-1,1))=0
        _Variable1("Variable1", Range(-1,1))=0
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
            float _Rotation,_Variable,_Variable1;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                float2 rotUV=o.uv.xy;
                // plus variable at here to change rotation center point of all uv map.
                rotUV+=_Variable;
                //
                float s=sin(_Rotation);
                float c=cos(_Rotation);
                float2x2 rotMat=float2x2(c,-s,s,c);
                rotUV=mul(rotMat,rotUV);
                //plus variable at here to change rotation center point of uv map when new uvs=i.uv.zw*2-1;
                rotUV+=_Variable1;
                //
                o.uv.zw= rotUV;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 newUVs=i.uv.zw*2-1;
                fixed4 col = tex2D(_MainTex, i.uv.xy);
                
                float radial=atan2(newUVs.y,newUVs.x)/(UNITY_PI);
                radial=radial*0.5+0.5;
                return fixed4(col.rgb*radial.xxx,1);
            }
            ENDCG
        }
    }
}
