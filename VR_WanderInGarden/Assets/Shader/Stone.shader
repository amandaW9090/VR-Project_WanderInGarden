// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/Stone"
{
    Properties
    {
        _NoiseTex ("Texture", 2D) = "white" {}
        _TopFactor("TopFactor",Range(0.5,1))=0.5
        _FresnelScale("FresnelScale",Range(0,1))=0.5
        _TopColor("TopColor",color)=(1,1,1,1)
        _BottomColor("BottomColor",color)=(1,1,1,1)
        _DarkColor("DarkColor",color)=(1,1,1,1)
        _EdgeThickness("EdgeThickness",Range(0,1))=0.2
        _StrokeFactor("StrokeFactor",Range(0,1))=0.3
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;
            fixed4 _TopColor;
            fixed4 _BottomColor;
            fixed4 _DarkColor;
            float _TopFactor;
            float _FresnelScale;
            float _EdgeThickness;
            fixed _StrokeFactor;

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal:TEXCOORD1;
                float3 worldPos:TEXCOORD2;
                float2 noiseUV:TEXCOORD3;
            };


            v2f vert (appdata_tan v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv=v.texcoord;
                o.noiseUV = TRANSFORM_TEX(v.texcoord, _NoiseTex);
                o.worldNormal=UnityObjectToWorldNormal(v.normal);
                o.worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;
                
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 offsetUV=abs(i.uv-float2(0.5,0.5));
                float blendFactor=2.5*dot(float2(offsetUV.x,offsetUV.y),float2(offsetUV.x,offsetUV.y));
                blendFactor=smoothstep(_TopFactor-0.3,_TopFactor,1-blendFactor);
                fixed3 c=lerp(_BottomColor,_TopColor,blendFactor).rgb;

                float3 worldView=normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 worldNormal=normalize(i.worldNormal);
                fixed edgeFactor=smoothstep(0,1-_EdgeThickness,1-dot(worldNormal,worldView));
                fixed fresnel=_FresnelScale+(1-_FresnelScale)*pow(edgeFactor,5);
                //fixed3 rimColor=fixed3(1-fresnel,1-fresnel,1-fresnel);

                fixed noise=tex2D(_NoiseTex,i.noiseUV).r;
                fixed3 finalColor=lerp(_DarkColor.rgb,c,pow(saturate(noise+1-fresnel),_StrokeFactor));

                return fixed4(finalColor,1);
                //return fixed4(noise+rimColor,1);
            }
            ENDCG
        }
    }
}
