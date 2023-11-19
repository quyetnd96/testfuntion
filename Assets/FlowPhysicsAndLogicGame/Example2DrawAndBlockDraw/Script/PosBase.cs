using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PosBase : MonoBehaviour
{
    private int _currentLineSortingOrder = 0;
    [SerializeField] private LineRed redLineDrawPrefab;
    private LineDrawController _lineCurrent;
    public LineDrawController LineCurrent => _lineCurrent;
    private bool _isFingerDown;
    public bool IsDrawing;
    [SerializeField] private LayerMask layerMask;
    [SerializeField] Obstacle obstacle;

    public Camera Camera;
    private void OnMouseDown()
    {
        _isFingerDown = true;
        Collider2D col = Physics2D.OverlapPoint(Camera.ScreenToWorldPoint(Input.mousePosition), layerMask);
        if (col != null && col.CompareTag("Red"))
        {
            SpawnLine(col, redLineDrawPrefab);
        }
    }
    private void SpawnLine(Collider2D col, LineDrawController lineDraw)
    {
        if (_lineCurrent != null) return;
        col.TryGetComponent<StartPos>(out StartPos startPos);
        var _line = Instantiate(lineDraw, transform);
        _line.SetSortingOrder(_currentLineSortingOrder);
        _lineCurrent = _line;
        _lineCurrent.Create(Camera.ScreenToWorldPoint(Input.mousePosition), startPos);
        _currentLineSortingOrder++;
        obstacle.lineCurrent = _lineCurrent;
    }
    private void OnMouseDrag()
    {
        if (_isFingerDown)
        {
            Collider2D col = Physics2D.OverlapPoint(Camera.ScreenToWorldPoint(Input.mousePosition), layerMask);
            if (_lineCurrent != null)
            {
                IsDrawing = true;

                _lineCurrent.UpdateListVector(Camera.ScreenToWorldPoint(Input.mousePosition));
            }
        }
    }
    private void OnMouseUp()
    {
        if (_lineCurrent != null) Destroy(_lineCurrent.gameObject);
    }

}
