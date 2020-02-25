using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SpawnedObject : MonoBehaviour
{

    public Action<Transform> CollidedWithSomething;

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.tag == "Player")
        {
            RaiseCollisionEvent(transform);
        }
    }

    private void RaiseCollisionEvent(Transform transform)
    {
        if (CollidedWithSomething != null)
        {
            CollidedWithSomething(transform);
        }
    }

    void OnTriggerEnter(Collider collision)
    {
        if (collision.gameObject.tag == "Player")
        {
            RaiseCollisionEvent(transform);
        }
    }
}
