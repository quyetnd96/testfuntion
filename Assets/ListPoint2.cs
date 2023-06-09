using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[ExecuteInEditMode]
public class ListPoint2 : MonoBehaviour
{
    public BaseDataVehicles baseData;
    [SerializeField] private List<Transform> listPathReceiveTransform2;

#if UNITY_EDITOR
    [ContextMenu("ConfirmPath")]
    public void ConfirmPath()
    {
        baseData.listPathReceivePos2.Clear();
        baseData.listPathReceiveRotate2.Clear();
        foreach (var x in listPathReceiveTransform2)
        {
            baseData.listPathReceivePos2.Add(x.position);

            baseData.listPathReceiveRotate2.Add(new Vector3(0, 0, x.localRotation.eulerAngles.z));
        }
        EditorUtility.SetDirty(baseData);
        EditorUtility.SetDirty(this);
    }
    private void OnDrawGizmos()
    {
        Gizmos.color = Color.green;
        for (int i = 1; i < baseData.listPathReceivePos2.Count; i++)
        {
            Gizmos.DrawLine(baseData.listPathReceivePos2[i - 1], baseData.listPathReceivePos2[i]);
        }
    }
#endif
}

