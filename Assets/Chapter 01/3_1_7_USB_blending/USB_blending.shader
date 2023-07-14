Shader "USB/USB_blending"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // if you want to use transparent textures, make sure to change the RenderType and the Queue to Transparent
        Tags 
        { 
            "RenderType"="Transparent" 
            "Queue"="Transparent"
        }        
        // this shader is additive because its Blending is One One
        // you can use all these Blending variables to change the final effect
        // in case you get Z-fighting then disable the Z-Buffer / Depth Buffer by adding "ZWrite Off"
        ZWrite Off 
        
        // Blend SrcAlpha OneMinusSrcAlpha
        Blend One One    
        // Blend OneMinusDstColor One
        // Blend DstColor Zero
        // Blend DstColor SrcColor   
        // Blend SrcColor One
        // Blend OneMinusSrcColor One
        // Blend Zero OneMinusSrcColor

        // by default the Blending operation is "Add" but you could use all these variables to change the final effect        
        BlendOp Add
        // BlendOp Sub
        // BlendOp RevSub
        // BlendOp Min
        // BlendOp Max

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
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

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
                return col;
            }
            ENDCG
        }
    }
}
