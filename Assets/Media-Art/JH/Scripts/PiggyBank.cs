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
    public AudioClip breakEffect;

    private AudioSource _audioSource;
    private AudioClip _originalSfx;
    public bool isHit = false;
    
    // Start is called before the first frame update
    void Start()
    {
        _audioSource = GetComponent<AudioSource>();
        _originalSfx = _audioSource.clip;
        
        _rigidbody = GetComponent<Rigidbody>();
        _grabbable = GetComponent<BNG.Grabbable>();
        _meshRenderer = GetComponent<MeshRenderer>();
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("Hammer") && !isHit)
        {
            if(CoinCapacity < 20)
                PlayAnimation(0);
            else if(CoinCapacity >= 20)
                PlayAnimation(1);
        }
    }
    
    void PlayAnimation(int id)
    {
        isHit = true;
        
        _meshRenderer.enabled = false;
        _rigidbody.isKinematic = true;

        _audioSource.clip = breakEffect;
        _audioSource.Play();
        
        if (id == 0) // empty
            emptyAnimation.SetActive(true);
        else if (id == 1) // full
            fullAnimation.SetActive(true);

        StartCoroutine(ResetAudioClip());
    }

    IEnumerator ResetAudioClip()
    {
        yield return new WaitForSeconds(breakEffect.length + 2);

        _audioSource.clip = _originalSfx;
        _rigidbody.isKinematic = false;
        isHit = false;
    }
}
