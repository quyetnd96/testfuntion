Shader "USB/USB_fresnel_effect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        // let's add some properties to dynamically modify the fresnel effect
        _FresnelPow ("Fresnel Power", Range(1, 5)) = 2
        _FresnelInt ("Fresnel Intensity", Range(0, 1)) = 1
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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normal_world : TEXCOORD1;
                float3 vertex_world : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            // add the conection variables for the properties
            float _FresnelPow;
            float _FresnelInt;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.normal_world = normalize(mul(unity_ObjectToWorld, float4(v.normal, 0))).xyz;
                o.vertex_world = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            // this is the same function Unity uses to calculate the Fresnel Effect in Shader Grph
            void unity_FresnelEffect_float(in float3 normal, in float3 viewDir, in float power, out float Out)
            {
                Out = pow((1 - saturate(dot(normal, viewDir))), power);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                float3 normal = i.normal_world;
                float3 viewDir = normalize(_WorldSpaceCameraPos - i.vertex_world);
                float fresnel = 0;
                // let's declare the unity_FresnelEffect_float.
                // notice the output store the final fresnel color
                unity_FresnelEffect_float(normal, viewDir, _FresnelPow, fresnel);
                // add the fresnel to the texture color RGB
                col.rgb += fresnel * _FresnelInt;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);                
                return col;
            }
            ENDCG
        }
    }
}
