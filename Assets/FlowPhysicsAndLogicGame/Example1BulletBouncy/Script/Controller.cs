using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Controller : MonoBehaviour
{
    [SerializeField] private MoveBullet bulletmove;
    public void Shoot()
    {
        bulletmove.IsMove = true;
    }
    public void Reset()
    {
        bulletmove.Reset();
    }
}
