Shader "4DSurface/Standard4D"
{
    Properties
    {
        _Translation4D("4D Translation", Vector) = (0, 0, 0, 0)
    }

    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 100
        Cull off

        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass {
        CGPROGRAM
        
        #pragma vertex vert
        #pragma fragment frag

        #pragma multi_compile_fog

        #include "UnityCG.cginc"

        struct appdata
        {
            float4 position : POSITION;
            //float3 normal : NORMAL;
            fixed4 color : COLOR;
            float2 uv2 : TEXCOORD1;
        };

        struct v2f
        {
            float4 vertex : SV_POSITION;
            UNITY_FOG_COORDS(1)
            fixed4 color : COLOR;
        };

        float4x4 _Rotation4D;
        float4 _Translation4D;

        sampler2D _MainTex;

        v2f vert (appdata input)
        {
            float4 pos4d = float4(input.position.xyz, input.uv2.x);
            pos4d = mul(_Rotation4D, pos4d) + _Translation4D;
            //pos4d = pos4d + _Translation4D;
            float4 pos = float4(pos4d.xyz, 1);
 
            v2f o;
            o.vertex = UnityObjectToClipPos(pos);
            //o.normal = UnityObjectToWorldNormal(v.normal);
            o.color = input.color;
            UNITY_TRANSFER_FOG(o,o.vertex);
            return o;
        }

        fixed4 frag(v2f input) : SV_Target
        {
            fixed4 col = input.color;
            UNITY_APPLY_FOG(input.fogcoord, col);
            return col;
        }

        ENDCG
        }
    }
    FallBack "Diffuse"
}
