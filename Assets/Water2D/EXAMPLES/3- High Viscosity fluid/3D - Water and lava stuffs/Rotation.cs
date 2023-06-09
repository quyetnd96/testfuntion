using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotation : MonoBehaviour
{
    public float amount = 1f;

    IEnumerator Start()
    {
        Vector3 euler = transform.localEulerAngles;
        while (true)
        {
           

            if (euler.z > 137 || euler.z < 110)
            {
                amount *= -1;  
            }

            euler.z += amount;

            transform.localEulerAngles = euler;
            yield return null;
        }

       
    }


  
}
