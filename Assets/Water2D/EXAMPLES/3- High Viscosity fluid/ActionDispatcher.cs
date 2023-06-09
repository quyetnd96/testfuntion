using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ActionDispatcher : MonoBehaviour
{
    public TextMesh TextScore;
    public AudioSource audio;
    public ParticleSystem confetti;

    int score = 0;
    public void Scored(GameObject g1, GameObject g2)
    {
        // Add points
        score++;
        TextScore.text = score.ToString();
        
        // g1 is the active spawner of the event
        g1.GetComponent<Water2D.Water2D_Spawner>().instance.RestoreCheckingFillShape();

        //g2 is the gameobject of collider triggered
        g2.GetComponent<BoxCollider2D>().enabled = false;

        audio.Play();
        confetti.Play();

    }

}
