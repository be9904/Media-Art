Shader "Oculus/Hands_Transparent" { 
     Properties 
     {
       // _InnerColor ("Inner Color", Color) = (1.0, 1.0, 1.0, 1.0)
       _RimColor ("Rim Color", Color) = (0.26,0.19,0.16,0.0)
       _RimPower ("Rim Power", Range(0.5,8.0)) = 3.0
     }
     SubShader 
     {
       Tags {
           "RenderPipeline" = "UniversalPipeline"
           "RenderType" = "Transparent" 
           "Queue" = "Transparent"
       }
       
       Cull Back
       Blend One One
       Pass{
           Tags{"LightMode" = "UniversalForward"}
           
           HLSLPROGRAM
           #pragma prefer_hlslcc gles
           #pragma exclude_renderers d3d11_9x
           #pragma vertex vert
           #pragma fragment frag

           #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
           
           float4 _RimColor;
           float _RimPower;
           
           struct Attributes
           {
               float4 vertex : POSITION;
               float3 normal : NORMAL;
           };

           struct Varyings
           {
               float4 vertex : SV_POSITION;
               float3 normal : NORMAL;
               float3 viewDir : TEXCOORD0;
           };
           
           Varyings vert(Attributes v)
           {
               Varyings o;
               o.vertex = TransformObjectToHClip(v.vertex);
               o.normal = TransformObjectToWorldNormal(v.normal);

               o.viewDir = normalize(_WorldSpaceCameraPos.xyz - mul(GetObjectToWorldMatrix(), v.vertex).xyz);

               return o;
           }

           half4 frag(Varyings i) : SV_Target
           {
               float rimlight = saturate(pow(1-saturate(dot(i.normal, i.viewDir)), _RimPower));
               return rimlight * _RimColor;
           }
           ENDHLSL
       }
     } 
     Fallback "Diffuse"
   }
