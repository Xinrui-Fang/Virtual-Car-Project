using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveCar : MonoBehaviour
{
    public GameObject Car; // Preceding Car
    public GameObject avatar; // User Avatar

    public static float speed = 0;


    private float distance = 10 * 61;

    public float breaking_speed = 65f;

    public Light targetlight_left;
    public Light targetlight_right;

    private float counter = 0;

    // Start is called before the first frame update
    void Start()
    {
       
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        Car.transform.position += new Vector3(0, 0, speed * Time.fixedDeltaTime / 3.6f); // iterate the position of the car 0 -> 80
        print(speed);

        if (speed < 80 && counter <= 1200)
        {
            speed += 0.08f;
            //print(speed);
        }

        if (counter >1200)
        {
            speed = breaking_speed;
            targetlight_left.color = Color.red;
            targetlight_right.color = Color.red;
        }
        if (counter > 1300)
        {
            targetlight_left.color = Color.white;
            targetlight_right.color = Color.white;
        }

        counter += 1;

       
    }
}
