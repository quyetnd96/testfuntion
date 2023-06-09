using System.Collections;
using Unity.VisualScripting;
using UnityEngine;
public class WaterCollison : Unit
{
    private bool _flagVibrate;
    [SerializeField] private LayerMask layer;

    // private void OnTriggerEnter2D(Collider2D collision)
    // {
    //     if (collision.CompareTag("Trap_Lava"))
    //     {
    //         var current = collision.GetComponent<ChildUnit>();
    //         current.myUnit.ChangeStone();
    //         ChangeStone();
    //         if (collision.GetComponentInParent<SpawnObject>() != null &&
    //         collision.gameObject.GetComponentInParent<SpawnObject>().gameObject != this.GetComponentInParent<SpawnObject>().gameObject)
    //         {
    //             this.GetComponentInParent<SpawnObject>().OtherSpawn = collision.gameObject.GetComponentInParent<SpawnObject>().gameObject;
    //             collision.gameObject.GetComponentInParent<SpawnObject>().OtherSpawn = this.GetComponentInParent<SpawnObject>().gameObject;
    //         }
    //     }
    //     else if (collision.CompareTag("Tag_Stone") && collision.gameObject.name != "BigStone" && collision.gameObject.name != "BigStoneBomb")
    //     {
    //         var b = false;
    //         var unit = collision.GetComponentInParent<Unit>();
    //         if (unit && unit.StoneState == EStoneState.IceStone)
    //         {
    //             b = true;
    //         }
    //         ChangeStone(b);
    //         if (collision.GetComponentInParent<SpawnObject>() != null &&
    //         collision.gameObject.GetComponentInParent<SpawnObject>().gameObject != this.GetComponentInParent<SpawnObject>().gameObject)
    //         {
    //             this.GetComponentInParent<SpawnObject>().OtherSpawn = collision.gameObject.GetComponentInParent<SpawnObject>().gameObject;
    //             collision.gameObject.GetComponentInParent<SpawnObject>().OtherSpawn = this.GetComponentInParent<SpawnObject>().gameObject;

    //         }

    //     }
    // }
    IEnumerator StepWaitBeforeChangeStone(Unit unit, float timeWait)
    {
        yield return new WaitForSeconds(timeWait);
        unit.ChangeStone();
    }
    private void OnCollisionEnter2D(Collision2D other)
    {
        if (activeChangeStone) return;
        ExtendCollision();
        if (other.gameObject.CompareTag("Trap_Lava"))
        {
            var current = other.gameObject.GetComponent<Unit>();
            float randomTime = Random.Range(0.05f, 0.20f);
            StartCoroutine(StepWaitBeforeChangeStone(current, randomTime));
            StartCoroutine(StepWaitBeforeChangeStone(this, randomTime));
            // current.ChangeStone();
            // ChangeStone();


        }
        else if (other.gameObject.CompareTag("Tag_Stone"))
        {


            float randomTime = Random.Range(0.05f, 0.20f);
            StartCoroutine(StepWaitBeforeChangeStone(this, randomTime));
            // ChangeStone();


        }
    }

    private void ExtendCollision()
    {
        var cols = Physics2D.OverlapCircleAll(this.transform.position, 0.05f + 0.03f, layer);
        if (cols.Length > 0)
        {


            bool isChange = false;

            foreach (var x in cols)
            {
                if (x.CompareTag("Tag_Stone"))
                {
                    isChange = true;
                }
            }
            if (isChange)
            {
                if (activeChangeStone) return;

                ChangeStone();

            }
        }
    }

}