using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MagicInteraction00 : MonoBehaviour
{
    private Component XRGrabInteractable;
    public GameObject lasor;
    void Start()
    {
        if(XRGrabInteractable == null){
            //XRGrabInteractable = gameObject.GetComponent<XRGrabInteractable>();
        }
        lasor.SetActive(false);
    }
    public void FirstHover()
    {
        //Debug.Log("First Hover");
    }
    public void LastHover()
    {
        //Debug.Log("Last Hover");
    }
    public void HoverEntered()
    {
        //Debug.Log("Hover Entered");
    }
    public void HoverExit()
    {
        //Debug.Log("Hover Exited");
    }
    public void FirstSelect()
    {
        Debug.Log("First selected");
    }
    public void LastSelect()
    {
        Debug.Log("Last selected");
    }
    public void SelectEntered()
    {
        GameManager.instance.StickHold();
    }
    public void SelectExited()
    {
        GameManager.instance.StickRelease();
    }
    public void Activated()
    {
        lasor.SetActive(true);
    }
    public void Deactivated()
    {
        lasor.SetActive(false);
    }

}
