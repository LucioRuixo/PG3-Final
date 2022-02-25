Shader "Custom/Water_Surface"
{
    Properties
    {
        //_Color("Color", Color) = (1,1,1,1)
        //_MainTex("Albedo (RGB)", 2D) = "white" {}
        //_Glossiness("Smoothness", Range(0,1)) = 0.5
        //_Metallic("Metallic", Range(0,1)) = 0.0
        //[Space]
        _Smoothness("Smoothness", Range(0.0, 1.0)) = 0.5

        [Header(Water Colors)]
        [Space]
        _ShallowWaterColor("Shallow Water Color", Color) = (0.0, 0.0, 0.5, 1.0)
        _DeepWaterColor("Deep Water Color", Color) = (0.0, 0.0, 1.0, 1.0)

        [Header(Water Depth)]
        [Space]
        _Depth("Depth Level", Float) = 1.0
        _Strength("Gradient Strength", Range(0.0, 2.0)) = 1.0

        [Header(Normal Maps)]
        [Space]
        _MainNormal("Main Normal", 2D) = "bump" {}
        _MainNormalSpeed("Main Normal Speed", Float) = 1.0
        [Space]
        _SecondNormal("Second Normal", 2D) = "bump" {}
        _SecondNormalSpeed("Second Normal Speed", Float) = -0.5
        [Space]
        _NormalStrength("Normal Strength", Float) = 1.0
        _NormalSpeedDivider("Normal Speed Divider", Float) = 50.0

        [Header(Vertex Displacement)]
        [Space]
        _NoiseTexture("Noise", 2D) = "white" {}
        _DisplacementStrength("Displacement Strength", Float) = 1.0

        [HideInInspector] _ScreenWidth("Screen Width", Int) = 1920
        [HideInInspector] _ScreenHeight("Screen Height", Int) = 1080
        [HideInInspector] _FarPlane("Far Plane", Float) = 1000.0

            //[HideInInspector] _Time("Time", Float) = 1000.0
    }
    SubShader
    {
        //Tags { "RenderType"="Transparent" }
        Tags {"Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "Transparent"}
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha
        //Cull front
        LOD 100

        //Tags { "RenderType" = "Fade" }
        //LOD 200

        CGPROGRAM
        //#pragma surface surf Standard fullforwardshadows alpha:fade vertex:vert
        #pragma surface surf Standard fullforwardshadows vertex:vert
        #pragma target 3.0

        float _Smoothness;

        fixed4 _ShallowWaterColor;
        fixed4 _DeepWaterColor;

        //sampler2D _MainTex;
        //half4 _MainTex_TexelSize;
        //float4 _MainTex_ST;

        sampler2D _CameraDepthTexture;
        float _Depth;
        float _Strength;

        sampler2D _MainNormal;
        float _MainNormalSpeed;
        sampler2D _SecondNormal;
        float _SecondNormalSpeed;
        float _NormalStrength;
        float _NormalSpeedDivider;

        sampler2D _NoiseTexture;
        float _DisplacementStrength;

        int _ScreenWidth;
        int _ScreenHeight;
        float _FarPlane;

        struct Input
        {
            //float d;
            float4 vertex;
            float4 screenPos;
            float2 uv_MainNormal;
            float2 uv_SecondNormal;
            //float2 uv_NoiseTexture;
        };

        void vert(inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);

            //float displacement = tex2Dlod(_NoiseTexture, float4(o.uv_NoiseTexture.xy, 0.0, 0.0)).x * 2.0 - 1.0;
            //v.vertex.y = displacement * _DisplacementStrength;
            //o.d = tex2D(_NoiseTexture, float4(o.uv_NoiseTexture.xy, 0.0, 0.0)).x * 2.0 - 1.0;

            o.vertex = UnityObjectToClipPos(v.vertex);
        }

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
            //o.Albedo.rgb = tex2D(_NoiseTexture, IN.uv_NoiseTexture.xy).x * _DisplacementStrength;
            //o.Albedo.rgb = IN.d;
            //return;

            // Calcular la profundidad de cámara en este fragment
            float cameraDepth01 = SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(IN.screenPos));
            cameraDepth01 = Linear01Depth(cameraDepth01);

            float cameraDepth = cameraDepth01 * _FarPlane;

            // Calcular la profundidad del fragment
            float fragmentDepth = IN.vertex.w / 1000.0;

            // Generar profundidad del agua
            float depth = clamp((cameraDepth - fragmentDepth + _Depth) * _Strength, 0.0, 1.0);

            // Lerpear entre los dos colores de agua usando la profundidad
            float4 color = lerp(_ShallowWaterColor, _DeepWaterColor, depth);

            // Normal maps
            float time = _Time.y;

            float2 mainNormalUV = IN.uv_MainNormal + time * (_MainNormalSpeed / _NormalSpeedDivider);
            float3 mainNormal = UnpackNormal(tex2D(_MainNormal, mainNormalUV));

            float2 secondNormalUV = IN.uv_SecondNormal + time * (_SecondNormalSpeed / _NormalSpeedDivider);
            float3 secondNormal = UnpackNormal(tex2D(_SecondNormal, secondNormalUV));

            float3 normal = mainNormal + secondNormal;
            normal.xy *= lerp(0.0, _NormalStrength, depth);
            
            // Asignar las propiedades del material
            o.Albedo = color.rgb;
            o.Alpha = color.a;
            o.Smoothness = _Smoothness;
            o.Normal = normal;
        }
        ENDCG
    }
    FallBack "Diffuse"
}