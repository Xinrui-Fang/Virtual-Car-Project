using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveLightdemo : MonoBehaviour
{
    public GameObject Car;
    public GameObject leftSpotLight;
    public GameObject rightSpotLight;
    public Transform avatar;

    public static float speed = 80;
    public static float speed_pre1 = 80;
    private static float speed_pre2 = 80;
    private static float speed_pre3 = 80;
    private static float speed_pre4 = 80;
    public static float[] SPEED = new float[] {80f, 80f, 80f,80f,80f,80f,80f,80f,80f,80f };
    public static float speedcar = 80;
    public static float speedpreceding = 80;
    public static float positionpreceding = 10;
    public static float positioncar = 0;

    public static float timer = 0;
    public static float timer2 = 0;
    public static float timer3 = 0;

    private float distance = 20 * 61;
    // Start is called before the first frame update

    private float[,] R = new float[,]{
                                      {0f,0.15f,0.3f,0.45f,0.6f,0.75f,0.9f,1.05f,1.2f,1.35f,1.5f,1.65f,1.8f,1.95f,2.1f,2.25f,2.4f,2.55f,2.7f,2.85f,3f,3.15f,3.3f,3.45f,3.6f,3.75f,3.9f,4.05f,4.2f,4.35f,4.5f,4.65f,4.8f,4.95f,5.1f,5.25f,5.4f,5.55f,5.7f,5.85f,6f,6.15f,6.3f,6.45f,6.6f,6.75f,6.9f,7.05f,7.2f,7.35f,7.5f,7.65f,7.8f,7.95f,8.1f,8.25f,8.4f,8.55f,8.7f,8.85f,9f,9.15f,9.3f,9.45f,9.6f,9.75f,9.9f,10.05f,10.2f,10.35f,10.5f,10.65f,10.8f,10.95f,11.1f,11.25f,11.4f,11.55f,11.7f,11.85f,12f,12.15f,12.3f,12.45f,12.6f,12.75f,12.9f,13.05f,13.2f,13.35f,13.5f,13.65f,13.8f,13.95f,14.1f,14.25f,14.4f,14.55f,14.7f,14.85f,15f},
                                      {0f,0.1f,0.2f,0.3f,0.4f,0.5f,0.6f,0.7f,0.8f,0.9f,1f,1.1f,1.2f,1.3f,1.4f,1.5f,1.6f,1.7f,1.8f,1.9f,2f,2.1f,2.2f,2.3f,2.4f,2.5f,2.6f,2.7f,2.8f,2.9f,3f,3.1f,3.2f,3.3f,3.4f,3.5f,3.6f,3.7f,3.8f,3.9f,4f,4.1f,4.2f,4.3f,4.4f,4.5f,4.6f,4.7f,4.8f,4.9f,5f,5.1f,5.2f,5.3f,5.4f,5.5f,5.6f,5.7f,5.8f,5.9f,6f,6.1f,6.2f,6.3f,6.4f,6.5f,6.6f,6.7f,6.8f,6.9f,7f,7.1f,7.2f,7.3f,7.4f,7.5f,7.6f,7.7f,7.8f,7.9f,8f,8.1f,8.2f,8.3f,8.4f,8.5f,8.6f,8.7f,8.8f,8.9f,9f,9.1f,9.2f,9.3f,9.4f,9.5f,9.6f,9.7f,9.8f,9.9f,10f }
                                     };

    private float[,] W = new float[,]{
                                      {0.18974f,0.098591f,0.043191f,0.15767f,0.44984f,-0.048728f,-0.25695f,-0.062938f,0.10209f,0.077178f,0.18981f,-0.063714f,0.11752f,0.005136f,0.027066f,0.12368f,0.21459f,0.11257f,-0.12807f,0.13774f,0.18182f,-0.015973f,0.0070602f,-0.13507f,0.18473f,-0.048293f,0.25838f,-0.010826f,0.1131f,0.21765f,-0.030586f,0.046125f,-0.070737f,0.2653f,-0.0014583f,-0.131f,0.12614f,-0.11827f,0.2119f,0.32033f,0.0047025f,-0.044123f,0.13625f,-0.15895f,0.25927f,0.066095f,0.10364f,-0.049411f,0.1101f,-0.092756f,0.10409f,0.18555f,0.20844f,0.060355f,-0.11017f,-0.20049f,0.68013f,-0.22551f,0.01161f,-0.054691f,0.2677f,0.18858f,0.061525f,-0.23775f,0.17739f,0.15118f,-0.093236f,0.19885f,0.13808f,-0.13199f,0.083142f,0.11196f,-0.10185f,0.12785f,0.26825f,0.10407f,-0.23629f,-0.014036f,0.16662f,-0.10852f,0.15528f,0.15074f,0.18512f,0.039849f,-0.20902f,0.014224f,0.09951f,-0.031164f,0.13906f,-0.038804f,-0.013846f,0.24987f,0.022987f,-0.061567f,0.052929f,-0.14228f,-0.2197f,0.24715f,-0.14415f,0.18369f,-0.073094f},
                                      {-0.29322f,-0.11974f,-0.227f,-0.24814f,0.0023414f,0.25538f,-0.26814f,-0.023638f,0.19789f,0.07409f,-0.33863f,-0.017231f,0.12769f,-0.091484f,-0.051557f,-0.17452f,-0.11413f,-0.23043f,0.088881f,0.070202f,-0.058478f,-0.086241f,0.083995f,-0.077682f,-0.051497f,-0.089166f,-0.21801f,-0.027214f,-0.15416f,0.069888f,-0.089385f,0.034343f,-0.11444f,0.10165f,-0.072598f,-0.090894f,-0.18622f,-0.13774f,0.078368f,-0.0065412f,-0.071715f,0.075927f,-0.38901f,0.24602f,-0.085825f,-0.332f,0.19248f,0.06657f,0.14899f,-0.357f,0.19537f,-0.055086f,-0.21277f,-0.16954f,0.040611f,-0.043467f,-0.14257f,-0.071525f,0.31973f,-0.040151f,0.15013f,-0.22242f,-0.17929f,-0.22895f,0.27877f,0.029592f,-0.19194f,0.17891f,0.25309f,-0.29002f,-0.11076f,-0.069426f,0.058718f,-0.066341f,0.11728f,0.11951f,-0.036615f,0.11785f,0.29879f,-0.27715f,0.010471f,-0.25352f,-0.10394f,0.062416f,-0.040405f,0.025133f,0.078544f,0.37892f,0.020936f,0.056512f,-0.19556f,-0.035538f,-0.013671f,-0.21556f,0.12726f,-0.018426f,-0.1514f,0.23047f,0.17385f,-0.047144f,-0.0095841f}
                                     };
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        if (timer3 == 1)
        {
            leftSpotLight.transform.position = new Vector3(leftSpotLight.transform.position.x, leftSpotLight.transform.position.y, -100f);
            rightSpotLight.transform.position = new Vector3(rightSpotLight.transform.position.x, rightSpotLight.transform.position.y, -100f);
        }

        if (MoveCar.speed == 80)
        {
            if (timer2 == 1)
            {
                speed_pre4 = Accelerate_v2.speed;
            }
            if (timer2 == 2)
            {
                speed_pre3 = Accelerate_v2.speed;
            }
            if (timer2 == 3)
            {
                speed_pre2 = Accelerate_v2.speed;
            }
            if (timer2 == 4)
            {
                speed_pre1 = Accelerate_v2.speed;
            }
            if (timer2 == 5)
            {
                speed = Accelerate_v2.speed;
                leftSpotLight.transform.position = new Vector3(leftSpotLight.transform.position.x, leftSpotLight.transform.position.y, avatar.position.z + 10f);
                rightSpotLight.transform.position = new Vector3(rightSpotLight.transform.position.x, rightSpotLight.transform.position.y, avatar.position.z + 10f);
            }
            if (timer == 10)
            {
                float[,] X = new float[,] { { speed - speed_pre2 },{ speedpreceding - speed_pre4 } };
                for (int i = 0; i <= 1; i++)
                {
                    for (int j = 0; j <= 100; j++)
                    {
                        speed += W[i, j] * Mathf.Exp( -(X[i,0]-R[i,j])* (X[i,0] - R[i, j]));
                    }
                }
                for (int j = 0; j <= 8; j++)
                {
                   SPEED[j] = SPEED[j + 1];
                }
                SPEED[9] = speed;
                speed_pre4 = speed_pre3;
                speed_pre3 = speed_pre2;
                speed_pre2 = speed_pre1;
                speed_pre1 = speedcar;
                speedcar = Accelerate_v2.speed;
                speedpreceding = MoveCar.speed;
                timer = 0;
            }
            if (timer2 >= 6)
            {
                leftSpotLight.transform.position = leftSpotLight.transform.position + new Vector3(0, 0, speed * Time.deltaTime / 3.6f);
                rightSpotLight.transform.position = rightSpotLight.transform.position + new Vector3(0, 0, speed * Time.deltaTime / 3.6f);
                speed_pre4 = speed_pre3;
                speed_pre3 = speed_pre2;
                speed_pre2 = speed_pre1;
                speed_pre1 = speedcar;
                speedcar = Accelerate_v2.speed;
                speedpreceding = MoveCar.speed;
                timer += 1;
            }

            timer2 += 1;

            if (Accelerate_v2.speed >= 80)
            {
                timer3 = 1;
            }
        }
        else
        {
            speed = Accelerate_v2.speed;
            speed_pre4 = speed;
            speed_pre3 = speed;
            speed_pre2 = speed;
            speed_pre1 = speed;
        }


    }
}
