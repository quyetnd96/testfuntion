using System.Collections.Generic;
using UnityEngine;


public class LineDrawController : MonoBehaviour
{
    [SerializeField] private LineRenderer line;
    [SerializeField] private List<Vector3> listPos;
    [SerializeField] private List<Vector3> listPosReal;
    public bool _isFixed = false;
    private StartPos _startPosCur;
    private Vector3 _cachePointUpdate;
    private bool _isDirection;
    public void Create(Vector3 pointStart, StartPos startPos = null)
    {
        Vector3 pointCreate = Vector3.zero;
        if (startPos != null)
        {
            _isDirection = true;
            _startPosCur = startPos;
            pointCreate = new Vector3(startPos.transform.position.x, startPos.transform.position.y, 5.5f);
            listPosReal.Add(pointCreate);
        }
        listPos.Add(pointCreate);
        line.SetPosition(0, pointCreate);
        Vector3 realPoint = new Vector3(pointStart.x, pointStart.y, 5.5f);
        listPos.Add(realPoint);
        listPosReal.Add(realPoint);
        line.SetPosition(1, realPoint);
    }
    public void UpdateListVector(Vector3 newPoint)
    {
        if (_isFixed) return;
        Vector3 realPoint = new Vector3(newPoint.x, newPoint.y, 5.5f);
        _cachePointUpdate = realPoint;
        if (CanNotDrawPoint(realPoint)) return;
        var storage = listPos.Count - 1;
        if (Vector2.Distance(listPos[storage], realPoint) > 0.2f)
        {
            if (listPos.Count > 3)
            {
                Vector2 lastestVector = listPos[storage] - listPos[storage - 1];
                Vector2 nearLastTestVector = listPos[storage - 2] - listPos[storage - 1];
                float angle = Vector3.Angle(lastestVector, nearLastTestVector);
                if (angle < 20 || angle > 160)
                {
                    // add 4 point to avoid sharp of line
                    listPosReal.Add(realPoint);

                    listPos.Add(realPoint);
                    line.positionCount++;
                    line.SetPosition(listPos.Count - 1, realPoint);

                    listPos.Add(realPoint);
                    line.positionCount++;
                    line.SetPosition(listPos.Count - 1, realPoint);

                    listPos.Add(realPoint);
                    line.positionCount++;
                    line.SetPosition(listPos.Count - 1, realPoint);

                    listPos.Add(realPoint);
                    line.positionCount++;
                    line.SetPosition(listPos.Count - 1, realPoint);
                }
                else
                {
                    listPos.Add(realPoint);
                    line.positionCount++;
                    line.SetPosition(listPos.Count - 1, realPoint);
                    listPosReal.Add(realPoint);
                }
            }
            else
            {
                listPos.Add(realPoint);
                line.positionCount++;
                line.SetPosition(listPos.Count - 1, realPoint);
                listPosReal.Add(realPoint);
            }
        }
    }
    private bool CanNotDrawPoint(Vector3 newPoint)
    {
        Vector3 vectorScaleBySpeed = newPoint - listPos[listPos.Count - 1];
        // Debug.Log(vectorScaleBySpeed.magnitude + "draw");
        // RaycastHit2D hit = Physics2D.Raycast(listPos[listPos.Count - 1], newPoint - listPos[listPos.Count - 1], vectorScaleBySpeed.magnitude + 0.009f);
        RaycastHit2D[] raycastHit2Ds = Physics2D.RaycastAll(listPos[listPos.Count - 1], newPoint - listPos[listPos.Count - 1], vectorScaleBySpeed.magnitude + 0.009f);
        foreach (var x in raycastHit2Ds)
        {
            if (x.collider != null)
            {
                if (x.collider.CompareTag("Obstacle"))
                {

                    return true;
                }
            }
        }
        return false;
    }
    // private void OnDrawGizmos()
    // {
    // Vector3 newPoint = new Vector3(LevelController.Instance.currentLevel.PublicCameraLevel.ScreenToWorldPoint(Input.mousePosition).x, LevelController.Instance.currentLevel.PublicCameraLevel.ScreenToWorldPoint(Input.mousePosition).y, 6);
    // Vector3 vectorScaleBySpeed = newPoint - _listPos[_listPos.Count - 1];
    // Vector3 cacheVector = (newPoint) - _listPos[_listPos.Count - 1];
    // // Debug.Log(cacheVector.magnitude + "gizmos");
    // Gizmos.color = Color.green;
    // Gizmos.DrawLine(_listPos[_listPos.Count - 1], newPoint + vectorScaleBySpeed.normalized * 0.009f);
    // }

    public void DestroyLine()
    {
        Destroy(this.gameObject);
    }
    public void SetSortingOrder(int indexSortingOrder)
    {
        line.sortingOrder = indexSortingOrder;
    }
}
