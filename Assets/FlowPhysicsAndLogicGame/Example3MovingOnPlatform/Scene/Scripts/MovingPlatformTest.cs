using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MovingPlatformTest : MonoBehaviour
{
    [SerializeField] private float speed = 1f;
    [SerializeField] private float MinX = -5f;
    [SerializeField] private float MaxX = 5f;
    // Update is called once per frame
    private int direction = 1;
    private void Start()
    {
        direction = 1;
    }
    void Update()
    {
        if (transform.position.x >= MaxX && direction == 1)
        {
            direction = -1;
        }
        if (transform.position.x <= MinX && direction == -1)
        {
            direction = 1;
        }
        this.transform.Translate(new Vector2(1, 0) * direction * speed * Time.deltaTime);
    }
}
