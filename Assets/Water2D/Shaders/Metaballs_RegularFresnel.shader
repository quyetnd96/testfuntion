

Shader "Water2D/Metaballs_RegularFresnel" 
{
Properties 
{ 
    _MainTex ("Texture", 2D) = "white" { } 
	_BackgroundTex ("BackgroundTexture", 2D) = "white" { }
	_ComparisonThreshold("Threshold Comparative", Range(0.5,0.00001)) = 0.001 
         
   // _botmcut ("Cutoff", Range(0,0.5)) = 0.1   

    //_constant ("Multiplier", Range(0,6)) = 1  

	//_AmountOfTintColor ("Intensity", Range(0,1)) = 0.3

   // _Mag ("Distortion", Range(0,3)) = 0.05
   // _Speed ("Speed", Range(0,5)) = 1.0
}
SubShader 
{
	Tags {"Queue" = "Transparent" "ForceNoShadowCasting"="True"}
    Pass {
    Blend SrcAlpha OneMinusSrcAlpha 
	
	CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag	
	#pragma shader_feature FLIP_TEXTURE
	
	#include "UnityCG.cginc"	
	

	sampler2D_half _MainTex;	
	sampler2D_half _BackgroundTex; // refract
  	fixed _AmountOfTintColor; // refract
	fixed _botmcut,_constant;
	fixed _FlipTex;
	fixed _Mag;// refrac
    fixed _Speed;//refract
	float _ComparisonThreshold;

	int _ArrayLength = 10;
	fixed4 _colors[10];
	fixed _cutoffs[10];
	fixed _multipliers[10]; // also use as AlphaStroke
	fixed4 _fresnels[10];
	fixed _styles[10];
	fixed2 _lens[10];
	fixed _mags[10];
    fixed _speeds[10];
	fixed _glossOffset = 1.0;

	uniform fixed4 background = fixed4(0,0,0,0);
	
	fixed4 DefaultFillColor = fixed4(0,0,0,1); // uses when search comparison result is false

	fixed isGammaColor = 1.0; // Gamma 1  // Linear 0

	// Optimization selective
	fixed useMultipleStylesPerScene = 1.0;
	


	struct v2f {
	    fixed4  pos : SV_POSITION;
	    fixed2  uv : TEXCOORD0;
	};	
	fixed4 _MainTex_ST;	


	fixed isCloseTo(fixed value1, fixed value2, fixed threshold)
	{
		fixed res = value1 - value2;
		if(res<0)
		res *= -1.0;

		if (res < threshold)
			return 1.0;
		else
			return 0;
	}
	
	fixed colorDistanceSQR(fixed3 value1, fixed3 value2)
	{
		//fixed rmean = ( value1.r + value2.r ) *0.5;
		fixed r = abs(value1.r - value2.r);
		fixed g = abs(value1.g - value2.g);
		fixed b = abs(value1.b - value2.b);
		
		//fixed prox = (((512.0+rmean)*r*r)>>8.0) + 4.0*g*g + (((767.0-rmean)*b*b)>>8.0);
		return (r*r + g*g + b*b);

	}

	fixed random (fixed2 uv){
        
        return frac(sin(dot(uv,fixed2(12.9898,78.233)))*43758.5453123);
    }
        

    fixed noise(fixed2 coord){
		 fixed2 i = floor(coord);
            fixed2 f = frac(coord);

            // 4 corners of a rectangle surrounding our point
            fixed a = random(i);
            fixed b = random(i + fixed2(1.0, 0.0));
            fixed c = random(i + fixed2(0.0, 1.0));
            fixed d = random(i + fixed2(1.0, 1.0));

            fixed2 cubic = f * f * (3.0 - 2.0 * f);

            return lerp(a, b, cubic.x) + (c - a) * cubic.y * (1.0 - cubic.x) + (d - b) * cubic.x * cubic.y;   
    }

	

	v2f vert (appdata_base v)
	{
	    v2f o;
		
        o.pos = UnityObjectToClipPos (v.vertex);
	    o.uv.xy = ComputeGrabScreenPos(o.pos);
		#if UNITY_UV_STARTS_AT_TOP
		
			o.uv.y = 1 - o.uv.y;
		#endif

		

	    return o;
	}	

	

	fixed4 applyFresnell(fixed4 color, fixed4 FresnelToApply)
	{

	

		fixed _FresnelExponent = 1.0;
		fixed fresnel = (1.0-FresnelToApply.a) * color.a;
		fresnel = saturate(1.0 - fresnel);
		fixed3 fresnelColor = fresnel * FresnelToApply.rgb;
    
		fresnel = pow(fresnel, _FresnelExponent);
		color.rgb += fresnelColor*fresnel;
		return color;
	}
	
	fixed4 frag (v2f i) : COLOR
	{		
			    
        if(_FlipTex == 1.0)
            i.uv.y = 1 - i.uv.y;

		fixed4 texcol,finalColor,grab2;
	    finalColor = tex2D (_MainTex, i.uv); 		
		fixed opacity = finalColor.a;
		

		//if(isGammaColor == 0.0) // for linear color mayor range is needed.
		//	thresholdComparative *= 50;//  == 1/20.;
		
		if(isGammaColor == 0.0){ // in linear

			finalColor.r = LinearToGammaSpace(finalColor.r);
			finalColor.g = LinearToGammaSpace(finalColor.g);
			finalColor.b = LinearToGammaSpace(finalColor.b);
			finalColor.a = LinearToGammaSpace(finalColor.a);

			opacity = finalColor.a;

		}
		
		fixed2 _uv = i.uv;
		int id = 0;// 9 = is the defaultFillColor used when search fails
		

		if(useMultipleStylesPerScene == 1.0) { //PROCEED TO PERFORM SEARCH FOR MULTIPLE LIQUIDS AND STYLES
			//id = 9;
			_colors[9] = background;
			fixed3 finalColorSintetized = (finalColor.rgb - ((1.0-opacity) * background.rgb))/opacity; // without alpha color
			for	(int i = 0; i < 10; i++) // repeat to the max _ArrayLength
			{

				fixed4 c = _colors[i];
				// REMEMBER TO SET EFFECT CAMERA COLOR TO BLACK (0,0,0,0) !!
			
				if(colorDistanceSQR(finalColorSintetized, c) < _ComparisonThreshold)
				{
					id = i;
					break;
				}

			}
		}
		
		
		
		

		// Regular with fresnel
		if(_styles[id] == 0.0)// Fresnel
		{
		
			if(finalColor.a < _cutoffs[id]) //if(finalColor.a < _botmcut)
			{
				finalColor.a = 0.0; //discard? 
				//if(useMultipleStylesPerScene == 0.0)finalColor.a = 0.8; //discard?
			}
			else
			{
				finalColor.a *= _multipliers[id]; //finalColor.a *= _constant;  
			}

			finalColor = applyFresnell(finalColor, _fresnels[id]);
		}
		
			
		//REFRACTING
		if(_styles[id] == 1.0)// 
		{

			
			if(finalColor.a < _cutoffs[id])
			{
				finalColor.a = 0; 
				
			}
			else
			{
				

				fixed4 backgroundColor;

				_Mag = 2.2;
				_Speed = 4.4;

				fixed time = _Time.y;
				fixed2 noisecoord1 = _uv * 8.0 * (_mags[id]);
				fixed2 noisecoord2 = _uv * 8.0 * (_mags[id]) + 4.0;
            
				fixed2 motion1 = fixed2(time * 0.3, time * -0.4) * _speeds[id];
				fixed2 motion2 = fixed2(time * 0.1, time * 0.5) * _speeds[id];
            
           
            
				fixed2 distort1 = fixed2(noise(noisecoord1 + motion1), noise(noisecoord2 + motion1)) - fixed2(0.5,0.5);
				fixed2 distort2 = fixed2(noise(noisecoord1 + motion2), noise(noisecoord2 + motion2)) - fixed2(0.5,0.5);
				fixed2 distort_sum = (distort1 + distort2) / 60.0;
			
				//if(_styles[id] == 1.0)
					finalColor = applyFresnell(finalColor, _fresnels[id]);
				
				fixed scaleL = .99;
				fixed2 _scale = fixed2(scaleL,scaleL);
				fixed2 newUV = (_uv - fixed2(0.5,0.5))* _scale + fixed2(0.5 ,0.5);
				_uv.xy = newUV.xy;
				_uv.xy += distort_sum;
				
				backgroundColor = tex2D (_BackgroundTex, _uv);
				
				if(isGammaColor == 0.0){ // in linear
					backgroundColor.r = LinearToGammaSpace(backgroundColor.r);
					backgroundColor.g = LinearToGammaSpace(backgroundColor.g);
					backgroundColor.b = LinearToGammaSpace(backgroundColor.b);
					backgroundColor.a = LinearToGammaSpace(backgroundColor.a);
				}

				finalColor = lerp(finalColor, backgroundColor , 1.0-_multipliers[id]/4.0);
				finalColor = lerp(fixed(0.5), finalColor, 1.6);
				finalColor.a = 1.0;

			}
		}

		// TOON
		if(_styles[id] == 2.0)// 
		{
		
			if(finalColor.a < _cutoffs[id]) //if(finalColor.a < _botmcut)
			{

				finalColor.a = 0.0; //discard? 
			}
			else
			{
				finalColor.a *= _multipliers[id]; //finalColor.a *= _constant;  
			}

			if(finalColor.a > 0.0 && finalColor.a < _cutoffs[id] * _multipliers[id] * 1.5)
			{
				finalColor.rgb = _fresnels[id].rgb;
				finalColor.a = 1.0;
			}
			// above commented section use an array color to put into pixel (not grab texture color)
			//else if(finalColor.a > _cutoffs[id]) {
				//finalColor.rgb = _colors[id];
			//}
			
		}

		 //Glossy
		if(_styles[id] == 3.0)// 
		{

			if(finalColor.a < _cutoffs[id]) 
			{
				finalColor.a = 0.0; 
			}
			else
			{
				finalColor.a *= _multipliers[id];
			}

			
			grab2 = tex2D (_MainTex, i.uv + fixed2(0.0108f,0.0108f)*_glossOffset);
			half4 dif = finalColor - grab2;
            
			
            
			fixed lastAlpha = finalColor.a;
            if(dif.a > 0)
            {
                finalColor = grab2;
				if(dif.a > 0.9) {
					finalColor = lerp(fixed4(1,1,1,1), finalColor,1.0-(saturate(dif.a)));
				}else{
					finalColor.a = lastAlpha;
				}
                
                
            }
			finalColor = applyFresnell(finalColor, _fresnels[id]);

        }

		 //Glossy Refract
		if(_styles[id] == 4.0)// 
		{


		
			if(finalColor.a < _cutoffs[id]) 
			{
				finalColor.a = 0.0; 
			}
			else
			{
				finalColor.a *= _multipliers[id];
			}


			
				

				grab2 = tex2D (_MainTex, i.uv + fixed2(0.0108f,0.0108f)*_glossOffset);
				half4 dif = finalColor - grab2;
            
			
            
				fixed lastAlpha = finalColor.a;
				if(dif.a > 0)
				{
					finalColor = grab2;
					if(dif.a > 0.9) {
						finalColor = lerp(fixed4(1,1,1,1), finalColor,1.0-(saturate(dif.a)));
					}else{
						finalColor.a = lastAlpha;
					}
                
                
				}

			if(finalColor.a > _cutoffs[id]) {

				fixed4 backgroundColor;

				_Mag = 2.2;
				_Speed = 4.4;

				fixed time = _Time.y;
				fixed2 noisecoord1 = _uv * 8.0 * (_mags[id]);
				fixed2 noisecoord2 = _uv * 8.0 * (_mags[id]) + 4.0;
            
				fixed2 motion1 = fixed2(time * 0.3, time * -0.4) * _speeds[id];
				fixed2 motion2 = fixed2(time * 0.1, time * 0.5) * _speeds[id];
            
           
            
				fixed2 distort1 = fixed2(noise(noisecoord1 + motion1), noise(noisecoord2 + motion1)) - fixed2(0.5,0.5);
				fixed2 distort2 = fixed2(noise(noisecoord1 + motion2), noise(noisecoord2 + motion2)) - fixed2(0.5,0.5);
				fixed2 distort_sum = (distort1 + distort2) / 60.0;
			
				
				finalColor = applyFresnell(finalColor, _fresnels[id]);
				
				fixed scaleL = .99;
				fixed2 _scale = fixed2(scaleL,scaleL);
				fixed2 newUV = (_uv - fixed2(0.5,0.5))* _scale + fixed2(0.5 ,0.5);
				_uv.xy = newUV.xy;
				_uv.xy += distort_sum;
				
				backgroundColor = tex2D (_BackgroundTex, _uv);
				
				if(isGammaColor == 0.0){ // in linear
					backgroundColor.r = LinearToGammaSpace(backgroundColor.r);
					backgroundColor.g = LinearToGammaSpace(backgroundColor.g);
					backgroundColor.b = LinearToGammaSpace(backgroundColor.b);
					backgroundColor.a = LinearToGammaSpace(backgroundColor.a);
				}




				
				finalColor = lerp(finalColor, backgroundColor , 1.0-_multipliers[id]/4.0);
				finalColor = lerp(fixed(0.5), finalColor, 1.6);
				finalColor.a = 1.0;
			}


			
			//finalColor = applyFresnell(finalColor, _fresnels[id]);

        }
								
	    return finalColor;
	}
	ENDCG

    }
}
Fallback "UnLit"
} 