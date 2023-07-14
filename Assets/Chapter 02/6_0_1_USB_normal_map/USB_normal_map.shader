Shader "USB/USB_normal_map"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        // let's add some properties to dynamically modify the normal map
        _NormalMap ("Normal Map", 2D) = "white" {}
        _Diffuse ("Light Intencity", Range(0, 1)) = 1
    }
    SubShader
    {    
        Pass
        {
            Tags { "RenderType"="Opaque" "LightMode"="ForwardBase"}
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
            // the normal map is a texture so we need a conection variable
            sampler2D _NormalMap;
            // like a texture, we need tiling and offset for the texture normal map
            float4 _NormalMap_ST;
            // let's add a conection variable for the diffuse color
            float _Diffuse;
            // _LightColor0 is an internal variable and has been included in UnityCg.cginc
            float4 _LightColor0;            

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f, o); 
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                o.uv_normal = TRANSFORM_TEX(v.uv, _NormalMap);
                // UnityObjectToWorldNormal contains the calculation for world normal 
                // normalize(mul(unity_ObjectToWorld, float4(v.normal, 0)));
                o.normal_world = UnityObjectToWorldNormal(v.normal);
                o.tangent_world = normalize(mul(v.tangent, unity_WorldToObject));
                o.binormal_world = normalize(cross(o.normal_world, o.tangent_world) * v.tangent.w);

                return o;
            }            
            
            // this function is used when the shader need DXT compression
            float3 DXTCompression (float4 normalMap)
            {
                #if defined(UNITY_NO_DXT5nm)
                    return normalMap.rgb * 2 - 1;
                #else   // UnpackNormalSTX5nm
                    float3 normalCol;
                    normalCol = float3 (normalMap.a * 2 - 1, normalMap.g * 2 - 1, 0);

                    // the b color can be calculated in different ways
                    // normalCol.b = sqrt(1 - dot(normalCol, normalCol));
                    // normalCol.b = sqrt(1 - (pow(normalCol.r, 2) + pow(normalCol.g, 2)));
                    normalCol.b = sqrt(1 - saturate(dot(normalCol.xy, normalCol.xy)));
                    return normalCol;
                #endif
            }   

            float3 DiffuseLambert(float3 normalCol, float3 lightDir, float3 lightColor, float diffuseFactor)
            {
                return lightColor * diffuseFactor * max(0, dot(normalCol, lightDir));
            }         

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // Color at Pixel which we read from Tangent space normal map
				float4 normal_map = tex2D(_NormalMap, i.uv_normal);				
				// Normal value converted from Color value
				float3 normal_compressed = DXTCompression(normal_map);
                // instead of DXTCompression we can use UnpackNormals, it's the same function	
                // float3 normal_compressed = UnpackNormal(normal_map);	

				// Let's create the TBN matrix
				float3x3 TBN_matrix = float3x3
                (
                    i.tangent_world.xyz, 
                    i.binormal_world, 
                    i.normal_world
                );
				float3 normal_color = normalize(mul(normal_compressed , TBN_matrix));
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float3 lightColor = _LightColor0;
                float3 diffuse_lambert = DiffuseLambert(normal_color, lightDir, lightColor, _Diffuse);
                
                // let multiply the texture color RGB by the diffuse shading. It includes the normal map
                col.rgb *= diffuse_lambert;
                return col;
            }
            ENDCG
        }        
    }
}
