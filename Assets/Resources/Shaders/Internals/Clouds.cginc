sampler2D _CloudTex;

float4x4 _CloudCameraView;
float4x4 _CloudCameraProjection;

float2 _CloudMovementDirection;
float _CloudSpeed;
float _CloudStrength;
int _CloudsEnabled;

static const fixed4 _White = fixed4(1, 1, 1, 1);

float4 CalculateCloudViewPos(float4 vertex)
{
	float4 cloudViewPos;

	cloudViewPos = mul(unity_ObjectToWorld, vertex);
	cloudViewPos = mul(_CloudCameraView, cloudViewPos);
	cloudViewPos = mul(_CloudCameraProjection, cloudViewPos);

	return cloudViewPos;
}

float2 CalculateCloudUVs(float4 vertex)
{
	float4 cloudViewPos;

	cloudViewPos = mul(unity_ObjectToWorld, vertex);
	cloudViewPos = mul(_CloudCameraView, cloudViewPos);
	cloudViewPos = mul(_CloudCameraProjection, cloudViewPos);

	float2 projectedCoords;
	projectedCoords.x = cloudViewPos.x / cloudViewPos.w / 2.0 + 0.5;
	projectedCoords.y = cloudViewPos.y / cloudViewPos.w / 2.0 + 0.5;

	return projectedCoords + (_Time * _CloudMovementDirection * _CloudSpeed);
}

fixed4 CalculateCloudContribution(float2 cloudUVs, float cloudInfluence)
{
	cloudUVs = frac(cloudUVs);

	if (cloudUVs.x < 0)
		cloudUVs.x = 1.0 + cloudUVs.x;
	else if (cloudUVs.x > 1)
		cloudUVs.x = cloudUVs.x - 1.0;

	float cloudsEnabledFactor = floor(_CloudsEnabled);

	// sample the texture
	fixed4 cloudColour = tex2D(_CloudTex, cloudUVs);

	fixed4 cloudContribution = lerp(fixed4(1.0, 1.0, 1.0, 1.0), cloudColour, cloudsEnabledFactor);

	//Cloud Influence should be either 0 or 1 and acts as a toggle for showing clouds or not on
	//a per-material basis.
	return fixed4(lerp(_White.rgb, cloudContribution.rgb, cloudInfluence * _CloudStrength), cloudContribution.a);
}

fixed4 CalculateCloudContribution(float2 cloudUVs)
{
	return CalculateCloudContribution(cloudUVs, 1);
}