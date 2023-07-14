using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class USBReplacementController : MonoBehaviour
{
    // replacement shader
    public Shader m_replacementShader;

    private void OnEnable() 
    {
        if(m_replacementShader != null)
        {
            // the camera will replace all the shader in the scene with the replacement shader
            // the "RenderType" configuration must match
            GetComponent<Camera>().SetReplacementShader(m_replacementShader, "RenderType");
        }
    }

    void OnDisable()
    {
        GetComponent<Camera>().ResetReplacementShader();
    }
}
