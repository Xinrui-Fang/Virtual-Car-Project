using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NewScale : MonoBehaviour
{
    public GameObject theGameObject;
    // Start is called before the first frame update
    void Start()
    {
        float size = theGameObject.GetComponent<Renderer>().bounds.size.z;
        print(size);
    }

    // Update is called once per frame
    void Update()
    {

    }
}