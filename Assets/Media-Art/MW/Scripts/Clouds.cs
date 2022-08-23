using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Clouds : MonoBehaviour
{
    private Vector3 initialPosition;
    public GameObject piggyBank;

    //First Move
    private float xpos;
    private float ypos;
    private float zpos;
    private float targetTime=4;
    private bool isMoveOn = false;
    private bool isMoved = false;
    
    //Second Move
    private bool isSecondMoved = false;
    private Vector3 destination;

    private float timer = 0.0f;
    
    private Color color;
    private Vector3 colorVector;
    private Vector3 initColorVector;
    private Vector3 destColorVector;
    private float waitingTime = 10;

    
    private void OnEnable()
    {
        isMoveOn=true;
        Debug.Log("Enabled");
    }
    private void Awake()
    {
        xpos = Random.Range(-4.5f, 4.5f);
        ypos = Random.Range(0, 4.5f);
        zpos = Random.Range(-4.5f, 4.5f);
        targetTime = Random.Range(0, 3);
    }
    void Start()
    {
        initialPosition = transform.position;
        destination = new Vector3(xpos, ypos, zpos);

        color = gameObject.GetComponent<Renderer>().material.GetColor("_CloudColor");
        colorVector = new Vector3(color.r, color.g, color.b);
        Debug.Log("initColorVec: " + colorVector.ToString());
        initColorVector = colorVector;
        destColorVector = new Vector3(1, 0.8431f, 0);
    }

    // Update is called once per frame
    void Update()
    {
        gameObject.GetComponent<Renderer>().material.SetColor("_CloudColor", new Color(colorVector.x,colorVector.y,colorVector.z));
        if (isMoveOn)
        {
            transform.position = Vector3.MoveTowards(initialPosition, destination, destination.sqrMagnitude/targetTime);
        }
        if ((destination - transform.position).sqrMagnitude < 0.01)
        {
            isMoveOn = false;
            Debug.Log("!isMoveOn");
            isMoved = true;
        }
        if (isMoved&&!isSecondMoved)
        {
            //Debug.Log("if (isMoved&&!isSecondMoved)");   
            timer += Time.deltaTime;

            if (timer > waitingTime)
            {
                Debug.Log("Timer Entered");   

                EnvironmnetManager.instance.isReturn = true;
                transform.position = Vector3.MoveTowards(destination, initialPosition, destination.sqrMagnitude / targetTime);
                colorVector = Vector3.MoveTowards(initColorVector, destColorVector,0.1f);
                //isSecondMoved = true;
                Debug.Log(gameObject.GetComponent<Renderer>().material.GetColor("_CloudColor"));
            }           
        }
    }
}
