Shader "Unlit/Moss"
{
    Properties
    {
        //_MainTex ("Texture", 2D) = "white" {}
        _BaseColor("BaseColor",color)=(1,1,1,1)
        _FurColor_1("FurColor1",color)=(1,1,1,1)
        _FurColor_2("FurColor2",color)=(1,1,1,1)
        _LayerTex("LayerTex",2D)="white" {}
        _NoiseTex("NoiseTex",2D)="white" {}
        _FurLength("FurLength",Range(0,1))=0.1

    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha

        CGINCLUDE
        #include "UnityCG.cginc"

        struct v2f{
        float4 pos:SV_POSITION;
        float2 uv:TEXCOORD0;
        };

        fixed4 _BaseColor;
        fixed4 _FurColor_1;
        fixed4 _FurColor_2;
        sampler2D _LayerTex;
        float4 _LayerTex_ST;
        sampler2D _NoiseTex;
        float4 _NoiseTex_ST;
        float _FurLength;

        v2f vert_internal(appdata_tan v,fixed Fur_Offset)
        {
        v2f o;
        v.vertex.xyz+=v.normal*_FurLength*Fur_Offset;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.uv=v.texcoord;

        return o;
        }

        fixed4 frag_internal(v2f i,fixed Fur_Offset)
        {
        float2 noiseUV=TRANSFORM_TEX(i.uv,_NoiseTex);

        fixed noise=saturate(tex2D(_NoiseTex,noiseUV*2.5).r+0.5*tex2D(_NoiseTex,noiseUV*1.6).r);
        fixed3 c=lerp(_FurColor_1,_FurColor_2,noise).rgb;

        fixed a=tex2D(_NoiseTex,noiseUV).r;
        a*=(1-Fur_Offset)*step(Fur_Offset*Fur_Offset,tex2D(_LayerTex,TRANSFORM_TEX(i.uv,_LayerTex)).r);
        
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
        return fixed4(_BaseColor.rgb,1);
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
