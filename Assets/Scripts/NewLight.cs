using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NewLight : MonoBehaviour
{
    public GameObject leftSpotLight;
    public GameObject rightSpotLight;
    public int max;
    private int counter = 1;

    // Start is called before the first frame update
    void Start()
    {

    }
    void Awake()
    {
        
    }

    // Update is called once per frame
    void Update()
    {

        // we need to change the generation speed here.
        // when the new pair or light generated, we delete the old ones.
        if (counter < max)
        {

            GameObject lspotLight_extend = GameObject.Instantiate(leftSpotLight);
            GameObject rspotLight_extend = GameObject.Instantiate(rightSpotLight);
            lspotLight_extend.transform.position = leftSpotLight.transform.position + new Vector3(0, 0, 10 * counter);
            rspotLight_extend.transform.position = rightSpotLight.transform.position + new Vector3(0, 0, 10 * counter);
            counter += 1;
        }
    }
}