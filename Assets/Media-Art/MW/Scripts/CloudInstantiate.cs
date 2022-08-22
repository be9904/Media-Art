using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CloudInstantiate : MonoBehaviour
{
    public static CloudInstantiate instance;
    public GameObject CloudPrefab;
    private void Awake()
    {
        instance = this;
    }
    public void WhenCut(Vector3 positionOfPiggyBank)
    {
        for (var i = 0; i < 10; i++)
        {
            Instantiate(CloudPrefab, positionOfPiggyBank, Quaternion.Euler(Random.Range(-180,180), Random.Range(-180, 180),Random.Range(-180, 180)));
        }
    }
}
