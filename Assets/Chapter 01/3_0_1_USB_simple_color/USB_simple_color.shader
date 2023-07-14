Shader "USB/USB_simple_color"
{
    Properties
    {
        // by default only a texture is included in a Unlit Shader
        _MainTex ("Texture", 2D) = "white" {}
        // if you want to add "color tint" to change the texture color you should add a Color property
        _Color ("Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        // by default our shader is "Opaque" (without transparency). Tags { "RenderType" = "Opaque" }
        // if you want to add transparency you should modify the Render Type, the Queue and also add a Blending mode
        Tags 
        { 
            "RenderType"="Transparent" 
            "Queue"="Transparent"
        }
        // this shader is affected by transparent textures because it has a Blending mode
        Blend SrcAlpha OneMinusSrcAlpha
        LOD 100

        Pass
        {
            CGPROGRAM   // or HLSLPROGRAM
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
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            // to connect our color property with the program, we need to add a connection variable
            float4 _Color;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                // we add color tint to the texture color by multiplication
                return col * _Color;
            }
            ENDCG   // or ENDHLSL
        }
    }
}
