Shader "LearningShader/USB_diffuse_shading"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _LightInt("Light Intensity", Range(0,1))=1
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
                float3 normal: NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normal_world:TEXTCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _LightInt;
            float4 _LightColor0;
            float3 LamberShading
            (
                float3 colorRefl, //Dr
                float lightInt,   //Dl
                float3 normal,    //n
                float3 lightDir   //l
            )

            {
                return colorRefl*lightInt*max(0,dot(normal,lightDir));
            }
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal_world=normalize(mul(unity_ObjectToWorld,float4(v.normal,0))).xyz;
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float3 normal=i.normal_world;
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                fixed3 colorRefl=_LightColor0.rgb;
                float3 lightDir=normalize(_WorldSpaceLightPos0.xyz);
                half3 diffuse=LamberShading(colorRefl,_LightInt,normal,lightDir);
                UNITY_APPLY_FOG(i.fogCoord, col);
                col.rgb*=diffuse;
                return col;
            }
            ENDCG
        }
    }
}
