using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player : basePeople, IHealController
{
    private void Update()
    {

    }
    private void Start()
    {
        test();
        MinusHeal();
    }
    public void MinusHeal()
    {
        Debug.Log("here call at Player");
    }

    public override void Move()
    {
        throw new System.NotImplementedException();
    }
    public override void test()
    {
        Debug.Log("Player test");
        base.test();
    }
}
