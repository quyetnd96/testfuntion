using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class basePeople : MonoBehaviour
{
    protected float something;
    public abstract void Move();
    public virtual void test()
    {
        Debug.Log("base people test");
    }


}
