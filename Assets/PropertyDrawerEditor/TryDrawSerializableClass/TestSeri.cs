using UnityEngine;
using System;
using System.Collections.Generic;

[Serializable]
public class TestSeriSe
{
    public int a;
    public string b;
    public bool isGetSetLevel;
    public List<GameObject> testList;
}
public class RangeAttribute : PropertyAttribute
{
    public float min;
    public float max;

    public RangeAttribute(float min, float max)
    {
        this.min = min;
        this.max = max;
    }
}
public class TestAttribute : PropertyAttribute
{
    public bool active;
    public TestAttribute(bool active)
    {
        this.active = active;
    }
}

