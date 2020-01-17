using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DisplayGizmo : MonoBehaviour
{
    public string GizmoImageName;

    // Update is called once per frame
    void Update()
    {
        if (string.IsNullOrEmpty(GizmoImageName) == false)
        {
            Gizmos.DrawIcon(transform.position, GizmoImageName);
        }
    }
}
