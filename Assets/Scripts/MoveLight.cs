using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveLight : MonoBehaviour
{
    public GameObject leftSpotLight;
    public GameObject rightSpotLight;
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
            if (leftSpotLight.transform.position.z < 540 + distance)
            {
                leftSpotLight.transform.position = leftSpotLight.transform.position + new Vector3(0, 0, speed * Time.deltaTime / 3.6f);
                rightSpotLight.transform.position = rightSpotLight.transform.position + new Vector3(0, 0, speed * Time.deltaTime / 3.6f);
            }
            else
            {
                leftSpotLight.transform.position = new Vector3(leftSpotLight.transform.position.x, leftSpotLight.transform.position.y, 540f);
                rightSpotLight.transform.position = new Vector3(rightSpotLight.transform.position.x, rightSpotLight.transform.position.y, 540f);
            }
        }
        
        
    }
}
