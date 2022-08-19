using System;
using System.Collections;
using System.Collections.Generic;
using BNG;
using UnityEngine;

public class PiggyBank : MonoBehaviour
{
    public int CoinCapacity;
    public float shakeThreshold;

    private MeshRenderer _meshRenderer;
    private Rigidbody _rigidbody;
    private Grabbable _grabbable;
    private BoxCollider _collider;

    public GameObject emptyAnimation;
    public GameObject fullAnimation;
    public AudioClip breakEffect;

    private AudioSource _audioSource;
    private AudioClip _originalSfx;
    public bool isHit = false;
    
    // Materials
    public Material skinMat;
    public Material eyesMat;

    private float timer = 0f;
    
    // Start is called before the first frame update
    void Start()
    {
        _audioSource = GetComponent<AudioSource>();
        _originalSfx = _audioSource.clip;
        
        _rigidbody = GetComponent<Rigidbody>();
        _grabbable = GetComponent<BNG.Grabbable>();
        _meshRenderer = GetComponent<MeshRenderer>();
        _collider = GetComponent<BoxCollider>();
    }

    private void Update()
    {
        if (_rigidbody.velocity.sqrMagnitude > shakeThreshold && _grabbable.BeingHeld)
        {
            timer += Time.deltaTime;
            CoinCapacity = (int)(timer * 0.75f);
        }
    }

    

    public void PlayAnimation(int id)
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

        _collider.enabled = false;

        StartCoroutine(Reset());
    }

    IEnumerator Reset()
    {
        yield return new WaitForSeconds(10f);
        
        _meshRenderer.enabled = true;
        
        float val = 1f;
        skinMat.SetFloat("_Weight", val);
        eyesMat.SetFloat("_Weight", val);
        skinMat.SetFloat("_Expand", 1f);
        eyesMat.SetFloat("_Expand", 1f);

        while (val > 0)
        {
            val -= .01f;
            skinMat.SetFloat("_Weight", val);
            eyesMat.SetFloat("_Weight", val);

            yield return null;
        }
        
        skinMat.SetFloat("_Expand", 0.2f);
        eyesMat.SetFloat("_Expand", 0.2f);
        
        _audioSource.clip = _originalSfx;
        
        isHit = false;
        
        _rigidbody.isKinematic = false;
        _collider.enabled = true;

        for (int i = 2 ; i < gameObject.transform.childCount; i++)
        {
            transform.GetChild(i).gameObject.SetActive(false);
        }
    }
}
