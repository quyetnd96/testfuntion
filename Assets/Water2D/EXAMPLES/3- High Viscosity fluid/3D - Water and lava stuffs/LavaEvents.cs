using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LavaEvents : MonoBehaviour
{
    public bool feverMode = false;

    public ParticleSystem[] steamP;

    public PhysicsMaterial2D solidLavaMaterial;

    private void Start()
    {
        for (int i = 1; i < steamP.Length; i++)
        {
            steamP[i] = Instantiate(steamP[0]);
        }
    }
    public void OnCollideLava( GameObject p1, GameObject p2)
    {
        /* p1 = particle 1 in the collision*/
        /* p2= particle 2 in the collision */


        if (p1.tag == p2.tag) // don't trigger if collider itself (lava <=> lava)
        {

            return;

           


        }



        if (p1.tag == "Metaball_liquid" && p2.tag == "Player") // Water & lava collision
        {
            //Lava 
            MetaballParticleClass m = p2.GetComponent<MetaballParticleClass>();
            if (feverMode)
            {
                m.LifeTime = .2f;
            }
            else
            {
               
                //m.LifeTime = 10f;
            }

            m.SetColor(Color.gray * .6f); // Color of final particle 
            m.SetHighDensity(); // set more density
            m.SetFreeze();
            m.removeGlow();
           
           
            // Play Steam particles to simulate water vaporation
            for (int i = 0; i < steamP.Length; i++)
            {
                if (steamP[i].isPlaying)
                    continue;

                steamP[i].transform.position = p1.transform.position;
                steamP[i].Play();
                break;
            }


        }





    }
}
