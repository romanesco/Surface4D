//Shader "4DSurface/URP_Lit4D_Fwd"
Shader "4DSurface/Surface4D_Lit"
//Shader "4DSurface/URP_Lit4D_MainShadow"
{
    Properties
    {
        _Translation4D("4D Translation", Vector) = (0,0,0,0)
        _BaseColor("Base Color", Color) = (1,1,1,1)
        _Smoothness("Smoothness", Range(0,1)) = 0.5
        _Specular("Specular", Range(0,1)) = 0.2
        _Metallic("Metallic", Range(0,1)) = 0.0
    }

    SubShader
    {
        Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Opaque" }

        Pass
        {
            Name "UniversalForward"
            Tags { "LightMode"="UniversalForward" }

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
                float2 uv2        : TEXCOORD1; // uv2.x を w として使う
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
            half _Metallic;

            Varyings vert(Attributes v)
            {
                // 4D -> 3D (object space)
                float4 p4 = float4(v.positionOS.xyz, v.uv2.x);
                p4 = mul(_Rotation4D, p4 + _Translation4D);

                float3 posOS = p4.xyz;

                Varyings o;
                VertexPositionInputs vp = GetVertexPositionInputs(posOS);

                o.positionHCS = vp.positionCS;
                o.positionWS  = vp.positionWS;
                o.color       = v.color;

                // main light shadow coord
                o.shadowCoord = GetShadowCoord(vp);
                return o;
            }

            inline half3 ShadeMainLight(half3 albedo, float3 N, float3 V, Light light,
                                        half smoothness, half specularStrength, half metallic)
            {
                float3 L = normalize(light.direction);

                half ndotl = saturate(dot(N, L));
                half atten = (half)(light.distanceAttenuation * light.shadowAttenuation);

                // metallic で diffuse を減らす（導体は拡散がほぼ無い）
                half3 diffuseColor = albedo * (1.0h - metallic);
                half3 diff = diffuseColor * light.color * (ndotl * atten);

                // metallic で spec を増やす（導体は反射が強い）
                float3 H = normalize(L + V);
                half specPow = exp2(8.0h + smoothness * 10.0h);

                // 非金属: 0.04, 金属: albedo をF0に寄せる
                half3 F0 = lerp(half3(0.04h, 0.04h, 0.04h), albedo, metallic);

                half specTerm = pow(saturate(dot(N, H)), specPow);
                half3 spc = light.color * (F0 * specTerm * specularStrength * atten);

                return diff + spc;
            }

            half4 frag(Varyings i) : SV_Target
            {
                // World-space face normal from derivatives (projection-a ware)
                float3 dpdx = ddx(i.positionWS);
                float3 dpdy = ddy(i.positionWS);
                float3 N = normalize(cross(dpdy, dpdx));

                // Two-sided-ish: flip normal toward camera
                float3 V = normalize(GetWorldSpaceViewDir(i.positionWS));
                N = faceforward(N, -V, N);

                half3 albedo = i.color.rgb * _BaseColor.rgb;

                // Main light with shadow
                Light mainLight = GetMainLight(i.shadowCoord);

                half3 col = ShadeMainLight(albedo, N, V, mainLight, _Smoothness, _Specular, _Metallic);

                // 環境光を追加
                half3 ambient = SampleSH(N) * albedo;
                col += ambient;
                return half4(col, _BaseColor.a * i.color.a);
            }
            ENDHLSL
        }
    }
}

