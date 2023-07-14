Shader "LearningShader/TestLightingShaderFromUnlit"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap ("Normal Map", 2D) = "white" {}
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
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float2 uv_normal : TEXCOORD1;

                float4 vertex : SV_POSITION;                
                float4 tangent_world : TEXCOORD2;
                float3 binormal_world : TEXCOORD3;
                float3 normal_world : TEXCOORD4; 
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NormalMap;
            float4 _NormalMap_ST;
            float4 _LightColor0; 
            v2f vert (appdata v)
            {
               v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f, o); 
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv_normal=TRANSFORM_TEX(v.uv,_MainTex);
                o.normal_world=normalize(mul(unity_ObjectToWorld, float4(v.normal,0)));
                o.tangent_world=normalize(mul(v.tangent,unity_WorldToObject));
                o.binormal_world=normalize(cross(o.normal_world,o.tangent_world)*v.tangent.w);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                float4 normal_map = tex2D(_NormalMap, i.uv_normal);
                // apply fog
                float3x3 TBN_matrix = float3x3
                (
                    i.tangent_world.xyz, 
                    i.binormal_world, 
                    i.normal_world
                );
                float3 lightColor = _LightColor0;
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 normal_color = normalize(mul(normal_map , TBN_matrix));
                float3 diffuse_lambert=lightColor*max(0, dot(normal_color, lightDir));
                col.rgb*=diffuse_lambert;
                return col;
            }
            ENDCG
        }
    }
}
