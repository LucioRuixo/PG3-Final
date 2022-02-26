Shader "Custom/Water_Surface"
{
    Properties
    {
        [Header(General Properties)]
        [Space]
        _Smoothness("Smoothness", Range(0.0, 1.0)) = 0.5
        _OffsetSpeedDivider("Offset Speed Divider", Float) = 50.0

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
        _MainOffsetSpeed("Main Offset Speed", Vector) = (1.0, 1.0, 0.0)
        [Space]
        _SecondNormal("Second Normal", 2D) = "bump" {}
        _SecondOffsetSpeed("Second Offset Speed", Vector) = (-0.5, -0.5, 0.0)
        [Space]
        _MinNormalStrength("Minimum Normal Strength", Float) = 0.25
        _NormalStrength("Normal Strength", Range(0.0, 5.0)) = 1.0

        [Header(Vertex Displacement)]
        [Space]
        _NoiseTexture("Noise", 2D) = "white" {}
        _NoiseOffsetSpeed("Noise Offset Speed", Vector) = (1.0, 1.0, 0.0)
        _DisplacementStrength("Displacement Strength", Float) = 1.0

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
        //Cull front
        LOD 100

        CGPROGRAM
        //#pragma surface surf Standard fullforwardshadows alpha:fade vertex:vert
        #pragma surface surf Standard fullforwardshadows vertex:vert
        #pragma target 3.5

        float _Smoothness;
        float _OffsetSpeedDivider;

        fixed4 _ShallowWaterColor;
        fixed4 _DeepWaterColor;

        sampler2D _CameraDepthTexture;
        float _Depth;
        float _Strength;


        sampler2D _MainNormal;
        float2 _MainOffsetSpeed;
        sampler2D _SecondNormal;
        float2 _SecondOffsetSpeed;
        float _MinNormalStrength;
        float _NormalStrength;

        sampler2D _NoiseTexture;
        float2 _NoiseOffsetSpeed;
        float _DisplacementStrength;

        int _ScreenWidth;
        int _ScreenHeight;
        float _FarPlane;

        struct Input
        {
            float4 noise;

            float4 vertex;
            float4 screenPos;

            float2 uv_MainNormal : TEXCOORD0;
            float2 uv_SecondNormal : TEXCOORD1;
            float2 uv_NoiseTexture : TEXCOORD2;
        };

        void vert(inout appdata_full v, out Input o)
        {
            UNITY_INITIALIZE_OUTPUT(Input, o);

            // Desplazar vertice en base a la textura de perlin noise
            float2 noiseUV = v.texcoord.xy + _Time.y * (_NoiseOffsetSpeed.xy / _OffsetSpeedDivider);
            float displacement = tex2Dlod(_NoiseTexture, float4(noiseUV, 0.0, 0.0)).x * 2.0 - 1.0;
            v.vertex.y = displacement * _DisplacementStrength;

            o.vertex = UnityObjectToClipPos(v.vertex);
        }

        void surf(Input IN, inout SurfaceOutputStandard o)
        {
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

            float2 mainNormalUV = IN.uv_MainNormal + time * (_MainOffsetSpeed.xy / _OffsetSpeedDivider);
            float3 mainNormal = UnpackNormal(tex2D(_MainNormal, mainNormalUV));

            float2 secondNormalUV = IN.uv_SecondNormal + time * (_SecondOffsetSpeed.xy / _OffsetSpeedDivider);
            float3 secondNormal = UnpackNormal(tex2D(_SecondNormal, secondNormalUV));

            float3 normal = mainNormal + secondNormal;
            _MinNormalStrength = clamp(_MinNormalStrength, 0.0, _NormalStrength);
            normal.xy *= lerp(_MinNormalStrength, _NormalStrength, depth);
            
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