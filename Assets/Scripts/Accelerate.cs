using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Accelerate : MonoBehaviour
{
    public Transform rightHandler;

    public Transform leftHandler;

    public Transform avatar;

    private float speed  = 0; // speed is the meter/second


    public float K = 100f; // Gain
    public float T = 10f; // Time Constant
    private float input; // a(k)

    // our input is the rotation of the handler -> accelormeter -> speed 

    void Start()
    {
        
    }

    void FixedUpdate()
    {


        // to fetch controller button continuous ananlog value
        input = OVRInput.Get(OVRInput.Axis2D.PrimaryThumbstick)[1];
        // print(OVRInput.Get(OVRInput.Axis2D.PrimaryThumbstick)[1]);




        speed = (1 / (T + Time.fixedDeltaTime)) * (T * speed + K * Time.fixedDeltaTime * input);
        // friction = speed *= 0.999
        //speed *= 0.999f;
        // print("Speed "+ speed);

        avatar.position += new Vector3(0, 0, speed * Time.fixedDeltaTime);

        //print(speed);

        // when the car reaches 80km/H -> enter the tunnel = 22.22 meters/second

    }


}
