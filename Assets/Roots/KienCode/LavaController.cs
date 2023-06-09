using System.Collections;
using System.Linq;
using UnityEngine;

public class LavaController : Unit
{
    private bool _flagVibrate;
    [SerializeField] private LayerMask layer;

    // private void OnTriggerEnter2D(Collider2D collision)
    // {
    //     if (activeChangeStone) return;
    //     if (!activeChangeStone && collision.CompareTag("Tag_Stone") && collision.gameObject.name != "BigStone" && collision.gameObject.name != "BigStoneBomb")
    //     {
    //         if (collision.CompareTag("Tag_Stone"))
    //         {
    //         }
    //         ChangeStone();
    //         if (collision.GetComponentInParent<SpawnObject>() != null &&
    //         collision.gameObject.GetComponentInParent<SpawnObject>().gameObject != this.GetComponentInParent<SpawnObject>().gameObject)
    //         {
    //             this.GetComponentInParent<SpawnObject>().OtherSpawn = collision.gameObject.GetComponentInParent<SpawnObject>().gameObject;
    //             collision.gameObject.GetComponentInParent<SpawnObject>().OtherSpawn = this.GetComponentInParent<SpawnObject>().gameObject;
    //         }
    //     }
    // }
    private void OnCollisionEnter2D(Collision2D other)
    {
        if (activeChangeStone) return;
        ExtendCollision();
        if (!activeChangeStone && other.gameObject.CompareTag("Tag_Stone"))
        {
            // ChangeStone();
            float randomTime = Random.Range(0.05f, 0.20f);
            StartCoroutine(StepWaitBeforeChangeStone(randomTime));
        }
    }
    IEnumerator StepWaitBeforeChangeStone(float timeWait)
    {
        yield return new WaitForSeconds(timeWait);
        ChangeStone();
    }
    private void ExtendCollision()
    {
        var cols = Physics2D.OverlapCircleAll(this.transform.position, 0.05f + 0.025f, layer);
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
                ChangeStone();
            }
        }
    }
}