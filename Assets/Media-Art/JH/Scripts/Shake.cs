using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Shake : MonoBehaviour
{
    public GameObject piggyBank;
    private Rigidbody rb;
    private GameObject[] coinArray;
    public int coinCount = 0;
    private float timer = 0f;
    private bool isOn = true;

    void Start()
    {
        rb = piggyBank.GetComponent<Rigidbody>();
        coinArray = new GameObject[22];
        for(int i=0; i<22; i++)
        {
            coinArray[i] = piggyBank.transform.GetChild(i).gameObject;
        }
    }

    // Update is called once per frame
    void Update()
    {
        timer += Time.deltaTime;
        if (timer > 1)
        {
            Debug.Log("if Timer...");
            isOn = true;
            timer = 0;
        }

        Debug.Log("Angular Velocity: " + rb.angularVelocity.magnitude.ToString());
        Debug.Log("Linear Velocity: " + rb.velocity.magnitude.ToString());
        if ((rb.angularVelocity.sqrMagnitude > 3 || rb.velocity.sqrMagnitude > 0.5) && isOn)
        {
            coinArray[coinCount].SetActive(true);
            coinCount++;
            isOn = false;
        }
    }

    public int CoinCounter()
    {
        return coinCount;
    }
}
