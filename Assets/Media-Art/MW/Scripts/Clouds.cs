using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Clouds : MonoBehaviour
{
    private Vector3 initialPosition;
    public GameObject piggyBank;

    //First Move
    private float xpos = Random.Range(-4.5f, 4.5f);
    private float ypos = Random.Range(0, 4.5f);
    private float zpos = Random.Range(-4.5f, 4.5f);
    private float targetTime = Random.Range(0, 3);
    private bool isMoveOn = false;
    private Vector3 destination;

    //Second Move
    private bool isReturn = false;

    private void OnEnable()
    {
        isMoveOn=true;
        Debug.Log("Enabled");
    }
    private void Awake()
    {
        
    }
    void Start()
    {
        initialPosition = transform.position;
        destination = new Vector3(xpos, ypos, zpos);
    }

    // Update is called once per frame
    void Update()
    {
        if (isMoveOn)
        {
            transform.position = Vector3.MoveTowards(initialPosition, destination, destination.sqrMagnitude/targetTime);
        }
        if ((destination - transform.position).sqrMagnitude < 0.01)
        {
            isMoveOn = false;
        }

        //delay ÀÌÈÄ
        transform.position = Vector3.MoveTowards(destination, piggyBank.transform.position, destination.sqrMagnitude / targetTime);
        
    }
}
