using UnityEngine;

public class A : MonoBehaviour
{
    private void OnCollisionEnter2D(Collision2D other)
    {
        Debug.Log("CollisionA");
    }
}
