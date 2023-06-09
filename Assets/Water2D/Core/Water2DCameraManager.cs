namespace Water2D { 
    using System.Collections;
    using System.Collections.Generic;
    using UnityEngine;

  


    public class Water2DCameraManager : MonoBehaviour
    {

        public static Bounds OrthographicBounds(Camera camera)
        {
            float screenAspect = (float)Screen.width / (float)Screen.height;
            float cameraHeight = camera.orthographicSize * 2;
            Vector3 size = new Vector3(cameraHeight * screenAspect, cameraHeight, 0);
            Bounds bounds = new Bounds(
                camera.transform.position, size);
            return bounds;
        }

        [TextArea]
        public string a;

        public float Size = 5f;




        void Start()
        {

        }

        // Update is called once per frame
        void Update()
        {

        }
    }
}
