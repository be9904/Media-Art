using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Hammer : MonoBehaviour
{
    public float minHitPower;
    
    private BNG.Grabbable _grabbable;
    private Rigidbody _rigidbody;

    private void Start()
    {
        _grabbable = GetComponent<BNG.Grabbable>();
        _rigidbody = GetComponent<Rigidbody>();
    }

    private void OnTriggerEnter(Collider other)
    {
        PiggyBank pb = FindObjectOfType<PiggyBank>();
        if (other.gameObject.CompareTag("PiggyBank") && !pb.isHit && _grabbable.BeingHeld)
        {
            if (_rigidbody.velocity.sqrMagnitude > minHitPower)
            {
                if(pb.CoinCapacity == 0)
                    pb.PlayAnimation(0);
                else if(pb.CoinCapacity < pb.MaxCoinCapacity)
                    pb.PlayAnimation(2);
                else if(pb.CoinCapacity >= pb.MaxCoinCapacity)
                    pb.PlayAnimation(1);
            }
        }
    }
}
