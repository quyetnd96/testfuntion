using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DeleteParticles : MonoBehaviour
{


    void OnCollisionEnter2D(Collision2D col) {
       
            MetaballParticleClass m1 = col.gameObject.GetComponent<MetaballParticleClass>();
            m1.Active = false;

    }
}
