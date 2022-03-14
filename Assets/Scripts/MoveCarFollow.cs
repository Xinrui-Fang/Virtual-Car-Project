using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveCarFollow : MonoBehaviour
{
    public GameObject Car; // Preceding Car
    public GameObject avatar; // User Avatar

    public static float speed = 0;


    private float distance = 10 * 61;

    public float breaking_speed = 90f;

    public Light targetlight_left;
    public Light targetlight_right;

    private float counter = 0;
    private float delta = 0; // 2022.01.24

    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void FixedUpdate()
    {
        Car.transform.position += new Vector3(0, 0, speed * Time.fixedDeltaTime / 3.6f); // iterate the position of the car 0 -> 80
                                                                                         //print("Front car speed: " + speed);
                                                                                         //print("Your speed: " + Accelerate.speed);


        // Accelarote the speed of preceeding car to 80km/h
        if (speed < 80 && delta < 5)
        {
            speed += 0.04f;

        }
        else // if the speed of the vehicle ahead reaches 80 km/h
        {

            // if 𝑑𝑒𝑙𝑡𝑎 < 𝐷𝑒𝑙𝑡𝑎 The preceding car continues to drive at 80 km/h
            if (delta < 5)
            {
                // if your speed is in the range of [70, 90]
                if (Accelerate_v2.speed >= 80 - 3 && Accelerate_v2.speed <= 80 + 3)
                {
                    // 𝑑𝑒𝑙𝑡𝑎 += ∆𝑡
                    delta += Time.fixedDeltaTime;
                }
                else
                {
                    delta = 0;
                }
                speed = 80;
            }
            else
            {
                // 𝑣𝑝𝑟𝑒=65 (km/h)
                speed = 90;
            }

        }

        // Set countere manually to break down the speed of car, and turn to red light
        //if (counter >1200)
        //{
        //    speed = breaking_speed;
        //    targetlight_left.color = Color.red;
        //    targetlight_right.color = Color.red;
        //}
        //
        //// Turn to white light
        //if (counter > 1300)
        //{
        //    targetlight_left.color = Color.white;
        //    targetlight_right.color = Color.white;
        //}

        // counter += 1;


    }
}