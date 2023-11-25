using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMoving : MonoBehaviour
{
    // Update is called once per frame
    [SerializeField] private float speed = 1f;
    [SerializeField] private bool isAutoMoving = true;
    private Vector3 startPos;
    private Vector3 cacheAndFixDistance;
    private bool isFixMoveByPlatform = false;
    private MovingPlatformTest objectFix;
    private void Start()
    {
        isAutoMoving = true;
        startPos = transform.position;
    }
    void Update()
    {

        if (isFixMoveByPlatform)
        {
            if (isAutoMoving)
            {
                this.transform.position = objectFix.transform.position - cacheAndFixDistance;
                this.transform.Translate(Vector2.left * speed * Time.deltaTime);
                cacheAndFixDistance = objectFix.transform.position - transform.position;
            }
            else
            {
                this.transform.position = objectFix.transform.position - cacheAndFixDistance;
            }
        }
        else
        {
            if (isAutoMoving)
            {
                this.transform.Translate(Vector2.left * speed * Time.deltaTime);
            }
        }
    }
    private void OnCollisionEnter2D(Collision2D other)
    {
        other.gameObject.TryGetComponent<MovingPlatformTest>(out MovingPlatformTest movingTest);
        if (movingTest != null)
        {
            objectFix = movingTest;
            cacheAndFixDistance = movingTest.gameObject.transform.position - this.transform.position;
            isAutoMoving = false;
            isFixMoveByPlatform = true;
        }
    }
    private void OnCollisionExit2D(Collision2D other)
    {
        other.gameObject.TryGetComponent<MovingPlatformTest>(out MovingPlatformTest movingTest);
        if (movingTest != null)
        {
            isAutoMoving = true;
            isFixMoveByPlatform = false;
        }
    }
    public void ResetPlayer()
    {
        transform.position = startPos;
        isAutoMoving = true;
        isFixMoveByPlatform = false;
    }
}
