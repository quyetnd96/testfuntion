using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class B : MonoBehaviour
{
    // private void OnTriggerEnter2D(Collider2D other)
    // {
    //     Debug.Log("TriggerB");
    // }
    private void OnCollisionEnter2D(Collision2D other)
    {
        Debug.Log("CollisionB");
    }
}
