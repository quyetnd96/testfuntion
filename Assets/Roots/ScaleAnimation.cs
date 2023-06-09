using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class ScaleAnimation : MonoBehaviour
{
    [SerializeField] private Ease ease = Ease.Linear;
    [SerializeField] private float duration = 1f;
    [SerializeField] private Vector3 endValue = new Vector3(1.1f, 1.1f, 1.1f);
    [SerializeField] private bool isLoop = true;
    [SerializeField] private bool loopOnAwake = true;
    private Vector3 startValue;

    public void SetEndValue(Vector3 endValue)
    {
        this.endValue = endValue;
    }

    public void SetDuration(float duration)
    {
        this.duration = duration;
    }

    private void Awake()
    {
        startValue = transform.localScale;
    }

    private void Start()
    {
        if (loopOnAwake)
        {
            StartScale();
        }
    }

    public void StartScale()
    {
        if (isLoop)
        {
            transform.DOScale(endValue, duration).SetEase(ease).OnComplete(() => ResetScale());
        }
        else
        {
            transform.DOScale(endValue, duration).SetEase(ease);
        }
    }

    public void ResetScale()
    {
        transform.DOScale(startValue, duration).SetEase(ease).OnComplete(() => StartScale());
    }

    private void OnDestroy()
    {
        transform.DOKill();
    }
}
