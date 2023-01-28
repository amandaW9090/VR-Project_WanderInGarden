Shader "Unlit/StoneWithMoss"
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

        _FurColor_1("FurColor1",color)=(1,1,1,1)
        _FurColor_2("FurColor2",color)=(1,1,1,1)
        _LayerTex("LayerTex",2D)="white" {}
        _FurLength("FurLength",Range(0,1))=0.1

        _MossHeight("MossHeight",Range(0.4,1))=0.5
        _EdgeFade("EdgeFade",Range(0.3,1))=0.3
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha

        CGINCLUDE

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

            fixed4 _FurColor_1;
            fixed4 _FurColor_2;
            sampler2D _LayerTex;
            float4 _LayerTex_ST;
            float _FurLength;

            float _MossHeight;
            float _EdgeFade;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal:TEXCOORD1;
                float3 worldPos:TEXCOORD2;
                //float2 noiseUV:TEXCOORD3;
            };

        v2f vert_internal(appdata_tan v,fixed Fur_Offset)
        {
        v2f o;
        v.vertex.xyz+=v.normal*_FurLength*Fur_Offset;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.uv=v.texcoord;
        o.worldNormal=UnityObjectToWorldNormal(v.normal);
        o.worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;

        return o;
        }

        fixed4 frag_internal(v2f i,fixed Fur_Offset)
        {
        float3 worldView=normalize(UnityWorldSpaceViewDir(i.worldPos));
        fixed3 worldNormal=normalize(i.worldNormal);
        fixed moss=saturate(dot(fixed3(0,1,0),worldNormal));
        moss=smoothstep(_MossHeight-0.4,_MossHeight,moss);

        float2 noiseUV=TRANSFORM_TEX(i.uv,_NoiseTex);
        fixed noise=saturate(tex2D(_NoiseTex,noiseUV*3).r+0.5*tex2D(_NoiseTex,noiseUV*3.5).r);
        fixed3 c=lerp(_FurColor_1,_FurColor_2,noise).rgb;

        fixed a=step(Fur_Offset*Fur_Offset,tex2D(_LayerTex,TRANSFORM_TEX(i.uv,_LayerTex)).r);
        a=saturate(a+dot(worldNormal,worldView)-_EdgeFade);
        a*=(1-Fur_Offset)*moss*tex2D(_NoiseTex,noiseUV*1.5).r;
        
        return fixed4(c,a);
        }

        v2f vert0(appdata_tan v)
        {
        return vert_internal(v,0);
        }

        v2f vert1(appdata_tan v)
        {
        return vert_internal(v,0.25);
        }

        v2f vert2(appdata_tan v)
        {
        return vert_internal(v,0.5);
        }

        v2f vert3(appdata_tan v)
        {
        return vert_internal(v,0.75);
        }

        v2f vert4(appdata_tan v)
        {
        return vert_internal(v,1);
        }

        fixed4 frag0(v2f i):SV_TARGET
        {
            float2 offsetUV=abs(i.uv-float2(0.5,0.5));
            float blendFactor=2.5*dot(float2(offsetUV.x,offsetUV.y),float2(offsetUV.x,offsetUV.y));
            blendFactor=smoothstep(_TopFactor-0.3,_TopFactor,1-blendFactor);
            fixed3 c=lerp(_BottomColor,_TopColor,blendFactor).rgb;

            float3 worldView=normalize(UnityWorldSpaceViewDir(i.worldPos));
            float3 worldNormal=normalize(i.worldNormal);
            fixed edgeFactor=smoothstep(0,1-_EdgeThickness,1-dot(worldNormal,worldView));
            fixed fresnel=_FresnelScale+(1-_FresnelScale)*pow(edgeFactor,5);

            float2 noiseUV=TRANSFORM_TEX(i.uv,_NoiseTex);
            fixed noise=tex2D(_NoiseTex,noiseUV).r;
            fixed3 finalColor=lerp(_DarkColor.rgb,c,pow(saturate(noise+1-fresnel),_StrokeFactor));

            return fixed4(finalColor,1);
        }

        fixed4 frag1(v2f i):SV_TARGET
        {
        return frag_internal(i,0.25);
        }

        fixed4 frag2(v2f i):SV_TARGET
        {
        return frag_internal(i,0.5);
        }

        fixed4 frag3(v2f i):SV_TARGET
        {
        return frag_internal(i,0.75);
        }

        fixed4 frag4(v2f i):SV_TARGET
        {
        return frag_internal(i,1);
        }

        ENDCG

        Pass
        {
            CGPROGRAM
            #pragma vertex vert0
            #pragma fragment frag0
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert1
            #pragma fragment frag1
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert2
            #pragma fragment frag2
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert3
            #pragma fragment frag3
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert4
            #pragma fragment frag4
            ENDCG
        }
        
    }
}
