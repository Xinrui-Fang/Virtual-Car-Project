using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NewTunnel : MonoBehaviour
{
    public GameObject tunnel;
    public int max;
    private int counter = 1;

    

    // Update is called once per frame
    void Update()
    {
        if (counter < max)
        {

            GameObject tunnel_extend = GameObject.Instantiate(tunnel);
            tunnel_extend.transform.position = tunnel.transform.position + new Vector3(0, 0, 61.09812f * counter);
            counter += 1;
        }
    }
}
