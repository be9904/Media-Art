using System;
using System.Collections;
using System.Collections.Generic;
using BNG;
using UnityEngine;

public class PiggyBank : MonoBehaviour
{
    public int CoinCapacity;

    private Rigidbody _rigidbody;
    private Grabbable _grabbable;
    
    // Start is called before the first frame update
    void Start()
    {
        _rigidbody = GetComponent<Rigidbody>();
        _grabbable = GetComponent<BNG.Grabbable>();
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnCollisionEnter(Collision collision)
    {
        if(collision.gameObject.CompareTag("HammerEnd"))
            Debug.Log("Hit by Hammer");
    }
}
