using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PiggyBankScript : MonoBehaviour
{
    public static PiggyBankScript instance;

    public GameObject scissors;
    private Animator scissorsAnimator;
    private bool isScissorsAnimated;
    private bool isFirstCut = true;

    public int slicing = 10000; //inspector에서 확인하기 위해 우선 public

    private void Awake()
    {
        instance = this;
    }
    void Start()
    {
        scissorsAnimator = scissors.GetComponentInChildren<Animator>();
    }
    void Update()
    {
        isScissorsAnimated = scissorsAnimator.GetBool("isOn");
        if (slicing <= 0&& isFirstCut)
        {
            //Action
            isFirstCut = false;
            CloudInstantiate.instance.WhenCut(transform.position);
        }
    }
    private void OnTriggerEnter(Collider other)
    {
        Debug.Log("Trigger On");
        if (isScissorsAnimated)
        {
            slicing -= 1;

        }
    }
    /*
    public bool CheckIsCut()
    {
        return isCut;
    }
    */
}
