Shader "Unlit/PlaneHighlight_2"
{
    Properties
    {
        //_MainTex ("Texture", 2D) = "white" {}
        _BaseColor("BaseColor",color)=(1,1,1,1)
        _FlowColor("FlowColor",color)=(1,1,1,1)
        _EdgeOffset("EdgeOffset",Range(0,1))=0.2
        _FlowSpeed("FlowSpeed",Range(0,5))=1
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderPipeline" = "UniversalPipeline" }

        Pass
        {
        Tags
            {
                "LightMode" = "SRPDefaultUnlit"
            }
            ZWrite On
            ColorMask 0

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

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
            float3 worldPos=TransformObjectToWorld(v.vertex.xyz);
            float3 dir=float3(0,0,0)-v.vertex.xyz;
            dir=TransformObjectToWorldDir(dir);
            worldPos+=dir*_EdgeOffset*0.1;
            o.pos=TransformWorldToHClip(worldPos);

            return o;
            }

            half4 frag(v2f i):SV_TARGET0
            {
            return half4(0,0,0,1);
            }

            ENDHLSL
        }

        Pass
        {
        Tags
            {
                "LightMode" = "UniversalForward"
            }
            ZWrite On
            Offset 1,1

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

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
            o.pos=TransformObjectToHClip(v.vertex.xyz);
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

            ENDHLSL
        }


        
    }
}
