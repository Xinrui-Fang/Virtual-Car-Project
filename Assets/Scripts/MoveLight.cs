using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveLight : MonoBehaviour
{
    public GameObject leftSpotLight;
    public GameObject rightSpotLight;
    public GameObject avatar;

    public float light_speed = 0;
    public float accele_light_speed = 90f;

    private float delta = 0; // 2022.02.05

    private float distance = 10 * 61;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        leftSpotLight.transform.position = leftSpotLight.transform.position + new Vector3(0, 0, light_speed * Time.deltaTime / 3.6f);
        rightSpotLight.transform.position = rightSpotLight.transform.position + new Vector3(0, 0, light_speed * Time.deltaTime / 3.6f);

        if (light_speed < 80 && delta < 5)
        {
            light_speed += 0.04f;

        }
        else
        {
            if (delta < 5)
            {
                // if your speed is in the range of [70, 90]
                if (Accelerate_v2.speed >= 80 - 3 && Accelerate_v2.speed <= 80 + 3)
                {
                    delta += Time.fixedDeltaTime;
                }
                else
                {
                    delta = 0;
                }
                light_speed = 80;
            }
            else
            {
                light_speed = accele_light_speed;
            }
        }
        
        
    }
}
