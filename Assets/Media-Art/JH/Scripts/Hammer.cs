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

    private void OnCollisionEnter(Collision collision)
    {
        PiggyBank pb = FindObjectOfType<PiggyBank>();
        if (collision.gameObject.CompareTag("PiggyBank") && !pb.isHit && _grabbable.BeingHeld)
        {
            if (_rigidbody.velocity.sqrMagnitude > minHitPower)
            {
                if(pb.CoinCapacity < 20)
                    pb.PlayAnimation(0);
                else if(pb.CoinCapacity >= 20)
                    pb.PlayAnimation(1);
            }
        }
    }
}
