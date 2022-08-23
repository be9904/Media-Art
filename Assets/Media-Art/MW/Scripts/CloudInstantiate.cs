using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CloudInstantiate : MonoBehaviour
{
    public static CloudInstantiate instance;
    public GameObject CloudPrefab;
    private GameObject[] arrayCloud;
    private void Awake()
    {
        instance = this;
        arrayCloud = new GameObject[20];
    }
    public void WhenCut(Vector3 positionOfPiggyBank)
    {
        for (var i = 0; i < 20; i++)
        {
            arrayCloud[i]= Instantiate(CloudPrefab, positionOfPiggyBank, Quaternion.Euler(Random.Range(-180,180), Random.Range(-180, 180),Random.Range(-180, 180))) as GameObject;
            arrayCloud[i].transform.parent = transform;
            arrayCloud[i].SetActive(true);
            Debug.Log("Cloud " + i.ToString() + " instantiated");
        }
    }
}
