using System.Collections;
using DG.Tweening;
using UnityEngine;

public class MoveArcControll : MonoBehaviour
{
    [SerializeField] private Transform targetMove;
    [SerializeField] private float SpeedMoveXStart = 0.5f;
    [SerializeField] private float SpeedMoveXFinal = 0.1f;
    [SerializeField] private float SpeedMinX = 0.1f;
    [SerializeField] private float SpeedMoveX = 0.1f;
    [SerializeField] private Vector3 vectorDirectionX;
    [SerializeField] private float accelerationX = 0.1f;
    [SerializeField] private bool isMoving = false;
    [SerializeField] private bool isMovingX = false;
    [SerializeField] private bool isMovingY = false;
    [SerializeField] private float timeCount = 0;
    float startXPos;


    [SerializeField] private float SpeedMoveY = 0.1f;
    [SerializeField] private Vector3 vectorDirectionY;
    float DistanceMoveY = 0;
    private void OnEnable()
    {
        StartMOve();
    }
    private void StartMOve()
    {
        timeCount = 0;
        cachePreviousDistanceX = targetMove.position.x - transform.position.x;
        cachePreviousDistanceY = targetMove.position.y - transform.position.y;
        vectorDirectionX = new Vector3(targetMove.position.x - transform.position.x, 0, 0).normalized;
        vectorDirectionY = new Vector3(0, targetMove.position.y - transform.position.y, 0).normalized;
        isMoving = true;
        isMovingX = true;
        isMovingY = true;
        startXPos = transform.position.x;
        DistanceMoveY = targetMove.transform.position.y - transform.position.y;
        CallMove();
    }
    private void FixedUpdate()
    {
        if (isMovingX) timeCount += Time.deltaTime;
    }
    private void CallMove()
    {
        if (cachePreviousDistanceX < vectorDirectionX.magnitude * SpeedMoveX)
        {
            transform.position = new Vector3(targetMove.position.x, transform.position.y, transform.position.z);
            isMovingX = false;
        }
        else
        {
            MoveX();
        }
        // SpeedMoveY = DistanceMoveY / CalculateTimeMoveX();
        SpeedMoveY = DistanceMoveY / 0.6f;
        if (cachePreviousDistanceY < vectorDirectionY.magnitude * SpeedMoveY)
        {
            transform.position = new Vector3(transform.position.x, targetMove.position.y, transform.position.z);
            isMovingY = false;
        }
        else
        {
            MoveY();
        }
        StartCoroutine(WaitCallMoveContinue());
    }
    private void MoveX()
    {
        if (!isMovingX) return;
        if (Mathf.Abs(cachePreviousDistanceX) < 0.1f) return;
        float currentSpeed = SpeedMoveXStart - accelerationX * timeCount;
        if (currentSpeed < SpeedMoveXFinal) currentSpeed = SpeedMoveXFinal;
        transform.Translate(vectorDirectionX * currentSpeed);
        cachePreviousDistanceX = targetMove.position.x - transform.position.x;
    }
    private float CalculateTimeMoveX()
    {
        float x1value = 0;
        float x2value = 0;
        SolveQuadraticEquation(-0.5f * accelerationX, SpeedMoveXStart, Mathf.Abs(startXPos - targetMove.transform.position.x), out x1value, out x2value);
        float tValue = x1value > 0 ? x1value : x2value;
        Debug.Log(tValue);
        return tValue;
    }
    private void MoveY()
    {
        if (!isMovingY) return;
        if (Mathf.Abs(cachePreviousDistanceY) < 0.1f) return;
        SpeedMoveY = DistanceMoveY / CalculateTimeMoveX();
        transform.Translate(vectorDirectionY * SpeedMoveY);
        cachePreviousDistanceY = targetMove.position.y - transform.position.y;
    }
    [SerializeField] private float cachePreviousDistanceX = 0;
    [SerializeField] private float cachePreviousDistanceY = 0;

    IEnumerator WaitCallMoveContinue()
    {
        yield return new WaitForSeconds(0.02f);
        CallMove();
    }

    public static bool SolveQuadraticEquation(float a, float b, float c, out float x1, out float x2)
    {
        float discriminant = b * b - 4 * a * c;
        x1 = 0;
        x2 = 0;

        if (discriminant < 0)
        {
            return false;
        }
        else if (discriminant == 0)
        {
            x1 = x2 = -b / (2 * a);
            return true;
        }
        else
        {
            x1 = (-b + Mathf.Sqrt(discriminant)) / (2 * a);
            x2 = (-b - Mathf.Sqrt(discriminant)) / (2 * a);

            return true;
        }
    }
}
