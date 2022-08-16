using System;
using System.Collections;
using System.Collections.Generic;
using BNG;
using UnityEngine;

public class PiggyBank : MonoBehaviour
{
    public int CoinCapacity;

    private MeshRenderer _meshRenderer;
    private Rigidbody _rigidbody;
    private Grabbable _grabbable;

    public GameObject emptyAnimation;
    public GameObject fullAnimation;
    
    // Start is called before the first frame update
    void Start()
    {
        _rigidbody = GetComponent<Rigidbody>();
        _grabbable = GetComponent<BNG.Grabbable>();
        _meshRenderer = GetComponent<MeshRenderer>();
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("Hammer"))
        {
            Debug.Log(collision.gameObject.name);
            PlayAnimation(0);
        }
    }
    
    void PlayAnimation(int id)
    {
        _meshRenderer.enabled = false;
        if (id == 0) // empty
            emptyAnimation.SetActive(true);
        else if (id == 1) // full
            fullAnimation.SetActive(true);
    }
}
