using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Text;
using System.IO;
using UnityEngine.UI;

public class Accelerate_fordemo : MonoBehaviour
{
    // Start is called before the first frame update
    public Transform rightHandler;

    public Transform leftHandler;

    public Transform avatar;
    public Transform UI;
    public Text Speed_panel;

    public GameObject Car;
    public GameObject leftSpotLight;
    public int avatarnumber = 1;
    public static float accel = 0f; // speed is the meter/second,v[k+1]
    public static float accelpre = 0f; // speed is the meter/second,v[k+1]

    public static float speed = 70; // speed is the meter/second,v[k+1]
    public static float speed_pre = 70;//v[k]
    public static float speed_pre2 = 70;//v[k-1]
    public static float[] SPEED = new float[] { 70f, 70f, 70f, 70f, 70f, 70f, 70f, 70f, 70f, 70f, 70f, 70f, 70f, 70f, 70f };
    public static float K = 4f; // Gain
    public static float T = 0.25f; // Time Constant
    private float input; // a(k)
    private int counter = 0; // To check if the frames lost or not

    private float[] CL = new float[] { 0.282f, 0.246f, 0.084f, 0.106f, 0.057f, 0.142f, 0.188f, 0.231f, 0.172f, 0.134f };
    private int[] DL = new int[] { 2, 2, 7, 2, 7, 5, 3, 3, 4, 4 };

    private float[] CM = new float[] { 0.132f, 0.096f, 0.100f, 0.035f, 0.024f, 0.069f, 0.057f, 0.072f, 0.057f, 0.064f };
    private int[] DM = new int[] { 6, 6, 8, 3, 13, 9, 9, 10, 15, 8};

    private static float timer = 10;
    private string path = @"G:\マイドライブ\MDP\202310303.csv";//path where the data will be saved.


    // our input is the rotation of the handler -> accelormeter -> speed 

    void Start()
    {


    }

    void FixedUpdate()
    {


        // to fetch controller button continuous ananlog value
        //input = OVRInput.Get(OVRInput.Axis2D.PrimaryThumbstick)[1]; // [-1, 1]
        // Tilt Range we want is [0, 45]
        // If Theta X>= 45, then Theta X = 45
        // If Theta X < 0, then Theta X = 0
        // input = Theta X / 45. 

        if (MoveCar.speed < 80)
        {
            speed = MoveCar.speed;
        }


        if (MoveCar.speed == 80)
        {
            if (MoveLightdemo.timer == 10)
            {
                if (MoveLightdemo.timer3 == 1)
                {
                    input = CM[avatarnumber - 1] * (MoveCar.SPEED[9 - DM[avatarnumber - 1]] - SPEED[9 - DM[avatarnumber - 1]]);
                }
                else
                {
                    input = CL[avatarnumber - 1] * (MoveLightMPCRBF.SPEED[9 - DL[avatarnumber - 1]] - SPEED[9 - DL[avatarnumber - 1]]);
                }
                timer = 0;

                if (input > 1f)
                {
                    input = 1f;
                }
                if (input < -1f)
                {
                    input = -1f;
                }
                speed_pre2 = speed_pre;
                speed_pre = speed;
                accelpre = accel;
                accel = (Time.fixedDeltaTime *10 * K / T) * input + ((T - Time.fixedDeltaTime *10) / T) * accelpre;
                speed = speed_pre + Time.fixedDeltaTime * 10 * accelpre;
                //print(speed);
                for (int j = 0; j <= 8; j++)
                {
                    SPEED[j] = SPEED[j + 1];
                }
                SPEED[9] = speed;

            }
        }
       
        ///@ Save the .csv file here:
        Write2CSV(counter, input, speed); // write the variables into the .csv file

        counter += 1; // itereate the counter

        avatar.position += new Vector3(0, 0, speed * Time.fixedDeltaTime / 3.6f); // iterate the position of the user
        //UI.position += new Vector3(0, 0, speed * Time.fixedDeltaTime / 3.6f); // iterate the position of the speed panel

        // speed -> meters / second -> meters / hour -> KM / hour
        Speed_panel.text = (speed).ToString() + " KM/H";




        // when the car reaches 80km/H -> enter the tunnel = 22.22 meters/second

    }

    private void Write2CSV(int counter, float input, float speed)
    {
        StreamWriter sw = new StreamWriter(path, true, Encoding.UTF8);
        //open the file for recording//
        if (!File.Exists(path))
        {
            File.Create(path).Close();
        }
        //save data
        sw.Write(counter + ",");
        sw.Write(input + ",");
        sw.Write(accel + ",");
        sw.Write(speed + ",");
        sw.Write(MoveCar.speed + ",");
        sw.Write(MoveLightMPCRBF.speed + ",");
        //sw.Write(MoveLightMPCRBF.speed - speed + ",");
        //sw.Write(MoveCar.speed - speed + ",");
        sw.Write(avatar.position.z + ",");

         sw.Write(MoveLightMPCRBF.timer + ",");
        // sw.Write(MoveLightMPCRBF.timer2 + ",");
        //  sw.Write(MoveLightMPC1021.speed_pre1 -speed + ",");
        //  sw.Write(leftSpotLight.transform.position.z - avatar.position.z - MoveLightMPCRBF.hl * 80 + ",");
        // sw.Write(Car.transform.position.z - avatar.position.z - MoveLightMPCRBF.hm * 80 + ",");

        sw.Write("\r\n");
        sw.Flush();
        sw.Close();
    }

    IEnumerator Vivration(float time, float amplitude, int handlerNumber)
    {


        if (handlerNumber == 0)
        {
            OVRInput.SetControllerVibration(0.51f, amplitude, OVRInput.Controller.RTouch);

            yield return new WaitForSeconds(time);

            OVRInput.SetControllerVibration(0, 0, OVRInput.Controller.RTouch);
        }
        else
        {
            OVRInput.SetControllerVibration(0.51f, amplitude, OVRInput.Controller.LTouch);

            yield return new WaitForSeconds(time);

            OVRInput.SetControllerVibration(0, 0, OVRInput.Controller.LTouch);
        }
        


    }


}
