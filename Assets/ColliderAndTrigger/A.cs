using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class A : MonoBehaviour
{
    // private void OnTriggerEnter2D(Collider2D other)
    // {
    //     Debug.Log("TriggerA");
    // }
    private void OnCollisionEnter2D(Collision2D other)
    {
        Debug.Log("CollisionA");
    }
}
