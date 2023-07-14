Shader "USB/USB_specular_reflectance"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        // let's add some properties to calculate the the specular reflection
        _SpecularTex ("Specular Texture", 2D) = "black" {}  // add specular
        _SpecularInt ("Specular Intensity", Range(0, 1)) = 0.5
        _SpecularPow ("Specular Power", Range(1, 128)) = 64
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}
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
            // let's add the conection variables for the properties
            sampler2D _SpecularTex; 
            float _SpecularInt;
            float _SpecularPow;            
            float4 _LightColor0; 

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                //o.normal_world = normalize(mul(unity_ObjectToWorld, float4(v.normal, 0))).xyz;
                o.normal_world = UnityObjectToWorldNormal(v.normal);
                o.vertex_world = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }
            // let's use this function to calculate the specular shading
            float3 SpecularShading
            (
                float3 colorRefl, 
                float specularInt, 
                float3 normal, 
                float3 lightDir, 
                float3 viewDir, 
                float specularPow
            )
            {     
                // h is the halfway vector
                float3 h = normalize(lightDir + viewDir);
                return colorRefl * specularInt * pow(max(0, dot(normal, h)), specularPow);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                half3 normal = i.normal_world;
                half3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                half3 colorRefl = _LightColor0.rgb;
                half3 specCol = tex2D(_SpecularTex, i.uv) * colorRefl;
                half3 viewDir = normalize(_WorldSpaceCameraPos - i.vertex_world);
                // initialize the SpecularShading function and store it into the spectular vector
                half3 specular = SpecularShading(specCol, _SpecularInt, normal, lightDir, viewDir, _SpecularPow);
                // add the pectular shading to the texture color RGB
                col.rgb += specular;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
