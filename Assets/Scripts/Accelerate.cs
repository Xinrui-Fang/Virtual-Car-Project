using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Accelerate : MonoBehaviour
{
    public Transform rightHandler;

    public Transform leftHandler;

    public Transform avatar;

    private float speed  = 0; // speed is the meter/second

    // our input is the rotation of the handler -> accelormeter -> speed 

    void Start()
    {
        
    }

    void Update()
    {


        //print(rightHandler.rotation.x);
        // user push the accelerator
        if (rightHandler.rotation.x > 0)
        {
            speed += 0.01f;
        }


        // user push the break
        if (leftHandler.rotation.x > 0)
        {
            speed -= 0.01f;

        }

        // friction = speed *= 0.999
        speed *= 0.999f;

        avatar.position -= new Vector3(0, 0, speed * Time.deltaTime);

        //print(speed);

        // when the car reaches 80km/H -> enter the tunnel = 22.22 meters/second

    }


}
