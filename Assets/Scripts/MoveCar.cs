using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveCar : MonoBehaviour
{
    public GameObject Car; // Preceding Car
    public GameObject avatar; // User Avatar

    private float speed = 0;

    private float distance = 10 * 61;

    public float breaking_speed = 65f;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        Car.transform.position += new Vector3(0, 0, speed * Time.fixedDeltaTime / 3.6f); // iterate the position of the car 0 -> 80
        //print(speed);

        if (speed < 80)
        {
            speed += 0.05f;
            print(speed);
        }

        if (Car.transform.position.z > 660)
        {
            breaking_speed = 65;
        }
    }
}
