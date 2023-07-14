Shader "USB/USB_shadow_map"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags {"RenderType"="Opaque"}
        LOD 100

        Pass
        {
            Name "Shadow Caster"

            Tags 
            { 
                "LightMode"="ShadowCaster" 
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            struct v2f 
            { 
                V2F_SHADOW_CASTER;
                //float4 pos : SV_POSITION;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }

        Pass
        {
            Tags {"LightMode"="ForwardBase"}
        
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            //#include "UnityLightingCommon.cginc"

            #pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
            #include "AutoLight.cginc"    

            struct appdata
            {
                float4 vertex : POSITION;
                float2 texcoord : TEXCOORD0;
                //float3 normal : NORMAL;
            };     

            struct v2f
            {
                float2 uv : TEXCOORD0;
                SHADOW_COORDS(1) // put shadows data into TEXCOORD1
                fixed4 diff : COLOR0;
                float4 pos : SV_POSITION;
                fixed3 ambient : COLOR1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f, o);
                o.pos = UnityObjectToClipPos(v.vertex); // reconoce solo si la variable se llama pos
                o.uv = v.texcoord;

                //half3 worldNormal = UnityObjectToWorldNormal(v.normal);
                //half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
                //o.diff = nl * _LightColor0;

                // the only difference from previous shader:
                // in addition to the diffuse lighting from the main light,
                // add illumination from ambient or light probes
                // ShadeSH9 function from UnityCG.cginc evaluates it,
                // using world space normal                
                //o.ambient = ShadeSH9(half4(worldNormal,1));
                TRANSFER_SHADOW(o)
                return o;
            }
            
            sampler2D _MainTex;

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                fixed shadow = SHADOW_ATTENUATION(i);
                col.rgb *= shadow;

                return col;
            }
            ENDCG
        }        
    }
}
