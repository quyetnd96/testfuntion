using UnityEngine;
using System;

[Serializable]
public class TestSeriSe
{
    public int a;
    public string b;
    public bool isGetSetLevel;
}
public class TestSeri : MonoBehaviour
{
    public TestSeriSe field1;
    public bool isGetSetLevel;
}
