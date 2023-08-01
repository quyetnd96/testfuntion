Shader "Unlit/SpriteOutLine"
{
    Properties
    {
		[PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
		_Color ("Main texture Tint", Color) = (1,1,1,1)
		[MaterialToggle] _OutlineEnabled ("Outline Enabled", Float) = 1
        _Thickness ("Width (Max recommended 100)", float) = 10
		_SolidOutline ("Outline Color Base", Color) = (1,1,1,1) 
    }

	SubShader
	{
		Tags
		{ 
			"Queue"="Transparent" 
			"IgnoreProjector"="True" 
			"RenderType"="Transparent" 
			"PreviewType"="Plane"
			"CanUseSpriteAtlas"="True"
		}

		Cull Off
		Lighting Off
		ZWrite Off
		Blend One OneMinusSrcAlpha

		Pass
		{
		CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile _ PIXELSNAP_ON
			#pragma exclude_renderers d3d11_9x

			#include "UnityCG.cginc"
			
			struct appdata
			{
				float4 vertex   : POSITION;
				float4 color    : COLOR;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float4 vertex   : SV_POSITION;
				fixed4 color    : COLOR;
				float2 uv  : TEXCOORD0;
			};

			fixed4 _Color;
            fixed _Thickness;
            fixed _OutlineEnabled;
			fixed4 _SolidOutline;
			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.color = v.color * _Color;
				#ifdef PIXELSNAP_ON
				o.vertex = UnityPixelSnap (o.vertex);
				#endif
				return o;
			}
			sampler2D _MainTex;
            uniform float4 _MainTex_TexelSize;
			fixed4 SampleSpriteTexture (float2 uv)
			{
				float2 offsets;
				offsets = float2(_Thickness * 2, _Thickness * 2);
				float2 bigsize = float2(_MainTex_TexelSize.z, _MainTex_TexelSize.w);
				float2 smallsize = float2(_MainTex_TexelSize.z - offsets.x, _MainTex_TexelSize.w - offsets.y);
				float2 uv_changed = float2
				(
					uv.x * bigsize.x / smallsize.x - 0.5 * offsets.x / smallsize.x,
					uv.y * bigsize.y / smallsize.y - 0.5 * offsets.y / smallsize.y
				);
				if(uv_changed.x < 0 || uv_changed.x > 1 || uv_changed.y < 0 || uv_changed.y > 1)
				{
					return float4(0, 0, 0, 0);
				}
				fixed4 color = tex2D (_MainTex, uv_changed);
				return color;
			}

			bool CheckOriginalSpriteTexture (float2 uv, bool ifZero)
			{
				float thicknessX = _Thickness / _MainTex_TexelSize.z;
				float thicknessY = _Thickness / _MainTex_TexelSize.w;
				int steps = 100;
				float angle_step = 360.0 / steps;

				float alphaCount = 0;

				// check if the basic points has an alpha to speed up the process and not use the for loop
				bool outline = false;
				float alphaCounter = 0;
				if(outline) return outline;
				for(int i = 0; i < steps; i++) // high number and not a variable to avoid stupid compiler bugs
				{
					float angle = i * angle_step * 2 * 3.14 / 360;
					if(ifZero && SampleSpriteTexture(uv + fixed2(thicknessX * cos(angle), thicknessY * sin(angle))).a == 0)
					{
						alphaCounter++;
						if(alphaCounter >= alphaCount)
						{
							outline = true;
							break;
						}
					}
					else if(!ifZero && SampleSpriteTexture(uv + fixed2(thicknessX * cos(angle), thicknessY * sin(angle))).a > 0)
					{
						outline = true;
						break;
					}
				}
				return outline;
			}
			fixed4 frag(v2f i) : SV_Target
			{
				fixed4 c = SampleSpriteTexture (i.uv) * i.color;
				c.rgb *= c.a;
				fixed4 outlineColor = fixed4(0, 0, 0, 1);

				if(_OutlineEnabled != 0)
				{
						outlineColor = _SolidOutline;
					
						if(c.a == 0 &&	CheckOriginalSpriteTexture(i.uv, false))
						{
							return outlineColor;
						}
						else
						{
							return c;
						}
				}
				else
				{
					return c;
				}

				return c;
			}
		ENDCG
		}
	}
}
