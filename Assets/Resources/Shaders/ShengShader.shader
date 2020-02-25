// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "GlobalEnglish/ShengShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_ColorTint("Color Tint", Color) = (1,1,1,1)
		_ColorRecolor("Recolor Color", Color) = (1,1,1,1)
		_AmbientColor("Ambient", Color) = (0.75,0.75,0.75,1)
		_DiffuseStrength("Diffuse Strength", Range( 0, 1 )) = 0.5
		_RecolorStrength( "Recolor Strength", Range( 0, 1 )) = 0

		_CloudsInfluence("Clouds Influence", Range(0, 1)) = 1
		_LightProbeInfluence("Light Probe Influence", Range(0, 1)) = 1

		_StencilRef("Stencil", Int) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
	
		Pass
		{
			Tags{ "LightMode" = "ForwardBase" }

			Stencil
			{
				Ref [_StencilRef]
				Comp Always
				Pass Replace
			}

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile ___ BATCHING_ON
			#pragma multi_compile ___ LIGHT_PROBES_ON

			#if defined(SHADER_API_D3D9)
    			#pragma target 3.0
			#endif

			#include "UnityCG.cginc"
			#include "Internals/Clouds.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 normal : NORMAL;
				float4 color : COLOR;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
				float lightDot : TEXCOORD1;
				float2 cloudUVs : TEXCOORD2;
				float3 normal : NORMAL;
			};

			sampler2D _MainTex;
			float4 _MainTex_TexelSize;
			float4 _MainTex_ST;

			float4 _ColorTint;
			float4 _ColorRecolor;
			float4 _AmbientColor;

			float _DiffuseStrength;
			float _RecolorStrength;

			float _CloudsInfluence;
			float _LightProbeInfluence;

			int _StencilRef;

			float GetMipmapLevel(float2 textureUV)
			{
				float2 dx = ddx(textureUV * _MainTex_TexelSize.x);
				float2 dy = ddy(textureUV * _MainTex_TexelSize.y);
				float1 d = max(dot(dx, dx), dot(dy, dy));

				return min( log2(max(d, 1)) * 0.5f, 3 );
			}

			v2f vert (appdata v)
			{
				float3 normalDirection = normalize( mul(float4(v.normal, 0.0), unity_WorldToObject).xyz );

				float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);

				float lightDot = max(0.0, dot(normalDirection, lightDirection));

				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = normalDirection;
				o.lightDot = lightDot;
				o.cloudUVs = CalculateCloudUVs(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 texColor = tex2Dlod(_MainTex, float4( i.uv, 0, GetMipmapLevel( i.uv )));
				// sample the texture
				fixed4 c = texColor;

				float keyStrength = ((abs(c.r - c.g) + abs(c.r - c.b) + abs(c.g - c.b)) / 2);
				float intensity = ((c.r + c.g + c.b) / 3);
				c = fixed4(intensity, intensity, intensity, 1 );
				fixed3 col = fixed3(lerp(c.rgb, _ColorRecolor, keyStrength));

				col = texColor * (1 - _RecolorStrength) + col * _RecolorStrength;
				fixed4 recolor = fixed4( col, c.a );

				fixed4 ambientOutput = recolor * _AmbientColor;
				fixed4 diffuseOutput = recolor * i.lightDot * _DiffuseStrength;

				fixed4 outputColor = ( ambientOutput + diffuseOutput ) * _ColorTint;

				fixed4 cloudColour = CalculateCloudContribution(i.cloudUVs, _CloudsInfluence);
				outputColor *= cloudColour;

#if LIGHT_PROBES_ON
				outputColor.rgb *= lerp(float3(1.0, 1.0, 1.0), ShadeSH9 (float4(i.normal,1.0)), _LightProbeInfluence);
#endif
				return outputColor;
			}
			ENDCG
		}
	}
}
