using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.XR.Interaction.Toolkit;

public class ControllerInteraction : MonoBehaviour
{
    [SerializeField]
    public XRInteractorLineVisual selection;
    // Start is called before the first frame update
    private void Start()
    {
        if(selection == null){
            selection = GetComponent<XRInteractorLineVisual>();
        }
    }

    public void LineActive(){
        selection.enabled = true;
    }
    public void LineDeactive(){
        selection.enabled = false;
    }

}
