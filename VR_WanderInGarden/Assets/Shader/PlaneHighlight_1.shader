Shader "Unlit/PlaneHighlight_1"
{
    
    Properties
    {
    _Color("Main Tint", Color) = (1, 1, 1, 1)
        _MainTex("Texture", 2D) = "white" {}
    _OutlineWidth("OutlineWidth", Range(0, 1)) = 0.1
        _OutlineColor("OutlineColor", Color) = (1, 1, 1, 1)
        _AlphaBlend("AlphaBlend", Range(0, 1)) = 0.8  // ������͸������Ļ����Ͽ��������͸����
        _AlphaTest("AlphaTest", Range(0, 1)) = 0.5
}
SubShader
{
    // RenderType��ǩ������Unity�����Shader���뵽��ǰ�������(Transparent)����ָ����Shader��һ��ʹ����͸���Ȼ�ϵ�Shader
    // IgnoreProjector=True����ζ�Ÿ�Shader�����ܵ�ͶӰ��(Projectors)��Ӱ��
    // Ϊ��ʹ��͸���Ȼ�ϵ�Shaderһ�㶼Ӧ����SubShader��������������ǩ
    Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
 
 
    //��һ��Pass���������д�룬�������ɫ������AlphaTest����
    Pass{
        // �����ǰ�ģ�͵������Ϣд����Ȼ����дӶ��޳�ģ���б������ڵ���ƬԪ
 
 
        ZWrite On
 
 
        // ����������ɫͨ����д����(Wirte Mask)ColorMask RGB|A|0|(R/G/B/A���)
        // ��Ϊ0ʱ��ζ�Ÿ�Pass��д���κ���ɫͨ����Ҳ�Ͳ�������κ���ɫ
        //Ҳ���Բ��ã��������ܿ������AlphaTest���µķ�˿��Ե����ɫ
        ColorMask 0
 
 
        CGPROGRAM
 
 
        #pragma vertex vert  
        #pragma fragment frag  
        #include "Lighting.cginc"  
 
 
        sampler2D _MainTex;
        float4 _MainTex_ST;
        fixed _AlphaTest;
 
 
        struct a2v {
        float4 vertex : POSITION;
        float4 texcoord : TEXCOORD0;
        };
 
 
        struct v2f {
        float4 pos : SV_POSITION;
        float2 uv : TEXCOORD2;
        };
 
 
        v2f vert(a2v v) {
        v2f o;
        o.pos = UnityObjectToClipPos(v.vertex);
        o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
        return o;
        }
 
 
        fixed4 frag(v2f i) : SV_Target{
        fixed4 texColor = tex2D(_MainTex, i.uv);
 
        clip(texColor.a - _AlphaTest); //����AlphaTest     //clip������������Ϊ������������ƬԪ���
 
        return fixed4(0,0,0,1);
        }
        ENDCG
        }
    //�ڶ���Pass���ر����д�룬����AlphaBlend��͸����������յȲ���
    Pass{
            // ��ǰ��Ⱦ·���ķ�ʽ
            Tags{ "LightMode" = "ForwardBase" }
 
            Cull Off //�ر��޳�����ͷ��˫����ʾ
 
            ZWrite Off //�ر����д��  
            //͸���Ȼ����Ҫ�ر����д��    
            //Orgb = SrcAlpha * Srgb + OneMinusSrcAlpha * Drgb
            //Oa = SrcAlpha * Sa + OneMinusSrcAlpha * Da
            //����Shader���������ɫֵ(Դ��ɫֵ) * ԴAlphaֵ + Ŀ����ɫֵ(�������Ϊ����ɫ) * (1-ԴAlphaֵ)���Ӷ���Դ����չʾ����(1-alpha)��͸���ȡ�
            Blend SrcAlpha OneMinusSrcAlpha
 
            CGPROGRAM
 
            #pragma vertex vert  
            #pragma fragment frag  
            #include "Lighting.cginc"  
 
            fixed4  _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _AlphaBlend;
 
            struct a2v {
            float4 vertex : POSITION;
            float3 normal : NORMAL;
            float4 texcoord : TEXCOORD0;
            };
 
            struct v2f {
            float4 pos : SV_POSITION;
            float3 worldNormal : TEXCOORD0;
            float3 worldPos : TEXCOORD1;
            float2 uv : TEXCOORD2;
            };
 
            v2f vert(a2v v) {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.worldNormal = UnityObjectToWorldNormal(v.normal);
            o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
            o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
            return o;
            }
 
            fixed4 frag(v2f i) : SV_Target{
            fixed3 worldNormal = normalize(i.worldNormal);
            fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
            fixed4 texColor = tex2D(_MainTex, i.uv);
            fixed3 albedo = texColor.rgb * _Color;
            fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
            fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal, worldLightDir));
            // ����͸����ͨ����ֵ
            return fixed4(ambient + diffuse, texColor.a * _AlphaBlend);
            }
            ENDCG
            }
            //������Pass���������
            Pass{
            Cull Front //�޳����� 
 
            CGPROGRAM
            #pragma vertex vert  
            #pragma fragment frag         
            #include "UnityCG.cginc"  
 
 
            sampler2D _MainTex;
            float4 _MainTex_ST;
            fixed _AlphaTest;
            float _OutlineWidth;
            float4 _OutlineColor;
 
            struct a2v
            {
            float4 vertex : POSITION;
            float4 normal : NORMAL;
            float4 texcoord : TEXCOORD0;
            };
 
            struct v2f
            {
            float4 pos : SV_POSITION;
            float2 uv : TEXCOORD2;
            };
            v2f vert(a2v v)
            {
            v2f o;
            //o.pos = mul(UNITY_MATRIX_MVP, v.vertex);    
            //float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal); 
            //float2 offset = TransformViewToProjection(normal.xy);
            //o.pos.xy += offset *o.pos.z * _OutlineWidth;
 
            //��������
            //o.pos = UnityObjectToClipPos(v.vertex);
            //float3 normal = UnityObjectToWorldNormal(v.normal);
            //normal = mul(UNITY_MATRIX_VP, normal);
            //o.pos.xyz += normal * _Outline;
            float4 pos = mul(UNITY_MATRIX_MV, v.vertex);   // viewPos,����任���ӽǿռ�
            float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal);  // viewNormal��UNITY_MATRIX_IT_MV�����Է������������߱任
            normal.z = -0.5;   // viewNormal �Զ��㷨�ߵ�z�������д���ʹ���ǵ���һ����ֵ
            float4 newNoraml = float4(normalize(normal), 0); //��һ�����noraml
            pos = pos + newNoraml * _OutlineWidth;  // viewPos �ط��߷���Զ����������
            o.pos = mul(UNITY_MATRIX_P, pos);
            o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
            return o;
            }
 
 
            fixed4 frag(v2f i) : SV_Target
            {
            fixed4 texColor = tex2D(_MainTex, i.uv);
            //AlphaTestΪ�������Ҳ�ܸ���͸������������,Ҳ���Բ���
            clip(texColor.a - _AlphaTest);
 
            return _OutlineColor;
            }
            ENDCG
            }
}
FallBack "Diffuse"


}
