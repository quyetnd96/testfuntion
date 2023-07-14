Shader "USB/USB_shadow_map_URP"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Opaque" 
            "RenderPipeline"="UniversalRenderPipeline"
        }

        LOD 100

        Pass
        {
            Tags 
            { 
                "LightMode"="UniversalForward"
            }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            //#pragma multi_compile_fog
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS

            //#include "UnityCG.cginc"
            #include "HLSLSupport.cginc" 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            //#include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                //UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
                //float3 viewDir : TEXCOORD2;
                float4 shadowCoord : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //UNITY_TRANSFER_FOG(o,o.vertex);
                o.normal = TransformObjectToWorldNormal(v.normal);
                //o.viewDir = _WorldSpaceCameraPos - TransformObjectToWorld(v.vertex);
                // VertexPositionInput pertenece a Core.hlsl
                // GetVertexPositionInputs pertenece a ShaderVariablesFunctions.hlsl, transforma los vértices a world-space
                VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
                // GetShadowCoord pertenece a Shadows.hlsl, pide como argumento a un VertexPositionInputs                
                o.shadowCoord = GetShadowCoord(vertexInput);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                Light light = GetMainLight(i.shadowCoord);
                //half s = MainLightRealtimeShadow(i.shadowCoord);

                float3 lightColor = light.color;
                float3 shadow = light.shadowAttenuation;

                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                float3 normal = normalize(i.normal);
                float NL = dot(light.direction, normal);
                
                col.rgb *= shadow;
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDHLSL
        }

        UsePass "Universal Render Pipeline/Lit/ShadowCaster"
    }
}
