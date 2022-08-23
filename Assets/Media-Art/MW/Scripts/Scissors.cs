using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using BNG;

public class Scissors : MonoBehaviour
{
    private InputBridge _inputBridge;
    private float _triggerOnPrevFrame;
    public float triggerSensitivity;
    
    private Grabbable _grabbable;

    private Grabber _currentGrabber;

    public Animator _animator;
    private void Awake() => _inputBridge = InputBridge.Instance;
    
    // Start is called before the first frame update
    void Start()
    {
        if (triggerSensitivity == 0)
            triggerSensitivity = .8f;

        _grabbable = GetComponent<Grabbable>();
    }

    // Update is called once per frame
    void Update() => PlayScissorAnim();

    void PlayScissorAnim()
    {
        if (_grabbable.BeingHeld)
        {
            _currentGrabber = _grabbable.HeldByGrabbers[0];

            // If grabbed by left hand
            if (_currentGrabber.HandSide == ControllerHand.Left)
            {
                if (_triggerOnPrevFrame < _inputBridge.LeftTrigger && _inputBridge.LeftTrigger > triggerSensitivity)
                {
                    //////////////////////////////////////
                    /////////// Play Animation ///////////
                    //////////////////////////////////////
                    _animator.SetBool("isOn",true);
                    Debug.Log("Snip by Left Hand");
                }

                _triggerOnPrevFrame = _inputBridge.LeftTrigger;
            }
        
            // If grabbed by right hand
            if (_currentGrabber.HandSide == ControllerHand.Right)
            {
                if (_triggerOnPrevFrame < _inputBridge.RightTrigger && _inputBridge.RightTrigger > triggerSensitivity)
                {
                    //////////////////////////////////////
                    /////////// Play Animation ///////////
                    //////////////////////////////////////
                    _animator.SetBool("isOn", true);
                    Debug.Log("Snip by Right Hand");
                }

                _triggerOnPrevFrame = _inputBridge.RightTrigger;
            }
        }
    }
}
