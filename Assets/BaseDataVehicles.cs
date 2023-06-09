using System.Collections;
using System.Collections.Generic;
using Quyet.Attributes;
using UnityEngine;

[CreateAssetMenu(fileName = "Vehicles", menuName = "ScriptableObject/Data")]
public class BaseDataVehicles : ScriptableObject
{
    public List<Vector3> listPathReceivePos;
    public List<Vector3> listPathReceivePos2;
    public List<Vector3> listPathReceiveRotate;
    public List<Vector3> listPathReceiveRotate2;

    [SerializeField, NamedId] string id;
#if UNITY_EDITOR
    [ContextMenu("ResetId")]
    public void ResetId()
    {
        id = Quyet.Attributes.NamedIdAttributeDrawer.ToSnakeCase(name);
    }
#endif

}
