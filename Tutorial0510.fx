//--------------------------------------------------------------------------------------
// File: Tutorial0510.fx
//
// Copyright (c) Microsoft Corporation. All rights reserved.
//--------------------------------------------------------------------------------------

//DEBUG
//fxc /Od /Zi /T fx_4_0 /Fo BasicHLSL10.fxo BasicHLSL10.fx

Texture2D txDiffuse0;
Texture2D txDiffuse1;

Texture2D shaderTextures[20];
Texture2D bumpTexture;
int texSelect;

//--------------------------------------------------------------------------------------
// Constant Buffer Variables
//--------------------------------------------------------------------------------------
cbuffer cbNeverChanges
{
	matrix View;
};
    
cbuffer cbChangeOnResize
{
    matrix Projection;
};
    
cbuffer cbChangesEveryFrame
{
    matrix World;
	float4 vLightDir[10];
	float4 vLightColor[10];
	float4 vOutputColor;
	int		texSelectIndex;
};




SamplerState samLinear
{
    Filter = MIN_MAG_MIP_LINEAR;
    AddressU = Wrap;
    AddressV = Wrap;
};


//--------------------------------------------------------------------------------------
struct VS_INPUT
{
    float4 Pos		: POSITION;
	float4 Normal	: NORMAL;
	float2 Tex		: TEXCOORD;
	int TexNum	    : TEXNUM;
	float4 Tangent	: TANGENT;
	float4 BiNormal	: BINORMAL;

};

struct PS_INPUT
{
    float4 Pos		: SV_POSITION;
	float4 Normal	: NORMAL;
	float2 Tex		: TEXCOORD0;
	int TexNum      : TEXNUM;
	float4 Tangent	: TANGENT;
	float4 BiNormal	: BINORMAL;


};


//--------------------------------------------------------------------------------------
// Vertex Shader
//--------------------------------------------------------------------------------------
PS_INPUT VS( VS_INPUT input )
{

	

	PS_INPUT output = (PS_INPUT)0;
	   
    output.Pos = mul( input.Pos, World );
    output.Pos = mul( output.Pos, View );
    output.Pos = mul( output.Pos, Projection );
    output.Normal = mul( input.Normal, World );
    output.Tex    = input.Tex;
	output.TexNum = input.TexNum;
	output.Tangent = input.Tangent;
	output.BiNormal = input.BiNormal;

    return output;
}


//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
float4 PS( PS_INPUT input) : SV_Target
{

			float4 bumVal = bumpTexture.Sample( samLinear, input.Tex ) * 2. - 1;
		//float bumpNorm = input.Normal + bumVal.x * input.BiNormal + bumVal.y * input.Tangent;
		//float bumpNorm = input.Normal + bumVal.x * input.BiNormal + bumVal.y * input.Tangent;
		//bumpNorm = bumpNorm * 2. - 1.;

        float4 LightColor = 0;
        
        //do NdotL lighting for x lights
        for(int i=0; i<4; i++)
        {
            //LightColor += saturate( dot( (float3)vLightDir[i],input.Normal) * vLightColor[i]);
            LightColor += saturate( dot( (float3)vLightDir[i],(float3)bumVal) * vLightColor[i]);
        }

		if( texSelect == input.TexNum)
			return float4( 0.0, 1.0, 0.0, 0.0 );

		if( texSelect == -2 )
			return float4( 0.0, (1.0 -( (float)input.TexNum * .10)), 0.0, 1.0 );

		int texnum = input.TexNum;




		//quick hack to make to expand it to large values. change 10 if more than 10 tex on an object
		for( int i = 0; i < 10; i++ )
		{
			if( i == input.TexNum )
			{
				return shaderTextures[i].Sample( samLinear, input.Tex )*LightColor;//*bumpNorm;

			}
		}
//
		//if this is white you got issues
		return float4( 1.0, 1.0, 1.0, 1.0 );

}

//--------------------------------------------------------------------------------------
// PSSolid - render a solid color
//--------------------------------------------------------------------------------------
float4 PSSolid( PS_INPUT input) : SV_Target
{
    return vOutputColor;
}


//--------------------------------------------------------------------------------------
technique10 Render
{
    pass P0
    {
        SetVertexShader( CompileShader( vs_4_0, VS() ) );
        SetGeometryShader( NULL );
        SetPixelShader( CompileShader( ps_4_0, PS() ) );
    }
}

//--------------------------------------------------------------------------------------
technique10 RenderLight
{
    pass P0
    {
        SetVertexShader( CompileShader( vs_4_0, VS() ) );
        SetGeometryShader( NULL );
        SetPixelShader( CompileShader( ps_4_0, PSSolid() ) );
    }
}
