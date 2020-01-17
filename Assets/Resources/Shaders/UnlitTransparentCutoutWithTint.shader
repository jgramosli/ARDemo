Shader "GlobalEnglish/UnlitTransparentCutoutWithTint"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_Cutoff ("Alpha Cutoff", Range(0.0, 1.0)) = 0.5
		_Color("Color Tint", Color) = (1,1,1,1)
	}
	
	SubShader
	{
		Tags{ "Queue"="AlphaTest" "RenderType"="TransparentCutout" "IgnoreProjector"="True" }
		LOD 100

		Pass
		{
			ZWrite On
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float4 color : COLOR;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float4 _MainTex_TexelSize;
			float4 _Color;
			float _Cutoff;

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

#if BATCHING_ON
				float2 uv;
				uv.x = min( v.color.r, v.color.r < 1 ) + v.uv.x * v.color.b;
				uv.y = min( v.color.g, v.color.g < 1 ) + v.uv.y * v.color.a;
				o.uv = TRANSFORM_TEX(uv, _MainTex);
#else
				o.uv = TRANSFORM_TEX( v.uv, _MainTex );
#endif
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2Dlod(_MainTex, float4( i.uv, 0, GetMipmapLevel( i.uv )));

				if (col.a < _Cutoff) {
					discard;
				} else {
					col.a = 1.0;
				}

				return col * _Color;
			}
			ENDCG
		}
	}
}
