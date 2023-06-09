using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SpawnObject : MonoBehaviour
{
    public List<Unit> gGems;
    private int _randomDisplayEffect;
    [SerializeField] private GameObject otherSpawn;
    public GameObject OtherSpawn
    {
        get { return otherSpawn; }
        set
        {
            if (otherSpawn == null)
            {
                otherSpawn = value;
            }
        }
    }
}