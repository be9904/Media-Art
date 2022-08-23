using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LasorBeam : MonoBehaviour
{
    public GameObject grabPoint, beamPoint;
    public LineRenderer lr0, lr1, lr2, lr3, lr4, lr5, lr6;
    public float maxLength;

    // Update is called once per frame
    void Update()
    {
        Vector3 direction = (beamPoint.transform.position - grabPoint.transform.position).normalized;
        lr0.SetPosition(0, beamPoint.transform.position + direction * 0.1f);
        lr1.SetPosition(0, beamPoint.transform.position + direction * 0.2f);
        lr2.SetPosition(0, beamPoint.transform.position + direction * 0.05f);
        lr3.SetPosition(0, beamPoint.transform.position);
        lr4.SetPosition(0, beamPoint.transform.position + direction * 0.2f);
        lr5.SetPosition(0, beamPoint.transform.position + direction * 0.15f);
        lr6.SetPosition(0, beamPoint.transform.position);

        RaycastHit hit;
        if(Physics.Raycast(beamPoint.transform.position, direction, out hit, maxLength)){
            if(hit.collider){
                lr0.SetPosition(1, hit.point);
                lr1.SetPosition(1, hit.point);
                lr2.SetPosition(1, hit.point);
                lr3.SetPosition(1, hit.point);
                lr4.SetPosition(1, hit.point);
                lr5.SetPosition(1, hit.point);
                lr6.SetPosition(1, hit.point);
            }
        }
        else{
            lr0.SetPosition(1, beamPoint.transform.position + direction * maxLength);
            lr1.SetPosition(1, beamPoint.transform.position + direction * maxLength);
            lr2.SetPosition(1, beamPoint.transform.position + direction * maxLength);
            lr3.SetPosition(1, beamPoint.transform.position + direction * maxLength);
            lr4.SetPosition(1, beamPoint.transform.position + direction * maxLength);
            lr5.SetPosition(1, beamPoint.transform.position + direction * maxLength);
            lr6.SetPosition(1, beamPoint.transform.position + direction * maxLength);
        }
    }

}
