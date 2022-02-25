using UnityEngine;

[ExecuteInEditMode]
public class Water : MonoBehaviour
{
    [Header("Water Colors")]
    [SerializeField] Color shallowWaterColor = Color.cyan;
    [SerializeField] Color deepWaterColor = Color.blue;

    [Header("Water Depth")]
    [SerializeField] float depthLevel = 1.0f;
    [SerializeField, Range(0.0f, 2.0f)] float gradientStrength = 1.0f;

    [Header("Normal Maps")]
    [SerializeField] Texture2D mainNormal = null;
    [SerializeField] float mainNormalSpeed = 1.0f;
    [Space]
    [SerializeField] Texture2D secondNormal = null;
    [SerializeField] float secondNormalSpeed = -0.5f;
    [Space]
    [SerializeField] float normalStrength = 1.0f;

    [Header("Vertex Displacement")]
    [SerializeField] Texture2D noise = null;
    [SerializeField] float displacementStrength = 1.0f;

    [Header("Rendering")]
    [SerializeField] Camera mainCamera = null;
    [SerializeField] Material material = null;

    void Update()
    {
        mainCamera.depthTextureMode = DepthTextureMode.Depth;

        material.SetColor("_ShallowWaterColor", shallowWaterColor);
        material.SetColor("_DeepWaterColor", deepWaterColor);

        material.SetFloat("_Depth", depthLevel);
        material.SetFloat("_Strength", gradientStrength);

        material.SetTexture("_MainNormal", mainNormal);
        material.SetFloat("_MainNormalSpeed", mainNormalSpeed);
        material.SetTexture("_SecondNormal", secondNormal);
        material.SetFloat("_SecondNormalSpeed", secondNormalSpeed);
        material.SetFloat("_NormalStrength", normalStrength);

        material.SetTexture("_NoiseTexture", noise);
        material.SetFloat("_DisplacementStrength", displacementStrength);

        material.SetInt("_ScreenWidth", Screen.width);
        material.SetInt("_ScreenHeight", Screen.height);
        material.SetFloat("_FarPlane", mainCamera.farClipPlane);
    }
}