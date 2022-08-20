using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MagicInteraction00 : MonoBehaviour
{
    private Component XRGrabInteractable;
    void Start()
    {
        if(XRGrabInteractable == null){
            //XRGrabInteractable = gameObject.GetComponent<XRGrabInteractable>();
        }
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
        Debug.Log("Select Entered");
        //XRGrabInteractable
    }
    public void SelectExited()
    {
        Debug.Log("Select Exited");
    }
    public void Activated()
    {
        Debug.Log("Activated");
    }
    public void Deactivated()
    {
        Debug.Log("Deactivated");
    }

}
