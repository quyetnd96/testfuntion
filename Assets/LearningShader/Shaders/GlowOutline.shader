Shader "UI/GlowOutline"
{
    Properties
    {

        _Intensity("Intensity",Range(1,10))=1
        _Radius ("Radius", Range(0.0, 1)) = 0.3
        _Smooth ("Smooth", Range(0.0, 0.5)) = 0.01
        _X ("X", Range(0.0, 0.5)) = 0.01
    }
    SubShader
    {
        Tags { "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
        LOD 200
        Blend SrcAlpha OneMinusSrcAlpha
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            sampler2D _MainTex;
            struct appdata_t
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float2 uv : TEXCOORD0;
            };
            struct v2f
            {
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
                float2 uv : TEXCOORD0;
            };
            fixed4 _Color;
            float _Intensity;
            float _Radius;
            float _X;
            float _Y;
            float _Smooth;
            v2f vert (appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.color = v.color;
                o.uv = v.uv;
                return o;
            }
            float circle (float2 p, float center, float radius, float smooth)
            {
                float c = length(p - center);
                return smoothstep(c - smooth, c + smooth, radius);
            }
            fixed4 frag (v2f i) : SV_Target
            {
                float4 baseColor = tex2D(_MainTex, i.uv) * i.color;
                float2 uvStep = ddx(i.uv);
                fixed4 outline = tex2D(_MainTex, i.uv) *_Intensity;
                fixed4 outlineColor=_Color;
                float center = _X;
                return lerp(baseColor, outline, circle(i.uv,center,_Radius,_Smooth));
                // return outline;
            }
            ENDCG
        }
    }
}












