using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HammerCollision : MonoBehaviour
{
    private void OnCollisionStay(Collision collisionInfo)
    {
        Debug.Log(collisionInfo.gameObject.name);
    }
}
