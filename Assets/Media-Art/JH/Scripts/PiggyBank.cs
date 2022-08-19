using System;
using System.Collections;
using System.Collections.Generic;
using BNG;
using UnityEngine;

public class PiggyBank : MonoBehaviour
{
    public int CoinCapacity;
    public int MaxCoinCapacity;
    public float shakeThreshold;

    private MeshRenderer _meshRenderer;
    private Rigidbody _rigidbody;
    private Grabbable _grabbable;
    private BoxCollider _boxCollider;
    private MeshCollider _meshCollider;

    public GameObject emptyAnimation;
    public GameObject fullAnimation;
    public AudioClip breakEffect;

    public AudioSource SfxAudioSource;
    public List<AudioClip> SfxAudioClips;
    private AudioSource _audioSource;
    private AudioClip _originalSfx;
    private int currentTrack;
    public bool isHit = false;
    
    // Materials
    public Material skinMat;
    public Material eyesMat;

    private float timer = 0f;
    BNG.InputBridge input;

    private void Awake()
    {
        input = BNG.InputBridge.Instance;
    }

    // Start is called before the first frame update
    void Start()
    {
        _audioSource = GetComponent<AudioSource>();
        _originalSfx = _audioSource.clip;
        
        _rigidbody = GetComponent<Rigidbody>();
        _grabbable = GetComponent<BNG.Grabbable>();
        _meshRenderer = GetComponent<MeshRenderer>();
        _boxCollider = GetComponent<BoxCollider>();
        _meshCollider = GetComponent<MeshCollider>();
    }

    private void Update() => Shake();

    void Shake()
    {
        if (_rigidbody.velocity.sqrMagnitude > shakeThreshold && _grabbable.BeingHeld)
        {
            timer += Time.deltaTime;
            CoinCapacity = (int)(timer * 0.75f);

            SfxAudioSource.volume = 1;

            if (CoinCapacity > MaxCoinCapacity * 0.35f && CoinCapacity <= MaxCoinCapacity * 0.7f)
            {
                input.VibrateController(.3f, .2f, .1f, BNG.ControllerHand.Left);
                input.VibrateController(.3f, .2f, .1f, BNG.ControllerHand.Right);
                if (currentTrack != 1)
                {
                    SfxAudioSource.clip = SfxAudioClips[1];
                    SfxAudioSource.loop = true;
                    SfxAudioSource.Play();
                    currentTrack = 1;
                }
            }
            else if (CoinCapacity > MaxCoinCapacity * 0.7f && CoinCapacity <= MaxCoinCapacity * 0.9f)
            {
                input.VibrateController(.3f, .3f, .1f, BNG.ControllerHand.Left);
                input.VibrateController(.3f, .3f, .1f, BNG.ControllerHand.Right);
                if (currentTrack != 2)
                {
                    SfxAudioSource.clip = SfxAudioClips[2];
                    SfxAudioSource.loop = true;
                    SfxAudioSource.Play();
                    currentTrack = 2;
                }
            }
            else if (CoinCapacity > MaxCoinCapacity * 0.9f)
            {
                input.VibrateController(.3f, .4f, .1f, BNG.ControllerHand.Left);
                input.VibrateController(.3f, .4f, .1f, BNG.ControllerHand.Right);
                if (currentTrack != 3)
                {
                    SfxAudioSource.clip = SfxAudioClips[3];
                    SfxAudioSource.loop = true;
                    SfxAudioSource.Play();
                    currentTrack = 3;
                }
            }
            else
            {
                input.VibrateController(.3f, .1f, .1f, BNG.ControllerHand.Left);
                input.VibrateController(.3f, .1f, .1f, BNG.ControllerHand.Right);
            }
        }
        else if (_rigidbody.velocity.sqrMagnitude > 0 && _grabbable.BeingHeld)
            SfxAudioSource.volume = _rigidbody.velocity.sqrMagnitude / shakeThreshold;
        else
            SfxAudioSource.volume = 0;
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

        _boxCollider.enabled = false;
        _meshCollider.enabled = false;

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
        _boxCollider.enabled = true;
        _meshCollider.enabled = true;

        for (int i = 2 ; i < gameObject.transform.childCount; i++)
        {
            transform.GetChild(i).gameObject.SetActive(false);
        }

        timer = 0f;
        CoinCapacity = 0;
        currentTrack = 0;
        SfxAudioSource.clip = SfxAudioClips[0];
        SfxAudioSource.Play();
    }

    private void OnApplicationQuit()
    {
        skinMat.SetFloat("_Weight", 0);
        eyesMat.SetFloat("_Weight", 0);
    }
}
