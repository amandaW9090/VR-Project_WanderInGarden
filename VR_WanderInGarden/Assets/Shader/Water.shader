Shader "Test/Water"
{
    Properties
    {
        //_MainTex ("Texture", 2D) = "white" {}
        _MainColor("ColorTint",color)=(1,1,1,1)
        _EdgeColor("EdgeColor",color)=(1,1,1,1)
        _DepthBiasFactor("DepthBiasFactor",Range(0,1))=0.1
        _VanishingDistance("VanishingDistance",Range(0.5,1))=0.5
        _EdgeColorDistance("EdgeColorDistance",Range(0,1))=0.5
    }
    SubShader
    {
        Tags{"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            fixed4 _MainColor;
            fixed4 _EdgeColor;
            float _DepthBiasFactor;
            sampler2D _CameraDepthTexture;
            float _VanishingDistance;
            float _EdgeColorDistance;

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 screenPos:TEXCOORD0;
            };

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeScreenPos(o.pos);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 depthSample=SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, (i.screenPos));
                float depth = LinearEyeDepth(depthSample);
                fixed a=saturate((depth - i.screenPos.w)/2 - _DepthBiasFactor);
                fixed a1=smoothstep(0,0.3,_VanishingDistance-i.screenPos.w/_ProjectionParams.z);
                a=min(a,a1);

                fixed a2=smoothstep(0,0.4,_EdgeColorDistance-i.screenPos.w/_ProjectionParams.z);
                fixed3 c=lerp(_EdgeColor.rgb,_MainColor.rgb,a2);

                return fixed4(c,a);
            }
            ENDCG
        }
    }
}
