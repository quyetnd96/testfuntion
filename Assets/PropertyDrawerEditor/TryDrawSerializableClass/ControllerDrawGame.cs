
using UnityEditor;
using UnityEngine;

public class ControllerDrawGame : MonoBehaviour
{
    [Test(false)]
    public TestSeriSe testSeriSe;
    [ContextMenu("Test")]
    public void Changevalue()
    {
        testSeriSe.a = 100;
        EditorUtility.SetDirty(this);
    }
}
