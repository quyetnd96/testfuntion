using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DecoratorManager : MonoBehaviour
{
    public Water2D.Water2D_Spawner Spawner;
    public Color[] _colors;
    void Update()
    {
        if (Input.GetMouseButton(0))
        {
            Spawner.Spawn();
        }
        else
        {
            Spawner.StopSpawning();
           
        }

        if (Input.GetMouseButtonUp(0))
            Spawner.FillColor = _colors[Random.Range(0, _colors.Length)];// new Color(Mathf.Max(Random.value, .5f), Mathf.Max(Random.value, .5f), Mathf.Max(Random.value, .5f), .4f);
        
    }
}
