// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Unlit/Highlight"
{
    Properties
    {
         _BaseColor("BaseColor",color)=(1,1,1,1)
        _FlowColor("FlowColor",color)=(1,1,1,1)
        _EdgeOffset("EdgeOffset",Range(0,1))=0.2
        _FlowSpeed("FlowSpeed",Range(0,5))=1
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}

        Pass
        {
            ZWrite On
            ColorMask 0

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float _EdgeOffset;

            struct a2v
            {
              float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            v2f vert(a2v v)
            {
            v2f o;
            //float3 worldPos=mul(unity_ObjectToWorld,v.vertex).xyz;
            float3 dir=float3(0,0,0)-v.vertex.xyz;
            //dir=UnityObjectToWorldDir(dir);
            v.vertex.xyz+=dir*_EdgeOffset*0.1;
            //o.pos=UnityWorldToClipPos(worldPos);
            o.pos=UnityObjectToClipPos(v.vertex);

            return o;
            }

            half4 frag(v2f i):SV_TARGET0
            {
            return half4(0,0,0,1);
            }

            ENDCG
        }

        Pass
        {
        
            ZWrite Off
            Offset 10,10

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            half4 _BaseColor;
            half4 _FlowColor;
            float _FlowSpeed;

            struct a2v
            {
              float4 vertex : POSITION;
              float4 texcoord:TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv:TEXCOORD0;
            };

            v2f vert(a2v v)
            {
            v2f o;
            o.pos=UnityObjectToClipPos(v.vertex);
            o.uv=v.texcoord.xy;

            return o;
            }

            half4 frag(v2f i):SV_TARGET0
            {
            float a=_Time.y*_FlowSpeed;
            i.uv-=float2(0.5,0.5);
            float blendFactor=saturate(i.uv.x*cos(a)-i.uv.y*sin(a));

            half3 c=lerp(_BaseColor.rgb,_FlowColor.rgb,blendFactor);
            return half4(c,1);
            }

            ENDCG
        }
    }
}
