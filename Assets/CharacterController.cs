using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CharacterController : MonoBehaviour
{
    public Animator animator;
    Vector3 lastPosition;
    float walkSpeed = 0;
    // Start is called before the first frame update
    void Start()
    {
        lastPosition = transform.position;
    }

    // Update is called once per frame
    void Update()
    {
        if(Vector3.Distance(lastPosition, transform.position) > 0)
        {
            walkSpeed = Mathf.Lerp(walkSpeed, 1, Time.deltaTime);
        }
        else
        {
            walkSpeed = Mathf.Lerp(walkSpeed, 0, Time.deltaTime);
        }

        Debug.Log("WalkSpeed: " + walkSpeed);
        animator.SetFloat("WalkSpeed", walkSpeed);
        lastPosition = transform.position;
    }
}
