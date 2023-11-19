using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveBullet : MonoBehaviour
{
    [SerializeField] private float Speed;
    private bool isMove = false;
    public bool IsMove { set => isMove = value; }
    private Vector3 startTransformPos;
    public bool isMoveRigid = false;
    [SerializeField] private Rigidbody2D rigid2D;
    [SerializeField] private Rigidbody rigid3D;
    // Update is called once per frame
    private Vector3 cachePreviousPos;
    private void Start()
    {
        startTransformPos = this.transform.position;
        cachePreviousPos = startTransformPos;
    }
    void Update()
    {
        if (isMove)
        {
            if (isMoveRigid)
            {
                Vector3 newPos = Vector3.zero;
                if ((this.transform.position.x - cachePreviousPos.x) < 0.1f)
                {
                    newPos = this.transform.position + new Vector3(1, 0, 0) * Speed * Time.deltaTime;
                    cachePreviousPos = newPos;
                }
                else
                {
                    newPos = cachePreviousPos;
                }
                if (rigid2D != null) rigid2D.MovePosition(newPos);
                if (rigid3D != null) rigid3D.MovePosition(newPos);
            }
            else
            {
                this.transform.Translate(new Vector3(1, 0, 0) * Speed * Time.deltaTime);
            }
        }
    }
    public void Reset()
    {
        isMove = false;
        this.transform.position = startTransformPos;
    }
    private void OnCollisionEnter2D(Collision2D other)
    {
        isMove = false;
        Debug.Log("here 2D");
    }
    private void OnCollisionEnter(Collision other)
    {
        isMove = false;
        Debug.Log("here 3D");
    }
}
