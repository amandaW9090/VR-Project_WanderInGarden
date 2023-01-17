Shader "Test/Water"
{
    Properties
    {
        //_MainTex ("Texture", 2D) = "white" {}
        _MainColor("ColorTint",color)=(1,1,1,1)
        _DepthBiasFactor("DepthBiasFactor",Range(0,1))=0.1
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
            float _DepthBiasFactor;
            sampler2D _CameraDepthTexture;

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

                return fixed4(_MainColor.rgb,a);
            }
            ENDCG
        }
    }
}
