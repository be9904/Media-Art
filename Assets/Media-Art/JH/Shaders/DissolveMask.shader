Shader "DissolveMask"
{
	Properties
        {
            // Stencil ID
        	[IntRange] _StencilID("Stencil ID", Range(0,255)) = 0
        	
            [HDR]_Color("Color", Color) = (1, 1, 1, 1)
            [NoScaleOffset]_Albedo("Albedo", 2D) = "white" {}
            _Metallic("Metallic", Range(0, 1)) = 0
            _Smoothness("Smoothness", Range(0, 1)) = 0.5
            [NoScaleOffset]_Normals("Normals", 2D) = "white" {}
            _NormalsStrength("NormalsStrength", Range(0, 1)) = 0
            [NoScaleOffset]_AmbientOcclusion("AmbientOcclusion", 2D) = "white" {}
            _AmbientOcclusionStrength("AmbientOcclusionStrength", Range(0, 1)) = 0
            [HDR]_DissolveColor("DissolveColor", Color) = (5.992157, 5.992157, 5.992157, 1)
            _DissolveAmount("DissolveAmount", Range(0, 1)) = 0.5
            _DissolveWidth("DissolveWidth", Range(0, 0.2)) = 0.02
            _DissolveScale("DissolveScale", Range(0, 500)) = 30
            [HideInInspector]_QueueOffset("_QueueOffset", Float) = 0
            [HideInInspector]_QueueControl("_QueueControl", Float) = -1
            [HideInInspector][NoScaleOffset]unity_Lightmaps("unity_Lightmaps", 2DArray) = "" {}
            [HideInInspector][NoScaleOffset]unity_LightmapsInd("unity_LightmapsInd", 2DArray) = "" {}
            [HideInInspector][NoScaleOffset]unity_ShadowMasks("unity_ShadowMasks", 2DArray) = "" {}
        }
        SubShader
        {
            Tags
            {
                "RenderPipeline"="UniversalPipeline"
                "RenderType"="Opaque"
                "UniversalMaterialType" = "Unlit"
                "Queue"="AlphaTest"
                "ShaderGraphShader"="true"
                "ShaderGraphTargetId"="UniversalUnlitSubTarget"
            }
            Pass
            {
                Name "Universal Forward"
                Tags
                {
                    // LightMode: <None>
                }
            
            // Render State
            Blend Zero One
			ZWrite Off
			
			Stencil{
				Ref [_StencilID]
				Comp Always
				Pass Replace
				Fail Keep
				ZFail Replace
			}
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 4.5
            #pragma exclude_renderers gles gles3 glcore
            #pragma multi_compile_instancing
            #pragma multi_compile_fog
            #pragma instancing_options renderinglayer
            #pragma multi_compile _ DOTS_INSTANCING_ON
            #pragma vertex vert
            #pragma fragment frag
            
            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>
            
            // Keywords
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma shader_feature _ _SAMPLE_GI
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ DEBUG_DISPLAY
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_UNLIT
            #define _FOG_FRAGMENT 1
            #define _ALPHATEST_ON 1
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
            {
                 float3 positionOS : POSITION;
                 float3 normalOS : NORMAL;
                 float4 tangentOS : TANGENT;
                 float4 uv0 : TEXCOORD0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                 float4 positionCS : SV_POSITION;
                 float3 positionWS;
                 float3 normalWS;
                 float4 texCoord0;
                 float3 viewDirectionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs
            {
                 float4 uv0;
            };
            struct VertexDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 ObjectSpacePosition;
            };
            struct PackedVaryings
            {
                 float4 positionCS : SV_POSITION;
                 float3 interp0 : INTERP0;
                 float3 interp1 : INTERP1;
                 float4 interp2 : INTERP2;
                 float3 interp3 : INTERP3;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            PackedVaryings PackVaryings (Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                output.interp0.xyz =  input.positionWS;
                output.interp1.xyz =  input.normalWS;
                output.interp2.xyzw =  input.texCoord0;
                output.interp3.xyz =  input.viewDirectionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            Varyings UnpackVaryings (PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.positionWS = input.interp0.xyz;
                output.normalWS = input.interp1.xyz;
                output.texCoord0 = input.interp2.xyzw;
                output.viewDirectionWS = input.interp3.xyz;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            float _Metallic;
            float _Smoothness;
            float _NormalsStrength;
            float4 _Albedo_TexelSize;
            float4 _Normals_TexelSize;
            float4 _AmbientOcclusion_TexelSize;
            float _AmbientOcclusionStrength;
            float4 _DissolveColor;
            float _DissolveAmount;
            float _DissolveWidth;
            float _DissolveScale;
            CBUFFER_END
            
            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_Albedo);
            SAMPLER(sampler_Albedo);
            TEXTURE2D(_Normals);
            SAMPLER(sampler_Normals);
            TEXTURE2D(_AmbientOcclusion);
            SAMPLER(sampler_AmbientOcclusion);
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
            void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
            {
                Out = A * B;
            }
            
            
            inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
            {
                float angle = dot(uv, float2(12.9898, 78.233));
                #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                    // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                    angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
                #endif
                return frac(sin(angle)*43758.5453);
            }
            
            inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
            {
                return (1.0-t)*a + (t*b);
            }
            
            
            inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                f = f * f * (3.0 - 2.0 * f);
            
                uv = abs(frac(uv) - 0.5);
                float2 c0 = i + float2(0.0, 0.0);
                float2 c1 = i + float2(1.0, 0.0);
                float2 c2 = i + float2(0.0, 1.0);
                float2 c3 = i + float2(1.0, 1.0);
                float r0 = Unity_SimpleNoise_RandomValue_float(c0);
                float r1 = Unity_SimpleNoise_RandomValue_float(c1);
                float r2 = Unity_SimpleNoise_RandomValue_float(c2);
                float r3 = Unity_SimpleNoise_RandomValue_float(c3);
            
                float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
                float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
                float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
                return t;
            }
            void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
            {
                float t = 0.0;
            
                float freq = pow(2.0, float(0));
                float amp = pow(0.5, float(3-0));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(1));
                amp = pow(0.5, float(3-1));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(2));
                amp = pow(0.5, float(3-2));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                Out = t;
            }
            
            void Unity_Add_float(float A, float B, out float Out)
            {
                Out = A + B;
            }
            
            void Unity_Step_float(float Edge, float In, out float Out)
            {
                Out = step(Edge, In);
            }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
            {
                float3 BaseColor;
                float Alpha;
                float AlphaClipThreshold;
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float4 _Property_7e99dd926f964644b2bdb64d1ac98304_Out_0 = IsGammaSpace() ? LinearToSRGB(_Color) : _Color;
                UnityTexture2D _Property_374ab744c684403fa921ce33bd75d3b8_Out_0 = UnityBuildTexture2DStructNoScale(_Albedo);
                float4 _SampleTexture2D_851146e9a7f74c459b59d676cf3d6dee_RGBA_0 = SAMPLE_TEXTURE2D(_Property_374ab744c684403fa921ce33bd75d3b8_Out_0.tex, _Property_374ab744c684403fa921ce33bd75d3b8_Out_0.samplerstate, _Property_374ab744c684403fa921ce33bd75d3b8_Out_0.GetTransformedUV(IN.uv0.xy));
                float _SampleTexture2D_851146e9a7f74c459b59d676cf3d6dee_R_4 = _SampleTexture2D_851146e9a7f74c459b59d676cf3d6dee_RGBA_0.r;
                float _SampleTexture2D_851146e9a7f74c459b59d676cf3d6dee_G_5 = _SampleTexture2D_851146e9a7f74c459b59d676cf3d6dee_RGBA_0.g;
                float _SampleTexture2D_851146e9a7f74c459b59d676cf3d6dee_B_6 = _SampleTexture2D_851146e9a7f74c459b59d676cf3d6dee_RGBA_0.b;
                float _SampleTexture2D_851146e9a7f74c459b59d676cf3d6dee_A_7 = _SampleTexture2D_851146e9a7f74c459b59d676cf3d6dee_RGBA_0.a;
                float4 _Multiply_ef5d2758e2404b7fa0b48f5d2f09bf6b_Out_2;
                Unity_Multiply_float4_float4(_Property_7e99dd926f964644b2bdb64d1ac98304_Out_0, _SampleTexture2D_851146e9a7f74c459b59d676cf3d6dee_RGBA_0, _Multiply_ef5d2758e2404b7fa0b48f5d2f09bf6b_Out_2);
                float _Property_ddddf6bf9923471e9d49214a88848944_Out_0 = _DissolveScale;
                float _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2;
                Unity_SimpleNoise_float(IN.uv0.xy, _Property_ddddf6bf9923471e9d49214a88848944_Out_0, _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2);
                float _Property_5c97f20724fb4c2aaae791101d937138_Out_0 = _DissolveWidth;
                float _Property_17aad81e47934bc4818f4debb8c3a7b8_Out_0 = _DissolveAmount;
                float _Add_a2fb0c9dcc9348d3a5fffa0ffe4267f0_Out_2;
                Unity_Add_float(_Property_5c97f20724fb4c2aaae791101d937138_Out_0, _Property_17aad81e47934bc4818f4debb8c3a7b8_Out_0, _Add_a2fb0c9dcc9348d3a5fffa0ffe4267f0_Out_2);
                float _Step_9a18a45d15644c56ad4cb6c4b7b184ae_Out_2;
                Unity_Step_float(_SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2, _Add_a2fb0c9dcc9348d3a5fffa0ffe4267f0_Out_2, _Step_9a18a45d15644c56ad4cb6c4b7b184ae_Out_2);
                float4 _Property_e061f5137200443db66277cadb245dfc_Out_0 = IsGammaSpace() ? LinearToSRGB(_DissolveColor) : _DissolveColor;
                float4 _Multiply_eb8669151edd4776a700bb3eda19948f_Out_2;
                Unity_Multiply_float4_float4((_Step_9a18a45d15644c56ad4cb6c4b7b184ae_Out_2.xxxx), _Property_e061f5137200443db66277cadb245dfc_Out_0, _Multiply_eb8669151edd4776a700bb3eda19948f_Out_2);
                float4 _Multiply_4bb5ea100aff4bc0aee774e4ec3e7cb8_Out_2;
                Unity_Multiply_float4_float4(_Multiply_ef5d2758e2404b7fa0b48f5d2f09bf6b_Out_2, _Multiply_eb8669151edd4776a700bb3eda19948f_Out_2, _Multiply_4bb5ea100aff4bc0aee774e4ec3e7cb8_Out_2);
                surface.BaseColor = (_Multiply_4bb5ea100aff4bc0aee774e4ec3e7cb8_Out_2.xyz);
                surface.Alpha = _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2;
                surface.AlphaClipThreshold = _Property_17aad81e47934bc4818f4debb8c3a7b8_Out_0;
                return surface;
            }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
            
                output.ObjectSpaceNormal =                          input.normalOS;
                output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                output.ObjectSpacePosition =                        input.positionOS;
            
                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
            
            #ifdef HAVE_VFX_MODIFICATION
                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
            
            #endif
            
                
            
            
            
            
            
                output.uv0 = input.texCoord0;
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            
                    return output;
            }
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
            Pass
            {
                Name "DepthOnly"
                Tags
                {
                    "LightMode" = "DepthOnly"
                }
            
            // Render State
            Cull Back
            ZTest LEqual
            ZWrite On
            ColorMask 0
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 4.5
            #pragma exclude_renderers gles gles3 glcore
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON
            #pragma vertex vert
            #pragma fragment frag
            
            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>
            
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
            #define _ALPHATEST_ON 1
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
            {
                 float3 positionOS : POSITION;
                 float3 normalOS : NORMAL;
                 float4 tangentOS : TANGENT;
                 float4 uv0 : TEXCOORD0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                 float4 positionCS : SV_POSITION;
                 float4 texCoord0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs
            {
                 float4 uv0;
            };
            struct VertexDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 ObjectSpacePosition;
            };
            struct PackedVaryings
            {
                 float4 positionCS : SV_POSITION;
                 float4 interp0 : INTERP0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            PackedVaryings PackVaryings (Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                output.interp0.xyzw =  input.texCoord0;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            Varyings UnpackVaryings (PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.texCoord0 = input.interp0.xyzw;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            float _Metallic;
            float _Smoothness;
            float _NormalsStrength;
            float4 _Albedo_TexelSize;
            float4 _Normals_TexelSize;
            float4 _AmbientOcclusion_TexelSize;
            float _AmbientOcclusionStrength;
            float4 _DissolveColor;
            float _DissolveAmount;
            float _DissolveWidth;
            float _DissolveScale;
            CBUFFER_END
            
            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_Albedo);
            SAMPLER(sampler_Albedo);
            TEXTURE2D(_Normals);
            SAMPLER(sampler_Normals);
            TEXTURE2D(_AmbientOcclusion);
            SAMPLER(sampler_AmbientOcclusion);
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
            
            inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
            {
                float angle = dot(uv, float2(12.9898, 78.233));
                #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                    // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                    angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
                #endif
                return frac(sin(angle)*43758.5453);
            }
            
            inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
            {
                return (1.0-t)*a + (t*b);
            }
            
            
            inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                f = f * f * (3.0 - 2.0 * f);
            
                uv = abs(frac(uv) - 0.5);
                float2 c0 = i + float2(0.0, 0.0);
                float2 c1 = i + float2(1.0, 0.0);
                float2 c2 = i + float2(0.0, 1.0);
                float2 c3 = i + float2(1.0, 1.0);
                float r0 = Unity_SimpleNoise_RandomValue_float(c0);
                float r1 = Unity_SimpleNoise_RandomValue_float(c1);
                float r2 = Unity_SimpleNoise_RandomValue_float(c2);
                float r3 = Unity_SimpleNoise_RandomValue_float(c3);
            
                float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
                float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
                float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
                return t;
            }
            void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
            {
                float t = 0.0;
            
                float freq = pow(2.0, float(0));
                float amp = pow(0.5, float(3-0));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(1));
                amp = pow(0.5, float(3-1));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(2));
                amp = pow(0.5, float(3-2));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                Out = t;
            }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
            {
                float Alpha;
                float AlphaClipThreshold;
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float _Property_ddddf6bf9923471e9d49214a88848944_Out_0 = _DissolveScale;
                float _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2;
                Unity_SimpleNoise_float(IN.uv0.xy, _Property_ddddf6bf9923471e9d49214a88848944_Out_0, _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2);
                float _Property_17aad81e47934bc4818f4debb8c3a7b8_Out_0 = _DissolveAmount;
                surface.Alpha = _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2;
                surface.AlphaClipThreshold = _Property_17aad81e47934bc4818f4debb8c3a7b8_Out_0;
                return surface;
            }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
            
                output.ObjectSpaceNormal =                          input.normalOS;
                output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                output.ObjectSpacePosition =                        input.positionOS;
            
                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
            
            #ifdef HAVE_VFX_MODIFICATION
                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
            
            #endif
            
                
            
            
            
            
            
                output.uv0 = input.texCoord0;
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            
                    return output;
            }
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
            Pass
            {
                Name "DepthNormalsOnly"
                Tags
                {
                    "LightMode" = "DepthNormalsOnly"
                }
            
            // Render State
            Cull Back
            ZTest LEqual
            ZWrite On
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 4.5
            #pragma exclude_renderers gles gles3 glcore
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON
            #pragma vertex vert
            #pragma fragment frag
            
            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>
            
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
            #define _ALPHATEST_ON 1
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
            {
                 float3 positionOS : POSITION;
                 float3 normalOS : NORMAL;
                 float4 tangentOS : TANGENT;
                 float4 uv0 : TEXCOORD0;
                 float4 uv1 : TEXCOORD1;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                 float4 positionCS : SV_POSITION;
                 float3 normalWS;
                 float4 tangentWS;
                 float4 texCoord0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs
            {
                 float4 uv0;
            };
            struct VertexDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 ObjectSpacePosition;
            };
            struct PackedVaryings
            {
                 float4 positionCS : SV_POSITION;
                 float3 interp0 : INTERP0;
                 float4 interp1 : INTERP1;
                 float4 interp2 : INTERP2;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            PackedVaryings PackVaryings (Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                output.interp0.xyz =  input.normalWS;
                output.interp1.xyzw =  input.tangentWS;
                output.interp2.xyzw =  input.texCoord0;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            Varyings UnpackVaryings (PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.normalWS = input.interp0.xyz;
                output.tangentWS = input.interp1.xyzw;
                output.texCoord0 = input.interp2.xyzw;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            float _Metallic;
            float _Smoothness;
            float _NormalsStrength;
            float4 _Albedo_TexelSize;
            float4 _Normals_TexelSize;
            float4 _AmbientOcclusion_TexelSize;
            float _AmbientOcclusionStrength;
            float4 _DissolveColor;
            float _DissolveAmount;
            float _DissolveWidth;
            float _DissolveScale;
            CBUFFER_END
            
            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_Albedo);
            SAMPLER(sampler_Albedo);
            TEXTURE2D(_Normals);
            SAMPLER(sampler_Normals);
            TEXTURE2D(_AmbientOcclusion);
            SAMPLER(sampler_AmbientOcclusion);
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
            
            inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
            {
                float angle = dot(uv, float2(12.9898, 78.233));
                #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                    // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                    angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
                #endif
                return frac(sin(angle)*43758.5453);
            }
            
            inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
            {
                return (1.0-t)*a + (t*b);
            }
            
            
            inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                f = f * f * (3.0 - 2.0 * f);
            
                uv = abs(frac(uv) - 0.5);
                float2 c0 = i + float2(0.0, 0.0);
                float2 c1 = i + float2(1.0, 0.0);
                float2 c2 = i + float2(0.0, 1.0);
                float2 c3 = i + float2(1.0, 1.0);
                float r0 = Unity_SimpleNoise_RandomValue_float(c0);
                float r1 = Unity_SimpleNoise_RandomValue_float(c1);
                float r2 = Unity_SimpleNoise_RandomValue_float(c2);
                float r3 = Unity_SimpleNoise_RandomValue_float(c3);
            
                float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
                float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
                float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
                return t;
            }
            void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
            {
                float t = 0.0;
            
                float freq = pow(2.0, float(0));
                float amp = pow(0.5, float(3-0));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(1));
                amp = pow(0.5, float(3-1));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(2));
                amp = pow(0.5, float(3-2));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                Out = t;
            }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
            {
                float Alpha;
                float AlphaClipThreshold;
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float _Property_ddddf6bf9923471e9d49214a88848944_Out_0 = _DissolveScale;
                float _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2;
                Unity_SimpleNoise_float(IN.uv0.xy, _Property_ddddf6bf9923471e9d49214a88848944_Out_0, _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2);
                float _Property_17aad81e47934bc4818f4debb8c3a7b8_Out_0 = _DissolveAmount;
                surface.Alpha = _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2;
                surface.AlphaClipThreshold = _Property_17aad81e47934bc4818f4debb8c3a7b8_Out_0;
                return surface;
            }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
            
                output.ObjectSpaceNormal =                          input.normalOS;
                output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                output.ObjectSpacePosition =                        input.positionOS;
            
                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
            
            #ifdef HAVE_VFX_MODIFICATION
                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
            
            #endif
            
                
            
            
            
            
            
                output.uv0 = input.texCoord0;
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            
                    return output;
            }
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
            Pass
            {
                Name "ShadowCaster"
                Tags
                {
                    "LightMode" = "ShadowCaster"
                }
            
            // Render State
            Cull Back
            ZTest LEqual
            ZWrite On
            ColorMask 0
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 4.5
            #pragma exclude_renderers gles gles3 glcore
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON
            #pragma vertex vert
            #pragma fragment frag
            
            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>
            
            // Keywords
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
            #define _ALPHATEST_ON 1
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
            {
                 float3 positionOS : POSITION;
                 float3 normalOS : NORMAL;
                 float4 tangentOS : TANGENT;
                 float4 uv0 : TEXCOORD0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                 float4 positionCS : SV_POSITION;
                 float3 normalWS;
                 float4 texCoord0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs
            {
                 float4 uv0;
            };
            struct VertexDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 ObjectSpacePosition;
            };
            struct PackedVaryings
            {
                 float4 positionCS : SV_POSITION;
                 float3 interp0 : INTERP0;
                 float4 interp1 : INTERP1;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            PackedVaryings PackVaryings (Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                output.interp0.xyz =  input.normalWS;
                output.interp1.xyzw =  input.texCoord0;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            Varyings UnpackVaryings (PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.normalWS = input.interp0.xyz;
                output.texCoord0 = input.interp1.xyzw;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            float _Metallic;
            float _Smoothness;
            float _NormalsStrength;
            float4 _Albedo_TexelSize;
            float4 _Normals_TexelSize;
            float4 _AmbientOcclusion_TexelSize;
            float _AmbientOcclusionStrength;
            float4 _DissolveColor;
            float _DissolveAmount;
            float _DissolveWidth;
            float _DissolveScale;
            CBUFFER_END
            
            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_Albedo);
            SAMPLER(sampler_Albedo);
            TEXTURE2D(_Normals);
            SAMPLER(sampler_Normals);
            TEXTURE2D(_AmbientOcclusion);
            SAMPLER(sampler_AmbientOcclusion);
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
            
            inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
            {
                float angle = dot(uv, float2(12.9898, 78.233));
                #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                    // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                    angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
                #endif
                return frac(sin(angle)*43758.5453);
            }
            
            inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
            {
                return (1.0-t)*a + (t*b);
            }
            
            
            inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                f = f * f * (3.0 - 2.0 * f);
            
                uv = abs(frac(uv) - 0.5);
                float2 c0 = i + float2(0.0, 0.0);
                float2 c1 = i + float2(1.0, 0.0);
                float2 c2 = i + float2(0.0, 1.0);
                float2 c3 = i + float2(1.0, 1.0);
                float r0 = Unity_SimpleNoise_RandomValue_float(c0);
                float r1 = Unity_SimpleNoise_RandomValue_float(c1);
                float r2 = Unity_SimpleNoise_RandomValue_float(c2);
                float r3 = Unity_SimpleNoise_RandomValue_float(c3);
            
                float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
                float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
                float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
                return t;
            }
            void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
            {
                float t = 0.0;
            
                float freq = pow(2.0, float(0));
                float amp = pow(0.5, float(3-0));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(1));
                amp = pow(0.5, float(3-1));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(2));
                amp = pow(0.5, float(3-2));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                Out = t;
            }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
            {
                float Alpha;
                float AlphaClipThreshold;
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float _Property_ddddf6bf9923471e9d49214a88848944_Out_0 = _DissolveScale;
                float _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2;
                Unity_SimpleNoise_float(IN.uv0.xy, _Property_ddddf6bf9923471e9d49214a88848944_Out_0, _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2);
                float _Property_17aad81e47934bc4818f4debb8c3a7b8_Out_0 = _DissolveAmount;
                surface.Alpha = _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2;
                surface.AlphaClipThreshold = _Property_17aad81e47934bc4818f4debb8c3a7b8_Out_0;
                return surface;
            }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
            
                output.ObjectSpaceNormal =                          input.normalOS;
                output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                output.ObjectSpacePosition =                        input.positionOS;
            
                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
            
            #ifdef HAVE_VFX_MODIFICATION
                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
            
            #endif
            
                
            
            
            
            
            
                output.uv0 = input.texCoord0;
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            
                    return output;
            }
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
            Pass
            {
                Name "SceneSelectionPass"
                Tags
                {
                    "LightMode" = "SceneSelectionPass"
                }
            
            // Render State
            Cull Off
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 4.5
            #pragma exclude_renderers gles gles3 glcore
            #pragma vertex vert
            #pragma fragment frag
            
            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>
            
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
            #define SCENESELECTIONPASS 1
            #define ALPHA_CLIP_THRESHOLD 1
            #define _ALPHATEST_ON 1
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
            {
                 float3 positionOS : POSITION;
                 float3 normalOS : NORMAL;
                 float4 tangentOS : TANGENT;
                 float4 uv0 : TEXCOORD0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                 float4 positionCS : SV_POSITION;
                 float4 texCoord0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs
            {
                 float4 uv0;
            };
            struct VertexDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 ObjectSpacePosition;
            };
            struct PackedVaryings
            {
                 float4 positionCS : SV_POSITION;
                 float4 interp0 : INTERP0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            PackedVaryings PackVaryings (Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                output.interp0.xyzw =  input.texCoord0;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            Varyings UnpackVaryings (PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.texCoord0 = input.interp0.xyzw;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            float _Metallic;
            float _Smoothness;
            float _NormalsStrength;
            float4 _Albedo_TexelSize;
            float4 _Normals_TexelSize;
            float4 _AmbientOcclusion_TexelSize;
            float _AmbientOcclusionStrength;
            float4 _DissolveColor;
            float _DissolveAmount;
            float _DissolveWidth;
            float _DissolveScale;
            CBUFFER_END
            
            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_Albedo);
            SAMPLER(sampler_Albedo);
            TEXTURE2D(_Normals);
            SAMPLER(sampler_Normals);
            TEXTURE2D(_AmbientOcclusion);
            SAMPLER(sampler_AmbientOcclusion);
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
            
            inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
            {
                float angle = dot(uv, float2(12.9898, 78.233));
                #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                    // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                    angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
                #endif
                return frac(sin(angle)*43758.5453);
            }
            
            inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
            {
                return (1.0-t)*a + (t*b);
            }
            
            
            inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                f = f * f * (3.0 - 2.0 * f);
            
                uv = abs(frac(uv) - 0.5);
                float2 c0 = i + float2(0.0, 0.0);
                float2 c1 = i + float2(1.0, 0.0);
                float2 c2 = i + float2(0.0, 1.0);
                float2 c3 = i + float2(1.0, 1.0);
                float r0 = Unity_SimpleNoise_RandomValue_float(c0);
                float r1 = Unity_SimpleNoise_RandomValue_float(c1);
                float r2 = Unity_SimpleNoise_RandomValue_float(c2);
                float r3 = Unity_SimpleNoise_RandomValue_float(c3);
            
                float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
                float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
                float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
                return t;
            }
            void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
            {
                float t = 0.0;
            
                float freq = pow(2.0, float(0));
                float amp = pow(0.5, float(3-0));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(1));
                amp = pow(0.5, float(3-1));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(2));
                amp = pow(0.5, float(3-2));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                Out = t;
            }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
            {
                float Alpha;
                float AlphaClipThreshold;
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float _Property_ddddf6bf9923471e9d49214a88848944_Out_0 = _DissolveScale;
                float _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2;
                Unity_SimpleNoise_float(IN.uv0.xy, _Property_ddddf6bf9923471e9d49214a88848944_Out_0, _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2);
                float _Property_17aad81e47934bc4818f4debb8c3a7b8_Out_0 = _DissolveAmount;
                surface.Alpha = _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2;
                surface.AlphaClipThreshold = _Property_17aad81e47934bc4818f4debb8c3a7b8_Out_0;
                return surface;
            }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
            
                output.ObjectSpaceNormal =                          input.normalOS;
                output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                output.ObjectSpacePosition =                        input.positionOS;
            
                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
            
            #ifdef HAVE_VFX_MODIFICATION
                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
            
            #endif
            
                
            
            
            
            
            
                output.uv0 = input.texCoord0;
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            
                    return output;
            }
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
            Pass
            {
                Name "ScenePickingPass"
                Tags
                {
                    "LightMode" = "Picking"
                }
            
            // Render State
            Cull Back
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 4.5
            #pragma exclude_renderers gles gles3 glcore
            #pragma vertex vert
            #pragma fragment frag
            
            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>
            
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
            #define SCENEPICKINGPASS 1
            #define ALPHA_CLIP_THRESHOLD 1
            #define _ALPHATEST_ON 1
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
            {
                 float3 positionOS : POSITION;
                 float3 normalOS : NORMAL;
                 float4 tangentOS : TANGENT;
                 float4 uv0 : TEXCOORD0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                 float4 positionCS : SV_POSITION;
                 float4 texCoord0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs
            {
                 float4 uv0;
            };
            struct VertexDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 ObjectSpacePosition;
            };
            struct PackedVaryings
            {
                 float4 positionCS : SV_POSITION;
                 float4 interp0 : INTERP0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            PackedVaryings PackVaryings (Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                output.interp0.xyzw =  input.texCoord0;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            Varyings UnpackVaryings (PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.texCoord0 = input.interp0.xyzw;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            float _Metallic;
            float _Smoothness;
            float _NormalsStrength;
            float4 _Albedo_TexelSize;
            float4 _Normals_TexelSize;
            float4 _AmbientOcclusion_TexelSize;
            float _AmbientOcclusionStrength;
            float4 _DissolveColor;
            float _DissolveAmount;
            float _DissolveWidth;
            float _DissolveScale;
            CBUFFER_END
            
            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_Albedo);
            SAMPLER(sampler_Albedo);
            TEXTURE2D(_Normals);
            SAMPLER(sampler_Normals);
            TEXTURE2D(_AmbientOcclusion);
            SAMPLER(sampler_AmbientOcclusion);
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
            
            inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
            {
                float angle = dot(uv, float2(12.9898, 78.233));
                #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                    // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                    angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
                #endif
                return frac(sin(angle)*43758.5453);
            }
            
            inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
            {
                return (1.0-t)*a + (t*b);
            }
            
            
            inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                f = f * f * (3.0 - 2.0 * f);
            
                uv = abs(frac(uv) - 0.5);
                float2 c0 = i + float2(0.0, 0.0);
                float2 c1 = i + float2(1.0, 0.0);
                float2 c2 = i + float2(0.0, 1.0);
                float2 c3 = i + float2(1.0, 1.0);
                float r0 = Unity_SimpleNoise_RandomValue_float(c0);
                float r1 = Unity_SimpleNoise_RandomValue_float(c1);
                float r2 = Unity_SimpleNoise_RandomValue_float(c2);
                float r3 = Unity_SimpleNoise_RandomValue_float(c3);
            
                float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
                float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
                float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
                return t;
            }
            void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
            {
                float t = 0.0;
            
                float freq = pow(2.0, float(0));
                float amp = pow(0.5, float(3-0));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(1));
                amp = pow(0.5, float(3-1));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(2));
                amp = pow(0.5, float(3-2));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                Out = t;
            }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
            {
                float Alpha;
                float AlphaClipThreshold;
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float _Property_ddddf6bf9923471e9d49214a88848944_Out_0 = _DissolveScale;
                float _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2;
                Unity_SimpleNoise_float(IN.uv0.xy, _Property_ddddf6bf9923471e9d49214a88848944_Out_0, _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2);
                float _Property_17aad81e47934bc4818f4debb8c3a7b8_Out_0 = _DissolveAmount;
                surface.Alpha = _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2;
                surface.AlphaClipThreshold = _Property_17aad81e47934bc4818f4debb8c3a7b8_Out_0;
                return surface;
            }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
            
                output.ObjectSpaceNormal =                          input.normalOS;
                output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                output.ObjectSpacePosition =                        input.positionOS;
            
                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
            
            #ifdef HAVE_VFX_MODIFICATION
                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
            
            #endif
            
                
            
            
            
            
            
                output.uv0 = input.texCoord0;
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            
                    return output;
            }
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
            Pass
            {
                Name "DepthNormals"
                Tags
                {
                    "LightMode" = "DepthNormalsOnly"
                }
            
            // Render State
            Cull Back
            ZTest LEqual
            ZWrite On
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 4.5
            #pragma exclude_renderers gles gles3 glcore
            #pragma multi_compile_instancing
            #pragma multi_compile _ DOTS_INSTANCING_ON
            #pragma vertex vert
            #pragma fragment frag
            
            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>
            
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
            #define _ALPHATEST_ON 1
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
            {
                 float3 positionOS : POSITION;
                 float3 normalOS : NORMAL;
                 float4 tangentOS : TANGENT;
                 float4 uv0 : TEXCOORD0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                 float4 positionCS : SV_POSITION;
                 float3 normalWS;
                 float4 texCoord0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs
            {
                 float4 uv0;
            };
            struct VertexDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 ObjectSpacePosition;
            };
            struct PackedVaryings
            {
                 float4 positionCS : SV_POSITION;
                 float3 interp0 : INTERP0;
                 float4 interp1 : INTERP1;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            PackedVaryings PackVaryings (Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                output.interp0.xyz =  input.normalWS;
                output.interp1.xyzw =  input.texCoord0;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            Varyings UnpackVaryings (PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.normalWS = input.interp0.xyz;
                output.texCoord0 = input.interp1.xyzw;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            float _Metallic;
            float _Smoothness;
            float _NormalsStrength;
            float4 _Albedo_TexelSize;
            float4 _Normals_TexelSize;
            float4 _AmbientOcclusion_TexelSize;
            float _AmbientOcclusionStrength;
            float4 _DissolveColor;
            float _DissolveAmount;
            float _DissolveWidth;
            float _DissolveScale;
            CBUFFER_END
            
            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_Albedo);
            SAMPLER(sampler_Albedo);
            TEXTURE2D(_Normals);
            SAMPLER(sampler_Normals);
            TEXTURE2D(_AmbientOcclusion);
            SAMPLER(sampler_AmbientOcclusion);
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
            
            inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
            {
                float angle = dot(uv, float2(12.9898, 78.233));
                #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                    // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                    angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
                #endif
                return frac(sin(angle)*43758.5453);
            }
            
            inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
            {
                return (1.0-t)*a + (t*b);
            }
            
            
            inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                f = f * f * (3.0 - 2.0 * f);
            
                uv = abs(frac(uv) - 0.5);
                float2 c0 = i + float2(0.0, 0.0);
                float2 c1 = i + float2(1.0, 0.0);
                float2 c2 = i + float2(0.0, 1.0);
                float2 c3 = i + float2(1.0, 1.0);
                float r0 = Unity_SimpleNoise_RandomValue_float(c0);
                float r1 = Unity_SimpleNoise_RandomValue_float(c1);
                float r2 = Unity_SimpleNoise_RandomValue_float(c2);
                float r3 = Unity_SimpleNoise_RandomValue_float(c3);
            
                float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
                float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
                float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
                return t;
            }
            void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
            {
                float t = 0.0;
            
                float freq = pow(2.0, float(0));
                float amp = pow(0.5, float(3-0));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(1));
                amp = pow(0.5, float(3-1));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(2));
                amp = pow(0.5, float(3-2));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                Out = t;
            }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
            {
                float Alpha;
                float AlphaClipThreshold;
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float _Property_ddddf6bf9923471e9d49214a88848944_Out_0 = _DissolveScale;
                float _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2;
                Unity_SimpleNoise_float(IN.uv0.xy, _Property_ddddf6bf9923471e9d49214a88848944_Out_0, _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2);
                float _Property_17aad81e47934bc4818f4debb8c3a7b8_Out_0 = _DissolveAmount;
                surface.Alpha = _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2;
                surface.AlphaClipThreshold = _Property_17aad81e47934bc4818f4debb8c3a7b8_Out_0;
                return surface;
            }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
            
                output.ObjectSpaceNormal =                          input.normalOS;
                output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                output.ObjectSpacePosition =                        input.positionOS;
            
                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
            
            #ifdef HAVE_VFX_MODIFICATION
                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
            
            #endif
            
                
            
            
            
            
            
                output.uv0 = input.texCoord0;
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            
                    return output;
            }
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
        }
        SubShader
        {
            Tags
            {
                "RenderPipeline"="UniversalPipeline"
                "RenderType"="Opaque"
                "UniversalMaterialType" = "Unlit"
                "Queue"="AlphaTest"
                "ShaderGraphShader"="true"
                "ShaderGraphTargetId"="UniversalUnlitSubTarget"
            }
            Pass
            {
                Name "Universal Forward"
                Tags
                {
                    // LightMode: <None>
                }
            
            // Render State
            Cull Back
            Blend One Zero
            ZTest LEqual
            ZWrite On
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 2.0
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma multi_compile_instancing
            #pragma multi_compile_fog
            #pragma instancing_options renderinglayer
            #pragma vertex vert
            #pragma fragment frag
            
            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>
            
            // Keywords
            #pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile _ DIRLIGHTMAP_COMBINED
            #pragma shader_feature _ _SAMPLE_GI
            #pragma multi_compile_fragment _ _DBUFFER_MRT1 _DBUFFER_MRT2 _DBUFFER_MRT3
            #pragma multi_compile_fragment _ DEBUG_DISPLAY
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_POSITION_WS
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define VARYINGS_NEED_VIEWDIRECTION_WS
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_UNLIT
            #define _FOG_FRAGMENT 1
            #define _ALPHATEST_ON 1
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DBuffer.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
            {
                 float3 positionOS : POSITION;
                 float3 normalOS : NORMAL;
                 float4 tangentOS : TANGENT;
                 float4 uv0 : TEXCOORD0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                 float4 positionCS : SV_POSITION;
                 float3 positionWS;
                 float3 normalWS;
                 float4 texCoord0;
                 float3 viewDirectionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs
            {
                 float4 uv0;
            };
            struct VertexDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 ObjectSpacePosition;
            };
            struct PackedVaryings
            {
                 float4 positionCS : SV_POSITION;
                 float3 interp0 : INTERP0;
                 float3 interp1 : INTERP1;
                 float4 interp2 : INTERP2;
                 float3 interp3 : INTERP3;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            PackedVaryings PackVaryings (Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                output.interp0.xyz =  input.positionWS;
                output.interp1.xyz =  input.normalWS;
                output.interp2.xyzw =  input.texCoord0;
                output.interp3.xyz =  input.viewDirectionWS;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            Varyings UnpackVaryings (PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.positionWS = input.interp0.xyz;
                output.normalWS = input.interp1.xyz;
                output.texCoord0 = input.interp2.xyzw;
                output.viewDirectionWS = input.interp3.xyz;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            float _Metallic;
            float _Smoothness;
            float _NormalsStrength;
            float4 _Albedo_TexelSize;
            float4 _Normals_TexelSize;
            float4 _AmbientOcclusion_TexelSize;
            float _AmbientOcclusionStrength;
            float4 _DissolveColor;
            float _DissolveAmount;
            float _DissolveWidth;
            float _DissolveScale;
            CBUFFER_END
            
            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_Albedo);
            SAMPLER(sampler_Albedo);
            TEXTURE2D(_Normals);
            SAMPLER(sampler_Normals);
            TEXTURE2D(_AmbientOcclusion);
            SAMPLER(sampler_AmbientOcclusion);
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
            void Unity_Multiply_float4_float4(float4 A, float4 B, out float4 Out)
            {
                Out = A * B;
            }
            
            
            inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
            {
                float angle = dot(uv, float2(12.9898, 78.233));
                #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                    // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                    angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
                #endif
                return frac(sin(angle)*43758.5453);
            }
            
            inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
            {
                return (1.0-t)*a + (t*b);
            }
            
            
            inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                f = f * f * (3.0 - 2.0 * f);
            
                uv = abs(frac(uv) - 0.5);
                float2 c0 = i + float2(0.0, 0.0);
                float2 c1 = i + float2(1.0, 0.0);
                float2 c2 = i + float2(0.0, 1.0);
                float2 c3 = i + float2(1.0, 1.0);
                float r0 = Unity_SimpleNoise_RandomValue_float(c0);
                float r1 = Unity_SimpleNoise_RandomValue_float(c1);
                float r2 = Unity_SimpleNoise_RandomValue_float(c2);
                float r3 = Unity_SimpleNoise_RandomValue_float(c3);
            
                float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
                float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
                float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
                return t;
            }
            void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
            {
                float t = 0.0;
            
                float freq = pow(2.0, float(0));
                float amp = pow(0.5, float(3-0));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(1));
                amp = pow(0.5, float(3-1));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(2));
                amp = pow(0.5, float(3-2));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                Out = t;
            }
            
            void Unity_Add_float(float A, float B, out float Out)
            {
                Out = A + B;
            }
            
            void Unity_Step_float(float Edge, float In, out float Out)
            {
                Out = step(Edge, In);
            }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
            {
                float3 BaseColor;
                float Alpha;
                float AlphaClipThreshold;
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float4 _Property_7e99dd926f964644b2bdb64d1ac98304_Out_0 = IsGammaSpace() ? LinearToSRGB(_Color) : _Color;
                UnityTexture2D _Property_374ab744c684403fa921ce33bd75d3b8_Out_0 = UnityBuildTexture2DStructNoScale(_Albedo);
                float4 _SampleTexture2D_851146e9a7f74c459b59d676cf3d6dee_RGBA_0 = SAMPLE_TEXTURE2D(_Property_374ab744c684403fa921ce33bd75d3b8_Out_0.tex, _Property_374ab744c684403fa921ce33bd75d3b8_Out_0.samplerstate, _Property_374ab744c684403fa921ce33bd75d3b8_Out_0.GetTransformedUV(IN.uv0.xy));
                float _SampleTexture2D_851146e9a7f74c459b59d676cf3d6dee_R_4 = _SampleTexture2D_851146e9a7f74c459b59d676cf3d6dee_RGBA_0.r;
                float _SampleTexture2D_851146e9a7f74c459b59d676cf3d6dee_G_5 = _SampleTexture2D_851146e9a7f74c459b59d676cf3d6dee_RGBA_0.g;
                float _SampleTexture2D_851146e9a7f74c459b59d676cf3d6dee_B_6 = _SampleTexture2D_851146e9a7f74c459b59d676cf3d6dee_RGBA_0.b;
                float _SampleTexture2D_851146e9a7f74c459b59d676cf3d6dee_A_7 = _SampleTexture2D_851146e9a7f74c459b59d676cf3d6dee_RGBA_0.a;
                float4 _Multiply_ef5d2758e2404b7fa0b48f5d2f09bf6b_Out_2;
                Unity_Multiply_float4_float4(_Property_7e99dd926f964644b2bdb64d1ac98304_Out_0, _SampleTexture2D_851146e9a7f74c459b59d676cf3d6dee_RGBA_0, _Multiply_ef5d2758e2404b7fa0b48f5d2f09bf6b_Out_2);
                float _Property_ddddf6bf9923471e9d49214a88848944_Out_0 = _DissolveScale;
                float _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2;
                Unity_SimpleNoise_float(IN.uv0.xy, _Property_ddddf6bf9923471e9d49214a88848944_Out_0, _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2);
                float _Property_5c97f20724fb4c2aaae791101d937138_Out_0 = _DissolveWidth;
                float _Property_17aad81e47934bc4818f4debb8c3a7b8_Out_0 = _DissolveAmount;
                float _Add_a2fb0c9dcc9348d3a5fffa0ffe4267f0_Out_2;
                Unity_Add_float(_Property_5c97f20724fb4c2aaae791101d937138_Out_0, _Property_17aad81e47934bc4818f4debb8c3a7b8_Out_0, _Add_a2fb0c9dcc9348d3a5fffa0ffe4267f0_Out_2);
                float _Step_9a18a45d15644c56ad4cb6c4b7b184ae_Out_2;
                Unity_Step_float(_SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2, _Add_a2fb0c9dcc9348d3a5fffa0ffe4267f0_Out_2, _Step_9a18a45d15644c56ad4cb6c4b7b184ae_Out_2);
                float4 _Property_e061f5137200443db66277cadb245dfc_Out_0 = IsGammaSpace() ? LinearToSRGB(_DissolveColor) : _DissolveColor;
                float4 _Multiply_eb8669151edd4776a700bb3eda19948f_Out_2;
                Unity_Multiply_float4_float4((_Step_9a18a45d15644c56ad4cb6c4b7b184ae_Out_2.xxxx), _Property_e061f5137200443db66277cadb245dfc_Out_0, _Multiply_eb8669151edd4776a700bb3eda19948f_Out_2);
                float4 _Multiply_4bb5ea100aff4bc0aee774e4ec3e7cb8_Out_2;
                Unity_Multiply_float4_float4(_Multiply_ef5d2758e2404b7fa0b48f5d2f09bf6b_Out_2, _Multiply_eb8669151edd4776a700bb3eda19948f_Out_2, _Multiply_4bb5ea100aff4bc0aee774e4ec3e7cb8_Out_2);
                surface.BaseColor = (_Multiply_4bb5ea100aff4bc0aee774e4ec3e7cb8_Out_2.xyz);
                surface.Alpha = _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2;
                surface.AlphaClipThreshold = _Property_17aad81e47934bc4818f4debb8c3a7b8_Out_0;
                return surface;
            }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
            
                output.ObjectSpaceNormal =                          input.normalOS;
                output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                output.ObjectSpacePosition =                        input.positionOS;
            
                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
            
            #ifdef HAVE_VFX_MODIFICATION
                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
            
            #endif
            
                
            
            
            
            
            
                output.uv0 = input.texCoord0;
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            
                    return output;
            }
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/UnlitPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
            Pass
            {
                Name "DepthOnly"
                Tags
                {
                    "LightMode" = "DepthOnly"
                }
            
            // Render State
            Cull Back
            ZTest LEqual
            ZWrite On
            ColorMask 0
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 2.0
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma multi_compile_instancing
            #pragma vertex vert
            #pragma fragment frag
            
            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>
            
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
            #define _ALPHATEST_ON 1
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
            {
                 float3 positionOS : POSITION;
                 float3 normalOS : NORMAL;
                 float4 tangentOS : TANGENT;
                 float4 uv0 : TEXCOORD0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                 float4 positionCS : SV_POSITION;
                 float4 texCoord0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs
            {
                 float4 uv0;
            };
            struct VertexDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 ObjectSpacePosition;
            };
            struct PackedVaryings
            {
                 float4 positionCS : SV_POSITION;
                 float4 interp0 : INTERP0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            PackedVaryings PackVaryings (Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                output.interp0.xyzw =  input.texCoord0;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            Varyings UnpackVaryings (PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.texCoord0 = input.interp0.xyzw;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            float _Metallic;
            float _Smoothness;
            float _NormalsStrength;
            float4 _Albedo_TexelSize;
            float4 _Normals_TexelSize;
            float4 _AmbientOcclusion_TexelSize;
            float _AmbientOcclusionStrength;
            float4 _DissolveColor;
            float _DissolveAmount;
            float _DissolveWidth;
            float _DissolveScale;
            CBUFFER_END
            
            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_Albedo);
            SAMPLER(sampler_Albedo);
            TEXTURE2D(_Normals);
            SAMPLER(sampler_Normals);
            TEXTURE2D(_AmbientOcclusion);
            SAMPLER(sampler_AmbientOcclusion);
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
            
            inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
            {
                float angle = dot(uv, float2(12.9898, 78.233));
                #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                    // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                    angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
                #endif
                return frac(sin(angle)*43758.5453);
            }
            
            inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
            {
                return (1.0-t)*a + (t*b);
            }
            
            
            inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                f = f * f * (3.0 - 2.0 * f);
            
                uv = abs(frac(uv) - 0.5);
                float2 c0 = i + float2(0.0, 0.0);
                float2 c1 = i + float2(1.0, 0.0);
                float2 c2 = i + float2(0.0, 1.0);
                float2 c3 = i + float2(1.0, 1.0);
                float r0 = Unity_SimpleNoise_RandomValue_float(c0);
                float r1 = Unity_SimpleNoise_RandomValue_float(c1);
                float r2 = Unity_SimpleNoise_RandomValue_float(c2);
                float r3 = Unity_SimpleNoise_RandomValue_float(c3);
            
                float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
                float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
                float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
                return t;
            }
            void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
            {
                float t = 0.0;
            
                float freq = pow(2.0, float(0));
                float amp = pow(0.5, float(3-0));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(1));
                amp = pow(0.5, float(3-1));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(2));
                amp = pow(0.5, float(3-2));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                Out = t;
            }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
            {
                float Alpha;
                float AlphaClipThreshold;
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float _Property_ddddf6bf9923471e9d49214a88848944_Out_0 = _DissolveScale;
                float _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2;
                Unity_SimpleNoise_float(IN.uv0.xy, _Property_ddddf6bf9923471e9d49214a88848944_Out_0, _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2);
                float _Property_17aad81e47934bc4818f4debb8c3a7b8_Out_0 = _DissolveAmount;
                surface.Alpha = _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2;
                surface.AlphaClipThreshold = _Property_17aad81e47934bc4818f4debb8c3a7b8_Out_0;
                return surface;
            }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
            
                output.ObjectSpaceNormal =                          input.normalOS;
                output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                output.ObjectSpacePosition =                        input.positionOS;
            
                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
            
            #ifdef HAVE_VFX_MODIFICATION
                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
            
            #endif
            
                
            
            
            
            
            
                output.uv0 = input.texCoord0;
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            
                    return output;
            }
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthOnlyPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
            Pass
            {
                Name "DepthNormalsOnly"
                Tags
                {
                    "LightMode" = "DepthNormalsOnly"
                }
            
            // Render State
            Cull Back
            ZTest LEqual
            ZWrite On
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 2.0
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma multi_compile_instancing
            #pragma vertex vert
            #pragma fragment frag
            
            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>
            
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define ATTRIBUTES_NEED_TEXCOORD1
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TANGENT_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
            #define _ALPHATEST_ON 1
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
            {
                 float3 positionOS : POSITION;
                 float3 normalOS : NORMAL;
                 float4 tangentOS : TANGENT;
                 float4 uv0 : TEXCOORD0;
                 float4 uv1 : TEXCOORD1;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                 float4 positionCS : SV_POSITION;
                 float3 normalWS;
                 float4 tangentWS;
                 float4 texCoord0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs
            {
                 float4 uv0;
            };
            struct VertexDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 ObjectSpacePosition;
            };
            struct PackedVaryings
            {
                 float4 positionCS : SV_POSITION;
                 float3 interp0 : INTERP0;
                 float4 interp1 : INTERP1;
                 float4 interp2 : INTERP2;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            PackedVaryings PackVaryings (Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                output.interp0.xyz =  input.normalWS;
                output.interp1.xyzw =  input.tangentWS;
                output.interp2.xyzw =  input.texCoord0;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            Varyings UnpackVaryings (PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.normalWS = input.interp0.xyz;
                output.tangentWS = input.interp1.xyzw;
                output.texCoord0 = input.interp2.xyzw;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            float _Metallic;
            float _Smoothness;
            float _NormalsStrength;
            float4 _Albedo_TexelSize;
            float4 _Normals_TexelSize;
            float4 _AmbientOcclusion_TexelSize;
            float _AmbientOcclusionStrength;
            float4 _DissolveColor;
            float _DissolveAmount;
            float _DissolveWidth;
            float _DissolveScale;
            CBUFFER_END
            
            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_Albedo);
            SAMPLER(sampler_Albedo);
            TEXTURE2D(_Normals);
            SAMPLER(sampler_Normals);
            TEXTURE2D(_AmbientOcclusion);
            SAMPLER(sampler_AmbientOcclusion);
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
            
            inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
            {
                float angle = dot(uv, float2(12.9898, 78.233));
                #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                    // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                    angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
                #endif
                return frac(sin(angle)*43758.5453);
            }
            
            inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
            {
                return (1.0-t)*a + (t*b);
            }
            
            
            inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                f = f * f * (3.0 - 2.0 * f);
            
                uv = abs(frac(uv) - 0.5);
                float2 c0 = i + float2(0.0, 0.0);
                float2 c1 = i + float2(1.0, 0.0);
                float2 c2 = i + float2(0.0, 1.0);
                float2 c3 = i + float2(1.0, 1.0);
                float r0 = Unity_SimpleNoise_RandomValue_float(c0);
                float r1 = Unity_SimpleNoise_RandomValue_float(c1);
                float r2 = Unity_SimpleNoise_RandomValue_float(c2);
                float r3 = Unity_SimpleNoise_RandomValue_float(c3);
            
                float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
                float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
                float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
                return t;
            }
            void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
            {
                float t = 0.0;
            
                float freq = pow(2.0, float(0));
                float amp = pow(0.5, float(3-0));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(1));
                amp = pow(0.5, float(3-1));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(2));
                amp = pow(0.5, float(3-2));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                Out = t;
            }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
            {
                float Alpha;
                float AlphaClipThreshold;
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float _Property_ddddf6bf9923471e9d49214a88848944_Out_0 = _DissolveScale;
                float _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2;
                Unity_SimpleNoise_float(IN.uv0.xy, _Property_ddddf6bf9923471e9d49214a88848944_Out_0, _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2);
                float _Property_17aad81e47934bc4818f4debb8c3a7b8_Out_0 = _DissolveAmount;
                surface.Alpha = _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2;
                surface.AlphaClipThreshold = _Property_17aad81e47934bc4818f4debb8c3a7b8_Out_0;
                return surface;
            }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
            
                output.ObjectSpaceNormal =                          input.normalOS;
                output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                output.ObjectSpacePosition =                        input.positionOS;
            
                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
            
            #ifdef HAVE_VFX_MODIFICATION
                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
            
            #endif
            
                
            
            
            
            
            
                output.uv0 = input.texCoord0;
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            
                    return output;
            }
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
            Pass
            {
                Name "ShadowCaster"
                Tags
                {
                    "LightMode" = "ShadowCaster"
                }
            
            // Render State
            Cull Back
            ZTest LEqual
            ZWrite On
            ColorMask 0
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 2.0
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma multi_compile_instancing
            #pragma vertex vert
            #pragma fragment frag
            
            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>
            
            // Keywords
            #pragma multi_compile_vertex _ _CASTING_PUNCTUAL_LIGHT_SHADOW
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_SHADOWCASTER
            #define _ALPHATEST_ON 1
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
            {
                 float3 positionOS : POSITION;
                 float3 normalOS : NORMAL;
                 float4 tangentOS : TANGENT;
                 float4 uv0 : TEXCOORD0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                 float4 positionCS : SV_POSITION;
                 float3 normalWS;
                 float4 texCoord0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs
            {
                 float4 uv0;
            };
            struct VertexDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 ObjectSpacePosition;
            };
            struct PackedVaryings
            {
                 float4 positionCS : SV_POSITION;
                 float3 interp0 : INTERP0;
                 float4 interp1 : INTERP1;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            PackedVaryings PackVaryings (Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                output.interp0.xyz =  input.normalWS;
                output.interp1.xyzw =  input.texCoord0;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            Varyings UnpackVaryings (PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.normalWS = input.interp0.xyz;
                output.texCoord0 = input.interp1.xyzw;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            float _Metallic;
            float _Smoothness;
            float _NormalsStrength;
            float4 _Albedo_TexelSize;
            float4 _Normals_TexelSize;
            float4 _AmbientOcclusion_TexelSize;
            float _AmbientOcclusionStrength;
            float4 _DissolveColor;
            float _DissolveAmount;
            float _DissolveWidth;
            float _DissolveScale;
            CBUFFER_END
            
            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_Albedo);
            SAMPLER(sampler_Albedo);
            TEXTURE2D(_Normals);
            SAMPLER(sampler_Normals);
            TEXTURE2D(_AmbientOcclusion);
            SAMPLER(sampler_AmbientOcclusion);
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
            
            inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
            {
                float angle = dot(uv, float2(12.9898, 78.233));
                #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                    // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                    angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
                #endif
                return frac(sin(angle)*43758.5453);
            }
            
            inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
            {
                return (1.0-t)*a + (t*b);
            }
            
            
            inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                f = f * f * (3.0 - 2.0 * f);
            
                uv = abs(frac(uv) - 0.5);
                float2 c0 = i + float2(0.0, 0.0);
                float2 c1 = i + float2(1.0, 0.0);
                float2 c2 = i + float2(0.0, 1.0);
                float2 c3 = i + float2(1.0, 1.0);
                float r0 = Unity_SimpleNoise_RandomValue_float(c0);
                float r1 = Unity_SimpleNoise_RandomValue_float(c1);
                float r2 = Unity_SimpleNoise_RandomValue_float(c2);
                float r3 = Unity_SimpleNoise_RandomValue_float(c3);
            
                float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
                float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
                float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
                return t;
            }
            void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
            {
                float t = 0.0;
            
                float freq = pow(2.0, float(0));
                float amp = pow(0.5, float(3-0));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(1));
                amp = pow(0.5, float(3-1));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(2));
                amp = pow(0.5, float(3-2));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                Out = t;
            }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
            {
                float Alpha;
                float AlphaClipThreshold;
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float _Property_ddddf6bf9923471e9d49214a88848944_Out_0 = _DissolveScale;
                float _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2;
                Unity_SimpleNoise_float(IN.uv0.xy, _Property_ddddf6bf9923471e9d49214a88848944_Out_0, _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2);
                float _Property_17aad81e47934bc4818f4debb8c3a7b8_Out_0 = _DissolveAmount;
                surface.Alpha = _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2;
                surface.AlphaClipThreshold = _Property_17aad81e47934bc4818f4debb8c3a7b8_Out_0;
                return surface;
            }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
            
                output.ObjectSpaceNormal =                          input.normalOS;
                output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                output.ObjectSpacePosition =                        input.positionOS;
            
                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
            
            #ifdef HAVE_VFX_MODIFICATION
                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
            
            #endif
            
                
            
            
            
            
            
                output.uv0 = input.texCoord0;
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            
                    return output;
            }
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShadowCasterPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
            Pass
            {
                Name "SceneSelectionPass"
                Tags
                {
                    "LightMode" = "SceneSelectionPass"
                }
            
            // Render State
            Cull Off
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 2.0
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma multi_compile_instancing
            #pragma vertex vert
            #pragma fragment frag
            
            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>
            
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
            #define SCENESELECTIONPASS 1
            #define ALPHA_CLIP_THRESHOLD 1
            #define _ALPHATEST_ON 1
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
            {
                 float3 positionOS : POSITION;
                 float3 normalOS : NORMAL;
                 float4 tangentOS : TANGENT;
                 float4 uv0 : TEXCOORD0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                 float4 positionCS : SV_POSITION;
                 float4 texCoord0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs
            {
                 float4 uv0;
            };
            struct VertexDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 ObjectSpacePosition;
            };
            struct PackedVaryings
            {
                 float4 positionCS : SV_POSITION;
                 float4 interp0 : INTERP0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            PackedVaryings PackVaryings (Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                output.interp0.xyzw =  input.texCoord0;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            Varyings UnpackVaryings (PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.texCoord0 = input.interp0.xyzw;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            float _Metallic;
            float _Smoothness;
            float _NormalsStrength;
            float4 _Albedo_TexelSize;
            float4 _Normals_TexelSize;
            float4 _AmbientOcclusion_TexelSize;
            float _AmbientOcclusionStrength;
            float4 _DissolveColor;
            float _DissolveAmount;
            float _DissolveWidth;
            float _DissolveScale;
            CBUFFER_END
            
            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_Albedo);
            SAMPLER(sampler_Albedo);
            TEXTURE2D(_Normals);
            SAMPLER(sampler_Normals);
            TEXTURE2D(_AmbientOcclusion);
            SAMPLER(sampler_AmbientOcclusion);
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
            
            inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
            {
                float angle = dot(uv, float2(12.9898, 78.233));
                #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                    // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                    angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
                #endif
                return frac(sin(angle)*43758.5453);
            }
            
            inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
            {
                return (1.0-t)*a + (t*b);
            }
            
            
            inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                f = f * f * (3.0 - 2.0 * f);
            
                uv = abs(frac(uv) - 0.5);
                float2 c0 = i + float2(0.0, 0.0);
                float2 c1 = i + float2(1.0, 0.0);
                float2 c2 = i + float2(0.0, 1.0);
                float2 c3 = i + float2(1.0, 1.0);
                float r0 = Unity_SimpleNoise_RandomValue_float(c0);
                float r1 = Unity_SimpleNoise_RandomValue_float(c1);
                float r2 = Unity_SimpleNoise_RandomValue_float(c2);
                float r3 = Unity_SimpleNoise_RandomValue_float(c3);
            
                float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
                float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
                float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
                return t;
            }
            void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
            {
                float t = 0.0;
            
                float freq = pow(2.0, float(0));
                float amp = pow(0.5, float(3-0));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(1));
                amp = pow(0.5, float(3-1));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(2));
                amp = pow(0.5, float(3-2));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                Out = t;
            }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
            {
                float Alpha;
                float AlphaClipThreshold;
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float _Property_ddddf6bf9923471e9d49214a88848944_Out_0 = _DissolveScale;
                float _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2;
                Unity_SimpleNoise_float(IN.uv0.xy, _Property_ddddf6bf9923471e9d49214a88848944_Out_0, _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2);
                float _Property_17aad81e47934bc4818f4debb8c3a7b8_Out_0 = _DissolveAmount;
                surface.Alpha = _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2;
                surface.AlphaClipThreshold = _Property_17aad81e47934bc4818f4debb8c3a7b8_Out_0;
                return surface;
            }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
            
                output.ObjectSpaceNormal =                          input.normalOS;
                output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                output.ObjectSpacePosition =                        input.positionOS;
            
                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
            
            #ifdef HAVE_VFX_MODIFICATION
                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
            
            #endif
            
                
            
            
            
            
            
                output.uv0 = input.texCoord0;
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            
                    return output;
            }
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
            Pass
            {
                Name "ScenePickingPass"
                Tags
                {
                    "LightMode" = "Picking"
                }
            
            // Render State
            Cull Back
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 2.0
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma multi_compile_instancing
            #pragma vertex vert
            #pragma fragment frag
            
            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>
            
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHONLY
            #define SCENEPICKINGPASS 1
            #define ALPHA_CLIP_THRESHOLD 1
            #define _ALPHATEST_ON 1
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
            {
                 float3 positionOS : POSITION;
                 float3 normalOS : NORMAL;
                 float4 tangentOS : TANGENT;
                 float4 uv0 : TEXCOORD0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                 float4 positionCS : SV_POSITION;
                 float4 texCoord0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs
            {
                 float4 uv0;
            };
            struct VertexDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 ObjectSpacePosition;
            };
            struct PackedVaryings
            {
                 float4 positionCS : SV_POSITION;
                 float4 interp0 : INTERP0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            PackedVaryings PackVaryings (Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                output.interp0.xyzw =  input.texCoord0;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            Varyings UnpackVaryings (PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.texCoord0 = input.interp0.xyzw;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            float _Metallic;
            float _Smoothness;
            float _NormalsStrength;
            float4 _Albedo_TexelSize;
            float4 _Normals_TexelSize;
            float4 _AmbientOcclusion_TexelSize;
            float _AmbientOcclusionStrength;
            float4 _DissolveColor;
            float _DissolveAmount;
            float _DissolveWidth;
            float _DissolveScale;
            CBUFFER_END
            
            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_Albedo);
            SAMPLER(sampler_Albedo);
            TEXTURE2D(_Normals);
            SAMPLER(sampler_Normals);
            TEXTURE2D(_AmbientOcclusion);
            SAMPLER(sampler_AmbientOcclusion);
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
            
            inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
            {
                float angle = dot(uv, float2(12.9898, 78.233));
                #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                    // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                    angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
                #endif
                return frac(sin(angle)*43758.5453);
            }
            
            inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
            {
                return (1.0-t)*a + (t*b);
            }
            
            
            inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                f = f * f * (3.0 - 2.0 * f);
            
                uv = abs(frac(uv) - 0.5);
                float2 c0 = i + float2(0.0, 0.0);
                float2 c1 = i + float2(1.0, 0.0);
                float2 c2 = i + float2(0.0, 1.0);
                float2 c3 = i + float2(1.0, 1.0);
                float r0 = Unity_SimpleNoise_RandomValue_float(c0);
                float r1 = Unity_SimpleNoise_RandomValue_float(c1);
                float r2 = Unity_SimpleNoise_RandomValue_float(c2);
                float r3 = Unity_SimpleNoise_RandomValue_float(c3);
            
                float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
                float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
                float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
                return t;
            }
            void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
            {
                float t = 0.0;
            
                float freq = pow(2.0, float(0));
                float amp = pow(0.5, float(3-0));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(1));
                amp = pow(0.5, float(3-1));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(2));
                amp = pow(0.5, float(3-2));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                Out = t;
            }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
            {
                float Alpha;
                float AlphaClipThreshold;
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float _Property_ddddf6bf9923471e9d49214a88848944_Out_0 = _DissolveScale;
                float _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2;
                Unity_SimpleNoise_float(IN.uv0.xy, _Property_ddddf6bf9923471e9d49214a88848944_Out_0, _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2);
                float _Property_17aad81e47934bc4818f4debb8c3a7b8_Out_0 = _DissolveAmount;
                surface.Alpha = _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2;
                surface.AlphaClipThreshold = _Property_17aad81e47934bc4818f4debb8c3a7b8_Out_0;
                return surface;
            }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
            
                output.ObjectSpaceNormal =                          input.normalOS;
                output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                output.ObjectSpacePosition =                        input.positionOS;
            
                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
            
            #ifdef HAVE_VFX_MODIFICATION
                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
            
            #endif
            
                
            
            
            
            
            
                output.uv0 = input.texCoord0;
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            
                    return output;
            }
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/SelectionPickingPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
            Pass
            {
                Name "DepthNormals"
                Tags
                {
                    "LightMode" = "DepthNormalsOnly"
                }
            
            // Render State
            Cull Back
            ZTest LEqual
            ZWrite On
            
            // Debug
            // <None>
            
            // --------------------------------------------------
            // Pass
            
            HLSLPROGRAM
            
            // Pragmas
            #pragma target 2.0
            #pragma only_renderers gles gles3 glcore d3d11
            #pragma multi_compile_instancing
            #pragma multi_compile_fog
            #pragma instancing_options renderinglayer
            #pragma vertex vert
            #pragma fragment frag
            
            // DotsInstancingOptions: <None>
            // HybridV1InjectedBuiltinProperties: <None>
            
            // Keywords
            // PassKeywords: <None>
            // GraphKeywords: <None>
            
            // Defines
            
            #define ATTRIBUTES_NEED_NORMAL
            #define ATTRIBUTES_NEED_TANGENT
            #define ATTRIBUTES_NEED_TEXCOORD0
            #define VARYINGS_NEED_NORMAL_WS
            #define VARYINGS_NEED_TEXCOORD0
            #define FEATURES_GRAPH_VERTEX
            /* WARNING: $splice Could not find named fragment 'PassInstancing' */
            #define SHADERPASS SHADERPASS_DEPTHNORMALSONLY
            #define _ALPHATEST_ON 1
            /* WARNING: $splice Could not find named fragment 'DotsInstancingVars' */
            
            
            // custom interpolator pre-include
            /* WARNING: $splice Could not find named fragment 'sgci_CustomInterpolatorPreInclude' */
            
            // Includes
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Texture.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/TextureStack.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/ShaderPass.hlsl"
            
            // --------------------------------------------------
            // Structs and Packing
            
            // custom interpolators pre packing
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPrePacking' */
            
            struct Attributes
            {
                 float3 positionOS : POSITION;
                 float3 normalOS : NORMAL;
                 float4 tangentOS : TANGENT;
                 float4 uv0 : TEXCOORD0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : INSTANCEID_SEMANTIC;
                #endif
            };
            struct Varyings
            {
                 float4 positionCS : SV_POSITION;
                 float3 normalWS;
                 float4 texCoord0;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            struct SurfaceDescriptionInputs
            {
                 float4 uv0;
            };
            struct VertexDescriptionInputs
            {
                 float3 ObjectSpaceNormal;
                 float3 ObjectSpaceTangent;
                 float3 ObjectSpacePosition;
            };
            struct PackedVaryings
            {
                 float4 positionCS : SV_POSITION;
                 float3 interp0 : INTERP0;
                 float4 interp1 : INTERP1;
                #if UNITY_ANY_INSTANCING_ENABLED
                 uint instanceID : CUSTOM_INSTANCE_ID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                 uint stereoTargetEyeIndexAsBlendIdx0 : BLENDINDICES0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                 uint stereoTargetEyeIndexAsRTArrayIdx : SV_RenderTargetArrayIndex;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                 FRONT_FACE_TYPE cullFace : FRONT_FACE_SEMANTIC;
                #endif
            };
            
            PackedVaryings PackVaryings (Varyings input)
            {
                PackedVaryings output;
                ZERO_INITIALIZE(PackedVaryings, output);
                output.positionCS = input.positionCS;
                output.interp0.xyz =  input.normalWS;
                output.interp1.xyzw =  input.texCoord0;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            Varyings UnpackVaryings (PackedVaryings input)
            {
                Varyings output;
                output.positionCS = input.positionCS;
                output.normalWS = input.interp0.xyz;
                output.texCoord0 = input.interp1.xyzw;
                #if UNITY_ANY_INSTANCING_ENABLED
                output.instanceID = input.instanceID;
                #endif
                #if (defined(UNITY_STEREO_MULTIVIEW_ENABLED)) || (defined(UNITY_STEREO_INSTANCING_ENABLED) && (defined(SHADER_API_GLES3) || defined(SHADER_API_GLCORE)))
                output.stereoTargetEyeIndexAsBlendIdx0 = input.stereoTargetEyeIndexAsBlendIdx0;
                #endif
                #if (defined(UNITY_STEREO_INSTANCING_ENABLED))
                output.stereoTargetEyeIndexAsRTArrayIdx = input.stereoTargetEyeIndexAsRTArrayIdx;
                #endif
                #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
                output.cullFace = input.cullFace;
                #endif
                return output;
            }
            
            
            // --------------------------------------------------
            // Graph
            
            // Graph Properties
            CBUFFER_START(UnityPerMaterial)
            float4 _Color;
            float _Metallic;
            float _Smoothness;
            float _NormalsStrength;
            float4 _Albedo_TexelSize;
            float4 _Normals_TexelSize;
            float4 _AmbientOcclusion_TexelSize;
            float _AmbientOcclusionStrength;
            float4 _DissolveColor;
            float _DissolveAmount;
            float _DissolveWidth;
            float _DissolveScale;
            CBUFFER_END
            
            // Object and Global properties
            SAMPLER(SamplerState_Linear_Repeat);
            TEXTURE2D(_Albedo);
            SAMPLER(sampler_Albedo);
            TEXTURE2D(_Normals);
            SAMPLER(sampler_Normals);
            TEXTURE2D(_AmbientOcclusion);
            SAMPLER(sampler_AmbientOcclusion);
            
            // Graph Includes
            // GraphIncludes: <None>
            
            // -- Property used by ScenePickingPass
            #ifdef SCENEPICKINGPASS
            float4 _SelectionID;
            #endif
            
            // -- Properties used by SceneSelectionPass
            #ifdef SCENESELECTIONPASS
            int _ObjectId;
            int _PassValue;
            #endif
            
            // Graph Functions
            
            
            inline float Unity_SimpleNoise_RandomValue_float (float2 uv)
            {
                float angle = dot(uv, float2(12.9898, 78.233));
                #if defined(SHADER_API_MOBILE) && (defined(SHADER_API_GLES) || defined(SHADER_API_GLES3) || defined(SHADER_API_VULKAN))
                    // 'sin()' has bad precision on Mali GPUs for inputs > 10000
                    angle = fmod(angle, TWO_PI); // Avoid large inputs to sin()
                #endif
                return frac(sin(angle)*43758.5453);
            }
            
            inline float Unity_SimpleNnoise_Interpolate_float (float a, float b, float t)
            {
                return (1.0-t)*a + (t*b);
            }
            
            
            inline float Unity_SimpleNoise_ValueNoise_float (float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                f = f * f * (3.0 - 2.0 * f);
            
                uv = abs(frac(uv) - 0.5);
                float2 c0 = i + float2(0.0, 0.0);
                float2 c1 = i + float2(1.0, 0.0);
                float2 c2 = i + float2(0.0, 1.0);
                float2 c3 = i + float2(1.0, 1.0);
                float r0 = Unity_SimpleNoise_RandomValue_float(c0);
                float r1 = Unity_SimpleNoise_RandomValue_float(c1);
                float r2 = Unity_SimpleNoise_RandomValue_float(c2);
                float r3 = Unity_SimpleNoise_RandomValue_float(c3);
            
                float bottomOfGrid = Unity_SimpleNnoise_Interpolate_float(r0, r1, f.x);
                float topOfGrid = Unity_SimpleNnoise_Interpolate_float(r2, r3, f.x);
                float t = Unity_SimpleNnoise_Interpolate_float(bottomOfGrid, topOfGrid, f.y);
                return t;
            }
            void Unity_SimpleNoise_float(float2 UV, float Scale, out float Out)
            {
                float t = 0.0;
            
                float freq = pow(2.0, float(0));
                float amp = pow(0.5, float(3-0));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(1));
                amp = pow(0.5, float(3-1));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                freq = pow(2.0, float(2));
                amp = pow(0.5, float(3-2));
                t += Unity_SimpleNoise_ValueNoise_float(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
            
                Out = t;
            }
            
            // Custom interpolators pre vertex
            /* WARNING: $splice Could not find named fragment 'CustomInterpolatorPreVertex' */
            
            // Graph Vertex
            struct VertexDescription
            {
                float3 Position;
                float3 Normal;
                float3 Tangent;
            };
            
            VertexDescription VertexDescriptionFunction(VertexDescriptionInputs IN)
            {
                VertexDescription description = (VertexDescription)0;
                description.Position = IN.ObjectSpacePosition;
                description.Normal = IN.ObjectSpaceNormal;
                description.Tangent = IN.ObjectSpaceTangent;
                return description;
            }
            
            // Custom interpolators, pre surface
            #ifdef FEATURES_GRAPH_VERTEX
            Varyings CustomInterpolatorPassThroughFunc(inout Varyings output, VertexDescription input)
            {
            return output;
            }
            #define CUSTOMINTERPOLATOR_VARYPASSTHROUGH_FUNC
            #endif
            
            // Graph Pixel
            struct SurfaceDescription
            {
                float Alpha;
                float AlphaClipThreshold;
            };
            
            SurfaceDescription SurfaceDescriptionFunction(SurfaceDescriptionInputs IN)
            {
                SurfaceDescription surface = (SurfaceDescription)0;
                float _Property_ddddf6bf9923471e9d49214a88848944_Out_0 = _DissolveScale;
                float _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2;
                Unity_SimpleNoise_float(IN.uv0.xy, _Property_ddddf6bf9923471e9d49214a88848944_Out_0, _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2);
                float _Property_17aad81e47934bc4818f4debb8c3a7b8_Out_0 = _DissolveAmount;
                surface.Alpha = _SimpleNoise_e158b2799c09422a88a300a1c131decd_Out_2;
                surface.AlphaClipThreshold = _Property_17aad81e47934bc4818f4debb8c3a7b8_Out_0;
                return surface;
            }
            
            // --------------------------------------------------
            // Build Graph Inputs
            #ifdef HAVE_VFX_MODIFICATION
            #define VFX_SRP_ATTRIBUTES Attributes
            #define VFX_SRP_VARYINGS Varyings
            #define VFX_SRP_SURFACE_INPUTS SurfaceDescriptionInputs
            #endif
            VertexDescriptionInputs BuildVertexDescriptionInputs(Attributes input)
            {
                VertexDescriptionInputs output;
                ZERO_INITIALIZE(VertexDescriptionInputs, output);
            
                output.ObjectSpaceNormal =                          input.normalOS;
                output.ObjectSpaceTangent =                         input.tangentOS.xyz;
                output.ObjectSpacePosition =                        input.positionOS;
            
                return output;
            }
            SurfaceDescriptionInputs BuildSurfaceDescriptionInputs(Varyings input)
            {
                SurfaceDescriptionInputs output;
                ZERO_INITIALIZE(SurfaceDescriptionInputs, output);
            
            #ifdef HAVE_VFX_MODIFICATION
                // FragInputs from VFX come from two places: Interpolator or CBuffer.
                /* WARNING: $splice Could not find named fragment 'VFXSetFragInputs' */
            
            #endif
            
                
            
            
            
            
            
                output.uv0 = input.texCoord0;
            #if defined(SHADER_STAGE_FRAGMENT) && defined(VARYINGS_NEED_CULLFACE)
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN output.FaceSign =                    IS_FRONT_VFACE(input.cullFace, true, false);
            #else
            #define BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            #endif
            #undef BUILD_SURFACE_DESCRIPTION_INPUTS_OUTPUT_FACESIGN
            
                    return output;
            }
            
            // --------------------------------------------------
            // Main
            
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/Varyings.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/Editor/ShaderGraph/Includes/DepthNormalsOnlyPass.hlsl"
            
            // --------------------------------------------------
            // Visual Effect Vertex Invocations
            #ifdef HAVE_VFX_MODIFICATION
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/VisualEffectVertex.hlsl"
            #endif
            
            ENDHLSL
            }
        }
        CustomEditorForRenderPipeline "UnityEditor.ShaderGraphUnlitGUI" "UnityEngine.Rendering.Universal.UniversalRenderPipelineAsset"
        CustomEditor "UnityEditor.ShaderGraph.GenericShaderGraphMaterialGUI"
        FallBack "Hidden/Shader Graph/FallbackError"
	/*Properties
	{
		// Stencil ID
		[IntRange] _StencilID("Stencil ID", Range(0,255)) = 0
		
		// Noise Texture
		_NoiseTexture("Noise Texture", 2D) = "white" {}
		
		// Dissolve Effect Properties
		_DissolveAmount("Dissolve Amount", Range(0, 1)) = 0
		_DissolveColor("Dissolve Color", Color) = (1,1,1,1)
		_DissolveScale("Dissolve Scale", Range(0,500)) = 30
		_DissolveBorderThickness("Dissolve Border Thickness", Range(0, 0.2)) = 0.02
	}

	SubShader{

		Tags {
			"RenderPipeline" = "UniversalPipeline"
			"RenderType" = "TransparentCutout"
			"Queue" = "AlphaTest"
		}

		Pass {
			Blend Zero One
			ZWrite Off
			
			Stencil{
				Ref [_StencilID]
				Comp Always
				Pass Replace
				Fail Keep
				ZFail Replace
			}
			
			HLSLPROGRAM
			#pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma vertex vert
            #pragma fragment frag
            
            //cg shader는 .cginc를 hlsl shader는 .hlsl을 include하게 됩니다.
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

			CBUFFER_START(UnityPerMaterial)
				float4 _DissolveColor;
				float _DissolveScale;
				float _DissolveBorderThickness;
			CBUFFER_END
			
			float _DissolveAmount;
			Texture2D _NoiseTex;
			float4 _NoiseTex_ST;
			SamplerState sampler_NoiseTex;
			
            struct VertexInput
            {
                float4 vertex : POSITION;
            	float2 uv : TEXCOORD0;
				float3 normal: NORMAL;
				UNITY_VERTEX_INPUT_INSTANCE_ID
            };
			
            struct VertexOutput
            {
                float4 vertex : SV_POSITION;
            	float2 uv : TEXCOORD0;
            	float3 normal: TEXCOORD2;
				UNITY_VERTEX_OUTPUT_STEREO
            };
			
            VertexOutput vert(VertexInput v)
            {
                VertexOutput o;

            	UNITY_SETUP_INSTANCE_ID(v); //Insert
			    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o); //Insert

            	o.vertex = TransformObjectToHClip(v.vertex.xyz);
            	o.normal = TransformObjectToWorldNormal(v.normal);

            	
                return o;
            }
			
            half4 frag(VertexOutput i) : SV_Target
            {
				float2 uv = i.uv.xy * _NoiseTex_ST.xy + _NoiseTex_ST.zw;
            	float4 surface = _NoiseTex.Sample(sampler_NoiseTex, uv).a;
            	float surfaceAlpha = _NoiseTex.Sample(sampler_NoiseTex, uv).a;
            	clip(surface.a - _DissolveAmount);
            	
            	return surface;
            }
			
			ENDHLSL
		}
	}*/
}