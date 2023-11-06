using UnityEngine;

public class B : MonoBehaviour
{
    private void OnCollisionEnter2D(Collision2D other)
    {
        Debug.Log("CollisionB");
    }
}
