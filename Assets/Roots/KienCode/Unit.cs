using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Unit : MonoBehaviour
{
    public enum EStoneState
    {
        None,
        IceStone,
        Stone,
    }
    public Sprite[] spriteGem;
    public GameObject effect, effect2;
    public SpriteRenderer sp;
    public Rigidbody2D rid;
    public bool activeChangeStone;
    public GameObject check;
    public Collider2D colliderBegin;
    public SpriteRenderer stoneRenderer;
    public Sprite stoneSprite;
    public Sprite iceStoneSprite;

    public EStoneState StoneState { get; private set; } = EStoneState.None;
    public void DisableSprite()
    {
        if (spriteGem.Length > 0)
        {
            randomDisplayEffect = Random.Range(0, spriteGem.Length);
            sp.sprite = spriteGem[randomDisplayEffect];
        }
    }
    public virtual void ChangeStone(bool isIce = false)
    {
        if (!activeChangeStone)
        {
            // colliderBegin.gameObject.layer = 9;
            this.gameObject.tag = "Tag_Stone";
            activeChangeStone = true;
            StoneState = isIce ? EStoneState.IceStone : EStoneState.Stone;
            StartCoroutine(DelayChangeStone(isIce));
        }
    }
    protected virtual IEnumerator DelayChangeStone(bool isIce = false)
    {
        yield return new WaitForSeconds(0.1f);

        if (check != null)
            check.SetActive(false);
        stoneRenderer.gameObject.SetActive(true);

        ChangeStoneType(isIce);
        sp.gameObject.SetActive(false);
        if (effect != null)
            effect.SetActive(false);
        if (effect2 != null)
            effect2.SetActive(false);
        int randomeffect = Random.Range(0, 100);

    }
    protected virtual void ChangeStoneType(bool isIce = false) { stoneRenderer.sprite = isIce ? iceStoneSprite : stoneSprite; }

    private void OnValidate()
    {
        if (sp == null)
        {
            sp = GetComponent<SpriteRenderer>();
        }

        if (rid == null)
            rid = GetComponent<Rigidbody2D>();
    }
    int randomDisplayEffect;


    public float speedMove;
    public bool isGravity;
    public float timeFly = 0;
    private float ranGas;
    // Start is called before the first frame update
    public void BeginCreateGas()
    {
        ranGas = Random.Range(0.5f, 1);
        if (isGravity)
            rid.gravityScale = 0;
        else
            rid.gravityScale = 0.1f;
        transform.localScale = new Vector3(ranGas, ranGas, ranGas);
        speedMove = Random.Range(1f, 1.5f);
    }
    public virtual void OnUpdate(float deltaTime)
    {

    }
}
