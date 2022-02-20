using UnityEngine;

[ExecuteInEditMode]
public class Water : MonoBehaviour
{
    [SerializeField] Camera mainCamera;
    [SerializeField] Shader shader;
    [SerializeField] Material material;
    [Space]
    [SerializeField, Range(1.0f, 5.0f)] float depthLevel = 1.0f;
    [SerializeField, Range(0.0f, 1.0f)] float degradationStrength = 0.5f;

    void Update()
    {
        Debug.Log("resolution: " + Screen.width + ", " + Screen.height);

        mainCamera.depthTextureMode = DepthTextureMode.Depth;

        material.SetFloat("_DepthLevel", depthLevel);
        material.SetFloat("_DegradationStrength", degradationStrength);

        material.SetInt("_ScreenWidth", Screen.width);
        material.SetInt("_ScreenHeight", Screen.height);
    }
}