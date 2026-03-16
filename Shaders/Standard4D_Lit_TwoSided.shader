Shader "4DSurface/Surface4D_Lit_TwoSided"
//Shader "4DSurface/URP_Lit4D_MainShadow_TwoSided"
{
    Properties
    {
        _Translation4D("4D Translation", Vector) = (0,0,0,0)
        _BaseColor("Base Color", Color) = (1,1,1,1)
        _Smoothness("Smoothness", Range(0,1)) = 0.5
        _Specular("Specular", Range(0,1)) = 0.2
        _Ambient("Ambient", Range(0,1)) = 0.1
    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" }

        Pass
        {
            Name "UniversalForward"
            Tags { "LightMode"="UniversalForward" }

            Cull Off // ★両面描画

            HLSLPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag

            // Main light shadows only
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _SHADOWS_SOFT

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float4 color      : COLOR;
                float2 uv2        : TEXCOORD1; // uv2.x = w
            };

            struct Varyings
            {
                float4 positionHCS : SV_POSITION;
                float3 positionWS  : TEXCOORD0;
                float4 color       : TEXCOORD1;
                float4 shadowCoord : TEXCOORD2;
            };

            float4x4 _Rotation4D;
            float4   _Translation4D;

            half4 _BaseColor;
            half _Smoothness;
            half _Specular;
            half _Ambient;

            Varyings vert(Attributes v)
            {
                float4 p4 = float4(v.positionOS.xyz, v.uv2.x);
                p4 = mul(_Rotation4D, p4 + _Translation4D);

                float3 posOS = p4.xyz;

                Varyings o;
                VertexPositionInputs vp = GetVertexPositionInputs(posOS);

                o.positionHCS = vp.positionCS;
                o.positionWS  = vp.positionWS;
                o.color       = v.color;
                o.shadowCoord = GetShadowCoord(vp);
                return o;
            }

            inline half3 ShadeMainLight(half3 albedo, float3 N, float3 V, Light light, half smoothness, half specularStrength)
            {
                float3 L = normalize(light.direction);

                half ndotl = saturate(dot(N, L));
                half atten = (half)(light.distanceAttenuation * light.shadowAttenuation);

                half3 diff = albedo * light.color * (ndotl * atten);

                float3 H = normalize(L + V);
                half specPow = exp2(8.0h + smoothness * 10.0h);
                half spec = pow(saturate(dot(N, H)), specPow) * specularStrength;
                half3 spc = light.color * (spec * atten);

                return diff + spc;
            }

            half4 frag(Varyings i, bool isFrontFace : SV_IsFrontFace) : SV_Target
            {
                float3 dpdx = ddx(i.positionWS);
                float3 dpdy = ddy(i.positionWS);
                float3 N = normalize(cross(dpdy, dpdx));

                // ★裏面は法線を反転（これが最重要）
                if (!isFrontFace) N = -N;

                float3 V = normalize(GetWorldSpaceViewDir(i.positionWS));

                half3 albedo = i.color.rgb * _BaseColor.rgb;

                Light mainLight = GetMainLight(i.shadowCoord);
                half3 col = ShadeMainLight(albedo, N, V, mainLight, _Smoothness, _Specular);

                // 簡易Ambient（確実に黒を防ぐ）
                col += albedo * _Ambient;

                return half4(col, _BaseColor.a * i.color.a);
            }
            ENDHLSL
        }
    }
}