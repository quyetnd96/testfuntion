using System.Collections;
using Unity.Collections;
using Unity.Mathematics;
using Unity.VisualScripting;
using UnityEngine;

public class MoveArcControll : MonoBehaviour
{
    [SerializeField] private GameObject objectSpawnPos;
    [SerializeField] private Transform targetMove;
    [SerializeField] private float speedMoveXStart = 0.5f;
    [SerializeField] private float speedMoveXFinal = 0.1f;
    [SerializeField] private float accelerationX = 0.1f;
    [SerializeField] private bool isMoving = false;
    [SerializeField] private bool isMovingX = false;
    [SerializeField] private bool isMovingY = false;
    [SerializeField] private float timeCount = 0;
    Vector2 startPos;
    [SerializeField] private float SpeedMoveYStart = 0.5f;
    private float _accelerationY;
    private void OnEnable()
    {
        StartMOve();
    }
    private void StartMOve()
    {
        timeCount = 0;
        cachePreviousDistanceX = targetMove.position.x - transform.position.x;
        cachePreviousDistanceY = targetMove.position.y - transform.position.y;
        startPos.x = transform.position.x;
        startPos.y = transform.position.y;
        CallMove();
    }
    private void FixedUpdate()
    {
        if (isMoving) timeCount += Time.deltaTime;
    }
    private void CallMove()
    {
        MoveX();
        MoveY();
        var x = Instantiate(objectSpawnPos, transform.position, quaternion.identity);
        StartCoroutine(WaitCallMoveContinue());
    }
    private void MoveX()
    {
        if (!isMovingX) return;
        if (timeCount > CalculateTimeMoveX())
        {
            Debug.Log("time move x: " + timeCount);
            isMoving = false;
            isMovingX = false;
            return;
        }
        transform.position = new Vector3(speedMoveXStart * timeCount + (float)0.5 * accelerationX * Mathf.Pow(timeCount, 2), transform.position.y, transform.position.z);
        cachePreviousDistanceX = Mathf.Abs(targetMove.position.x - transform.position.x);
    }
    private float CalculateTimeMoveX()
    {
        float x1value = 0;
        float x2value = 0;
        SolveQuadraticEquation(0.5f * accelerationX, speedMoveXStart, startPos.x - targetMove.transform.position.x, out x1value, out x2value);
        float tValue = x1value > 0 ? x1value : x2value;
        return tValue;
    }
    private void MoveY()
    {
        if (!isMovingY) return;
        var timeMoveX = CalculateTimeMoveX();
        _accelerationY = 2 * (targetMove.transform.position.y - startPos.y - SpeedMoveYStart * timeMoveX) / Mathf.Pow(timeMoveX, 2);
        if (timeCount > CalculateTimeMoveX())
        {
            Debug.Log("time move y: " + timeCount);
            isMovingY = false;
            isMoving = false;
            return;
        }
        transform.position = new Vector3(transform.position.x, SpeedMoveYStart * timeCount + (float)0.5 * _accelerationY * Mathf.Pow(timeCount, 2), transform.position.z);
        cachePreviousDistanceY = Mathf.Abs(targetMove.position.y - transform.position.y);
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
