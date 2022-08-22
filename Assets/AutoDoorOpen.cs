using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AutoDoorOpen : MonoBehaviour
{
    public float timeLength=2.0f;

    private float alphaClip;
    private bool isDetected=false;
    private bool isNotDone = true;
    // Start is called before the first frame update
    void Start()
    {
        alphaClip = gameObject.GetComponent<Renderer>().material.GetFloat("_AlphaClip");
    }

    // Update is called once per frame
    void Update()
    {
        if (isDetected&&isNotDone)
        {
            alphaClip+= Time.deltaTime/timeLength;
            if (alphaClip >= 1)
            {
                isNotDone = false;
            }
        }
    }
    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Player")
        {
            isDetected = true;
        }
    }
}
