using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LavaColorPicker : MonoBehaviour
{
    public Color[] Colors;
    public Water2D.Water2D_Spawner Spawner;

    private IEnumerator Start()
    {
        while (true)
        {
            yield return new WaitForSeconds(.1f);
            Spawner.FillColor = getColor();
        }
       

    }

    Color getColor() {
        return Colors[Random.Range(0, Colors.Length)];
    
    }
}
