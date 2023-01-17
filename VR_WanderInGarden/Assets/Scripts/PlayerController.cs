using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(CharacterController))]
public class PlayerController : MonoBehaviour
{
    private CharacterController cc => GetComponent<CharacterController>();
    public float moveSpeed;
    public float jumpSpeed;
    private float horizontalMove, verticalMove;
    private Vector3 dir;

    public float gravity;

    private Vector3 velocity;//control speed in Y axis

    //test whether the player is on the ground
    public Transform groundCheck;
    public float checkRadius;
    public LayerMask groundLayer;
    [HideInInspector] public bool isGround;
    [HideInInspector] public bool mouseEnabled=true;

    private void Update()
    {
        if(mouseEnabled)
        {
            isGround = Physics.CheckSphere(groundCheck.position, checkRadius, groundLayer);
            if (isGround && velocity.y < 0)
            {
                velocity.y = -2f;
            }

            horizontalMove = Input.GetAxis("Horizontal") * moveSpeed;
            verticalMove = Input.GetAxis("Vertical") * moveSpeed;
            dir = transform.forward * verticalMove + transform.right * horizontalMove;
            cc.Move(dir * Time.deltaTime);

            if (Input.GetButtonDown("Jump") && isGround)
            {
                velocity.y = jumpSpeed;
            }

            velocity.y -= gravity * Time.deltaTime;
            cc.Move(velocity * Time.deltaTime);
        }
        
        
    }

    public float GetDistanceToItem(Vector3 itemPos)
    {
        Vector3 toPlayer = transform.position - itemPos;
        Vector2 toPlayer_xz = new Vector2(toPlayer.x, toPlayer.z);
        return toPlayer_xz.magnitude;
    }

}
