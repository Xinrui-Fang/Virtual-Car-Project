using System.Collections;
using System.Collections.Generic;
using UnityEngine;
public class AvatarCar : MonoBehaviour
{
    // Start is called before the first frame update
    public Transform Avatar;
    public Transform Avatar_Car;
    void Start()
    {

    }
    // Update is called once per frame
    void Update()
    {
        Avatar_Car.position = new Vector3(-0.08f, Avatar_Car.position.y, Avatar.position.z - 0.3f);
    }
}