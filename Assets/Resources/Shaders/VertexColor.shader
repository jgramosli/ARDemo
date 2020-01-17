// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "GlobalEnglish/Vertex Blend1 with Alpha"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_CloudsInfluence("CloudsInfluence", Range(0, 1)) = 1
	}
	SubShader
	{
		Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
		LOD 100

		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha
			ZWrite Off
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON

			#include "UnityCG.cginc"
			#include "Internals/Clouds.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				float4 color : COLOR;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float2 uv2 : TEXCOORD1;
				float4 vertex : SV_POSITION;
				float4 color : COLOR;
				float2 cloudUVs : TEXCOORD2;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;

			float _CloudsInfluence;
		
			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.uv2.xy = v.uv2.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				o.color = v.color;

				o.cloudUVs = CalculateCloudUVs(v.vertex);
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				// sample the texture
				fixed4 col = tex2D(_MainTex, i.uv) * i.color;

				fixed4 cloudColour = CalculateCloudContribution(i.cloudUVs, _CloudsInfluence);

#if LIGHTMAP_ON
				float3 lightMap = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv2));
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
