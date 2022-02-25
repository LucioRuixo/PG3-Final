Shader "Unlit/Water"
{
    Properties
    {
        _ShallowWaterColor ("Shallow Water Color", Color) = (0.0, 0.0, 0.5, 1.0)
        _DeepWaterColor ("Deep Water Color", Color) = (0.0, 0.0, 1.0, 1.0)

        _MainTex ("Texture", 2D) = "white" {}

        _CameraDepthTexture("Depth Texture", 2D) = "" {}
        _Depth ("Depth Level", Float) = 1.0
        _Strength ("Gradient Strength", Range(0.0, 2.0)) = 1.0

        [HideInInspector] _ScreenWidth("Screen Width", Int) = 1920
        [HideInInspector] _ScreenHeight("Screen Height", Int) = 1080
        [HideInInspector] _FarPlane("Far Plane", Float) = 1000.0
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

            fixed4 _ShallowWaterColor;
            fixed4 _DeepWaterColor;

            sampler2D _MainTex;
            half4 _MainTex_TexelSize;
            float4 _MainTex_ST;

            sampler2D _CameraDepthTexture;
            float _Depth;
            float _Strength;

            int _ScreenWidth;
            int _ScreenHeight;
            float _FarPlane;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float4 rawScreenPosition : TEXCOORD0;
                //float2 uv : TEXCOORD0;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);

                o.rawScreenPosition = o.vertex;
                //o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //o.uv = MultiplyUV(UNITY_MATRIX_TEXTURE0, v.uv);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // Calcular la profundidad de cámara en este fragment
                float2 screenPosition = float2(i.vertex.x / _ScreenWidth, i.vertex.y / _ScreenHeight);

                float cameraDepth01 = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, screenPosition);
                cameraDepth01 = Linear01Depth(cameraDepth01);

                float cameraDepth = cameraDepth01 * _FarPlane;

                // Calcular la profundidad del fragment
                float fragmentDepth = i.rawScreenPosition.w;

                // Generar profundidad del agua
                float depth = clamp((cameraDepth - fragmentDepth + _Depth) * _Strength, 0.0, 1.0);

                // Lerpear entre los dos colores de agua usando la profundidad
                float4 color = lerp(_ShallowWaterColor, _DeepWaterColor, depth);
                //return color;
                return fixed4(i.vertex.x, i.vertex.y, 0.0, 1.0);
                //return fixed4(screenPosition.x, screenPosition.y, 0.0, 1.0);
                //return fixed4(fragmentDepth, fragmentDepth, fragmentDepth, 1.0);
                //return fixed4(cameraDepth, cameraDepth, cameraDepth, 1.0);
            }
            ENDCG
        }
    }
}