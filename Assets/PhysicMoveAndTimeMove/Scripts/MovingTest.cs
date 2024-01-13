using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using UnityEngine;

public class MovingTest : MonoBehaviour
{
    public float distance;
    public double time;
    private DateTime startDate;
    private void Start()
    {
        startDate = DateTime.Now;
    }
    private void Update()
    {
        time = (DateTime.Now - startDate).TotalSeconds;
        transform.Translate(Vector3.right * Time.deltaTime);
        distance = (this.transform.position - Vector3.zero).magnitude;
    }
}
