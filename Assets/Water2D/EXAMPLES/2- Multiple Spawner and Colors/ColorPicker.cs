namespace Water2D
{
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;

    public class ColorPicker : MonoBehaviour
    {
        public Water2D_Spawner W2D;
        public float Delay;
        public Color[] Colors;
        float delta;


        // Update is called once per frame
        void Update()
        {
            if(delta >= Delay)
            {// tick 

                if (Colors == null)
                    return;

                if (W2D == null)
                    return;

                W2D.FillColor = Colors[Random.Range(0, Colors.Length)];

                delta *= 0;
            }else
            {
                delta += Time.deltaTime;
            }
        }
    }

}