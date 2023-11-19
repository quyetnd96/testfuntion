using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Obstacle : MonoBehaviour
{
    public Camera Camera;
    public LineDrawController lineCurrent;
    [SerializeField] private LayerMask layerMask;
    private void OnMouseEnter()
    {
        if (lineCurrent != null) lineCurrent._isFixed = true;
    }
}
