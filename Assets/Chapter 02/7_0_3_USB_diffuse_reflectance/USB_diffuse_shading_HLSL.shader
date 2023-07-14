Shader "USB/USB_diffuse_shading_HLSL"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        // let's add a property to modify the light intensity
        _LightInt ("Light Intensity", Range(0, 1)) = 1 
    }
    SubShader
    {
        Tags 
        { 
            "RenderType"="Opaque" 
            "RenderPipeline"="UniversalRenderPipeline"
            // this is the first incidence of light in the first pass
            //"LightMode"="ForwardBase"
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
            #pragma multi_compile_fog
           

            //#include "UnityCG.cginc"
            //#include "AutoLight.cginc"
            // compila las variables tipo fixed4
            #include "HLSLSupport.cginc" 
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Shaders/LitInput.hlsl"

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
                float3 normal_world : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            // we need a conection variable for the light intensity property
            float _LightInt;
            // _LightColor0 is an internal variable and has been included in UnityCg.cginc
            float4 _LightColor0; 

            v2f vert (appdata v)
            {
                v2f o;
                //UNITY_INITIALIZE_OUTPUT(v2f, o);
                // space transforms.hlsl
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //UNITY_TRANSFER_FOG(o,o.vertex);
                o.normal_world = normalize(mul(unity_ObjectToWorld, float4(v.normal, 0))).xyz;
                return o;
            }

            // this is the function we need to calculate the diffuse shading
            float3 LambertShading(float3 colorRefl, float lightInt, float3 normal, float3 lightDir)
            {
                return colorRefl * lightInt * max(0, dot(normal, lightDir));
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                float3 normal = i.normal_world;
                Light light = GetMainLight();
                float3 lightDir = light.direction;
                float3 colorRefl = light.color;
                // let's declare the LambiertShading function and store it into the diffuse vector
                float3 diffuse = 0;
                diffuse = LambertShading(colorRefl, _LightInt, normal, lightDir);
                // multiply the diffuse by the texture color RGB
                col.rgb *= diffuse;
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDHLSL
        }        
    }
}
