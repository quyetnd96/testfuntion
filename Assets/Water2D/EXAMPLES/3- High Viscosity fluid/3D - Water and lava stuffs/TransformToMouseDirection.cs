using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TransformToMouseDirection : MonoBehaviour
{
    Water2D.Water2D_Spawner w2;
    void Start()
    {
        w2 = GetComponent<Water2D.Water2D_Spawner>();
        w2.StopSpawning();
    }

    Vector3 dir;
    void Update()
    {
        dir = transform.position - Camera.main.ScreenToWorldPoint(Input.mousePosition);
        dir.z *= 0;
        transform.up = -dir;

        w2.Speed = dir.magnitude * 3f;
        w2.Speed = Mathf.Clamp(w2.Speed, 7f, 25f);

        if (w2 != null) {

            if (Input.GetMouseButton(0))
            {
                if (!w2.IsSpawning)
                {
                    w2.Spawn();
                }
            }
            else
            {
                if (w2.IsSpawning)
                {
                    w2.StopSpawning();
                }
            }

           
        }
            
    }
}
