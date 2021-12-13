using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveCar : MonoBehaviour
{
    public GameObject Car;
    public GameObject avatar;

    public float speed = 20;

    private float distance = 10 * 61;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (avatar.transform.position.z > 500)
        {
            if (Car.transform.position.z < 500 + distance)
            {
                Car.transform.position = Car.transform.position + new Vector3(0, 0, speed * Time.deltaTime / 3.6f);
                //Car.transform.position = Car.transform.position + new Vector3(0, 0, speed * Time.deltaTime);
            }
            else
            {
                Car.transform.position = new Vector3(Car.transform.position.x, Car.transform.position.y, 540f);
            }
        }
    }
}
