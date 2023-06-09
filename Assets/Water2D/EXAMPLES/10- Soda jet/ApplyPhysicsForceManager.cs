using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ApplyPhysicsForceManager : MonoBehaviour
{

    public Rigidbody2D rb;
    public Water2D.Water2D_Spawner jet1;
    public Water2D.Water2D_Spawner jet2;
    public AudioSource[] fx;

    Vector3 initPOs;
    bool canPlay = false;

    public void ApplyForceToBody(GameObject g1, GameObject g2)
    {
        rb.AddForce(g2.GetComponent<Rigidbody2D>().velocity * -.8f);
    }

    public void Start()
    {
        for (int i = 1; i < fx.Length; i++)
        {
            fx[i] = Instantiate(fx[0]);
        }

        StartCoroutine(PlaySoundLoopEnum());

        initPOs = transform.position;
    }

    public void Update()
    {
        if (Input.GetKey(KeyCode.LeftArrow))
        {
            
            rb.AddTorque(15f);
        }
        

        if (Input.GetKey(KeyCode.RightArrow))
        {
            
            rb.AddTorque(-15f);
        }

        if (Input.GetKey(KeyCode.UpArrow))
        {

            jet1.Spawn();
            jet2.Spawn();
            canPlay = true;
           
        }
       
        else
        {

            jet2.StopSpawning();
            jet1.StopSpawning();
        }

        if (Input.GetKey(KeyCode.R))
        {
            transform.position = initPOs;
            transform.localEulerAngles = Vector3.zero;
            rb.velocity = Vector2.zero;
        }
    }

    IEnumerator PlaySoundLoopEnum() {

        while (true)
        {
            yield return null;

            if (canPlay)
            {
                yield return new WaitForSeconds(0.05f);
                for (int i = 0; i < fx.Length; i++)
                {
                    if (fx[i].isPlaying)
                        continue;

                    fx[i].pitch = Mathf.Max(.5f,  rb.velocity.sqrMagnitude*.002f);  
                    fx[i].Play();
                    canPlay = false;
                    break;
                }

            }

           
        }

        
    }

}
