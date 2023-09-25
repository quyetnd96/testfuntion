using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChangeToCam : MonoBehaviour
{
    [SerializeField] private float ScaleChangeCam=1.75f;
    public void ChangeRatioObjectFollowCam(GameObject objectChangeSizeAndPos,Camera camBefore)
    {
        var cachePos=camBefore.WorldToScreenPoint(objectChangeSizeAndPos.transform.position);
        var newPos=GetComponent<Camera>().ScreenToWorldPoint(cachePos);
        objectChangeSizeAndPos.transform.position=newPos;
        var scaleBefore=objectChangeSizeAndPos.transform.localScale;
        objectChangeSizeAndPos.transform.localScale=new Vector3(
            scaleBefore.x/ScaleChangeCam,
            scaleBefore.y/ScaleChangeCam,
            scaleBefore.z/ScaleChangeCam);
    }
}
