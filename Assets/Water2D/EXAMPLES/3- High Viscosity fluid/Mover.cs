using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Mover : MonoBehaviour
{
    public GameObject[] Plates;

    
    Vector3 vel;
    Vector3 pos;
    float speed_Amount = 1.8f;


    void FixedUpdate()
    {
        for (int i = 0; i < Plates.Length; i++)
        {
            vel = Plates[i].GetComponent<Rigidbody2D>().velocity;
            pos = Plates[i].GetComponent<Rigidbody2D>().position;

            if (pos.x <= -10f)
            {
                pos.x = 11.0f;
                Plates[i].transform.Find("trigger").GetComponent<Collider2D>().enabled = true;
            }

            else vel.x = -speed_Amount;


            Plates[i].GetComponent<Rigidbody2D>().velocity = vel;
            Plates[i].GetComponent<Rigidbody2D>().position = pos;
        }

       


    }
}
