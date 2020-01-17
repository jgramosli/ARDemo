// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "GlobalEnglish/Unlit (with lightmaps)"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Tint("Color Tint", Color) = (1,1,1,1)
		_Exposure("Exposure", Float) = 1.0
		_CloudsInfluence("CloudsInfluence", Range(0, 1)) = 1
		_StencilRef("Stencil", Int) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			Lighting Off

			Stencil
			{
				Ref [_StencilRef]
				Comp Always
				Pass Replace
			}

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON
			#pragma multi_compile ___ BATCHING_ON

			#if defined(SHADER_API_D3D9)
    			#pragma target 3.0
			#endif

			#include "UnityCG.cginc"
			#include "Internals/Clouds.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				float4 color : COLOR;
				float4 normal : NORMAL;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				float4 vertex : SV_POSITION;
				float4 normal : NORMAL;
				float2 cloudUVs : TEXCOORD2;
				float4 color : TEXCOORD3;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _MainTex_TexelSize;
			float4 _Tint;
			float _Exposure;
			float _CloudsInfluence;

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
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.color = v.color;
				o.uv = TRANSFORM_TEX( v.uv, _MainTex );
				o.uv2.xy = v.uv2.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				o.normal = v.normal;

				o.cloudUVs = CalculateCloudUVs(v.vertex);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
#if BATCHING_ON
				float2 uv;
				uv.x = frac( i.uv.x ) * i.color.b + i.color.r;
				uv.y = frac( i.uv.y ) * i.color.a + i.color.g;
#else
				float2 uv = i.uv;
#endif

				fixed4 col = tex2Dlod(_MainTex, float4( uv, 0, GetMipmapLevel( i.uv )));
				fixed4 cloudColour = CalculateCloudContribution(i.cloudUVs, _CloudsInfluence);
#if LIGHTMAP_ON
				
				float3 lightMap = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv2));
				col.rgb *= min(lightMap, cloudColour.rgb);
#else
				col.rgb *= cloudColour.rgb;
#endif
				col.rgb *= _Tint * _Exposure;
				col.a = 1;
				
				return col;
			}	

			ENDCG
		}
	}
}
