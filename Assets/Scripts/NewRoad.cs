using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NewRoad : MonoBehaviour
{
    public GameObject road;
    public int max;
    private int counter = 1;

    

    // Update is called once per frame
    void Update()
    {
        if (counter < max)
        {
            
            GameObject road_extend = GameObject.Instantiate(road);
            road_extend.transform.position = road.transform.position + new Vector3(0, 0, 10 * counter);
            counter += 1;
        }
    }
}
