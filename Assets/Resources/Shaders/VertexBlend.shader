// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "GlobalEnglish/Vertex Blend4"
{
	Properties
	{
		_MainTex1 ("Texture", 2D) = "white" {}
		_MainTex2("Texture", 2D) = "white" {}
		_MainTex3("Texture", 2D) = "white" {}
		_MainTex4("Texture", 2D) = "white" {}
		_CloudsInfluence("CloudsInfluence", Range(0, 1)) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON

			#include "UnityCG.cginc"
			#include "Internals/Clouds.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 texcoord0 : TEXCOORD0;
				float2 texcoord1 : TEXCOORD1;
				float4 color : COLOR;
			};

			struct v2f
			{
				float2 uv1 : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				float2 uv3 : TEXCOORD2;
				float2 uv4 : TEXCOORD3;
				float2 uvL : TEXCOORD4;
				float4 vertex : SV_POSITION;
				float4 color : COLOR;
				float2 cloudUVs : TEXCOORD5;
			};

			sampler2D _MainTex1;
			float4 _MainTex1_ST;
			
			sampler2D _MainTex2;
			float4 _MainTex2_ST;

			sampler2D _MainTex3;
			float4 _MainTex3_ST;

			sampler2D _MainTex4;
			float4 _MainTex4_ST;

			float _CloudsInfluence;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv1 = TRANSFORM_TEX(v.texcoord0, _MainTex1);
				o.uv2 = TRANSFORM_TEX(v.texcoord0, _MainTex2);
				o.uv3 = TRANSFORM_TEX(v.texcoord0, _MainTex3);
				o.uv4 = TRANSFORM_TEX(v.texcoord0, _MainTex4);
				o.uvL.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				o.color = v.color;
				o.cloudUVs = CalculateCloudUVs(v.vertex);

				return o;
			}


			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex1, i.uv1) * i.color.r;
				col += tex2D(_MainTex2, i.uv2) * i.color.g;
				col += tex2D(_MainTex3, i.uv3) * i.color.b;
				col += tex2D(_MainTex4, i.uv4) * (1-i.color.a);

				fixed4 cloudColour = CalculateCloudContribution(i.cloudUVs, _CloudsInfluence);
#if LIGHTMAP_ON
				float3 lightMap = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uvL));
				col.rgb *= min(lightMap, cloudColour.rgb);
#else
				col.rgb *= cloudColour.rgb;
#endif

				return col;
			}
			ENDCG
		}
	}
}
