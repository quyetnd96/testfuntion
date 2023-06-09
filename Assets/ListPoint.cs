using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[ExecuteInEditMode]
public class ListPoint : MonoBehaviour
{
    public BaseDataVehicles baseData;
    [SerializeField] private List<Transform> listPathReceiveTransform;

#if UNITY_EDITOR
    [ContextMenu("ConfirmPath")]
    public void ConfirmPath()
    {
        baseData.listPathReceivePos.Clear();
        baseData.listPathReceiveRotate.Clear();

        foreach (var x in listPathReceiveTransform)
        {
            baseData.listPathReceivePos.Add(x.position);

            baseData.listPathReceiveRotate.Add(new Vector3(0, 0, x.localRotation.eulerAngles.z));
        }
        EditorUtility.SetDirty(baseData);
        EditorUtility.SetDirty(this);
    }
    private void OnDrawGizmos()
    {
        Gizmos.color = Color.green;
        for (int i = 1; i < baseData.listPathReceivePos.Count; i++)
        {
            Gizmos.DrawLine(baseData.listPathReceivePos[i - 1], baseData.listPathReceivePos[i]);
        }
    }
#endif
}
