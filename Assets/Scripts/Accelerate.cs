using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Text;
using System.IO;
using UnityEngine.UI;

public class Accelerate : MonoBehaviour
{
    public Transform rightHandler;

    public Transform leftHandler;

    public Transform avatar;
    public Transform UI;
    public Text Speed_panel;

    private float speed  = 0; // speed is the meter/second


    public float K = 100f; // Gain
    public float T = 10f; // Time Constant
    private float input; // a(k)

    private int counter = 0; // To check if the frames lost or not

   
    private string path = @"C:\Users\super\test_minus.csv";


    // our input is the rotation of the handler -> accelormeter -> speed 

    void Start()
    {
        
    }

    void FixedUpdate()
    {


        // to fetch controller button continuous ananlog value
        input = OVRInput.Get(OVRInput.Axis2D.PrimaryThumbstick)[1];
        // print(OVRInput.Get(OVRInput.Axis2D.PrimaryThumbstick)[1]);




        speed = (1 / (T + Time.fixedDeltaTime)) * (T * speed + K * Time.fixedDeltaTime * input);
        //print(speed);

        //Write2CSV(counter, input, speed); // write the variables into the .csv file
        counter += 1; // itereate the counter

        avatar.position += new Vector3(0, 0, speed * Time.fixedDeltaTime / 3.6f); // iterate the position of the user
        UI.position += new Vector3(0, 0, speed * Time.fixedDeltaTime / 3.6f); // iterate the position of the speed panel

        // speed -> meters / second -> meters / hour -> KM / hour
        Speed_panel.text = (speed).ToString() + " KM/H";




        // when the car reaches 80km/H -> enter the tunnel = 22.22 meters/second

    }

    private void Write2CSV( int counter, float input, float speed)
    {
        StreamWriter sw = new StreamWriter(path, true, Encoding.UTF8);
        //open the file for recording//
        if (!File.Exists(path))
        {
            File.Create(path).Close();
        }

        sw.Write(counter + ",");
        sw.Write(input + ",");
        sw.Write(speed + ",");

        sw.Write("\r\n");
        sw.Flush();
        sw.Close();
    }


}
