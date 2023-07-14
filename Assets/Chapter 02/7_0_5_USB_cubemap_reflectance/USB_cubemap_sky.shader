Shader "USB/USB_cubemap_sky"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}      
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

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // get the vertex output normal
                half3 normal = i.normal_world;
                // calculate the view direction using UnityWorldSpaceViewDir function
                float3 viewDir = normalize(UnityWorldSpaceViewDir(i.vertex_world));
                // calculate the world reflection
                float3 world_reflect = reflect(-viewDir, i.normal_world);
                // get the sky data from the default Reflection Probe
                half4 skyData = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, world_reflect);
                // decode the sky color in High Dynamic Range
                half3 skyColor = DecodeHDR(skyData, unity_SpecCube0_HDR);
                // add the skycolor to the texture color RGB
                col.rgb = skyColor;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);                
                return col;
            }
            ENDCG
        }
    }
}
