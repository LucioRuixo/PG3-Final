Shader "Unlit/Water"
{
    Properties
    {
        _Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _MainTex ("Texture", 2D) = "white" {}

        _CameraDepthTexture("Depth Texture", 2D) = "" {}
        _DepthLevel ("Depth Level", Range(1.0, 5.0)) = 1.0
        _DegradationStrength ("Degradation Strength", Range(0.0, 1.0)) = 0.5

        [HideInInspector] _ScreenWidth("Screen Width", Int) = 1
        [HideInInspector] _ScreenHeight("Screen Height", Int) = 1
    }
    SubShader
    {
        //Tags { "RenderType"="Transparent" }
        Tags {"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        Cull front
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            //#pragma target 3.0

            #include "UnityCG.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            half4 _MainTex_TexelSize;
            float4 _MainTex_ST;

            sampler2D _CameraDepthTexture;
            float _DepthLevel;
            float _DegradationStrength;

            int _ScreenWidth;
            int _ScreenHeight;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            v2f vert (appdata v)
            //v2f vert (appdata v, out float4 vertex : SV_POSITION)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //vertex = UnityObjectToClipPos(v.vertex);

                //o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv = MultiplyUV(UNITY_MATRIX_TEXTURE0, v.uv);

                return o;
            }

            // CHECKEAR MAIL DEL PROFE PARA VER SI ES SERÁ NECESARIO HACER LO DE LA DISTANCIA A CÁMARA Y SINO INTENTAR ALGO MÁS FÁCIL uwu

            fixed4 frag(v2f i) : SV_Target
            //fixed4 frag(v2f i, UNITY_VPOS_TYPE screenPosition : VPOS) : SV_Target
            {
                //fixed4 depth = tex2D(_MainTex, i.uv) * UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.uv)) * _Color;

                //depth = pow(Linear01Depth(depth), _DepthLevel);

                //float2 clipPosition = (screenPosition.x / 1920);
                //fixed4 depth = tex2D(_CameraDepthTexture, i.uv) * _DepthLevel;

                //float depth = Linear01Depth(tex2D(_CameraDepthTexture, i.uv));
                //float depth = pow(Linear01Depth(UNITY_SAMPLE_DEPTH(i.uv)), _DepthLevel);
                //float depth = LinearEyeDepth(UNITY_SAMPLE_DEPTH(i.uv)) * _DepthLevel;

                //depth = Linear01Depth(depth);

                //UNITY_OUTPUT_DEPTH(i.uv);

                //float2 clipCoors = float2((i.vertex.x + 1.0) / 2.0, (i.vertex.y + 1.0) / 2.0);
                //float2 clipCoors = float2(i.vertex.x / _ScreenWidth, i.vertex.y / _ScreenHeight);
                //return fixed4((clipCoors.x + 1.0) / 2.0, (clipCoors.y + 1.0) / 2.0, 0.0, 1.0);
                //return fixed4(i.vertex.x / 500.0, i.vertex.y / 500.0, 0.0, 1.0);

                //fixed4 color = _Color;
                //color.a = depth.r;
                //return color;
                
                //fixed4 color = i.vertex;
                //return color;
                
                float2 clipPosition = float2(i.vertex.x / _ScreenWidth, i.vertex.y / _ScreenHeight);
                //float2 clipPosition = float2(i.vertex.x / 1000.0, i.vertex.y / 500.0);
                // 
                //fixed4 depth = tex2D(_CameraDepthTexture, clipPosition) * _DepthLevel;
                fixed4 depth = tex2D(_CameraDepthTexture, clipPosition);

                fixed4 color = _Color;
                //fixed4 color = fixed4(depth.r, 0.0, 0.0, 1.0);

                //color.a = depth.r + 0.025;
                //color.a = pow(depth.r, _DegradationStrength);
                //color.a = pow(Linear01Depth(UNITY_SAMPLE_DEPTH(i.uv)), _DepthLevel);
                //color.a = pow(Linear01Depth(clipPosition), _DepthLevel);
                color.a = pow(depth.r, _DegradationStrength) * _DepthLevel;
                return color;
            }
            ENDCG
        }
    }
}