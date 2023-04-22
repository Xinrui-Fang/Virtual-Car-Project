using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MoveLightMPCRBF : MonoBehaviour
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

    public static float speedcar = 80;
    public static float speedpreceding = 80;
    public static float positionpreceding = 10;
    public static float positioncar = 0;

    public static float timer = 0;
    public static float timer2 = 0;
    private static float timer3 = 0;

    private float distance = 20 * 61;
    // Start is called before the first frame update

    private float[,] R = new float[,]{
                                      {0f,0.1f,0.2f,0.3f,0.4f,0.5f,0.6f,0.7f,0.8f,0.9f,1f,1.1f,1.2f,1.3f,1.4f,1.5f,1.6f,1.7f,1.8f,1.9f,2f,2.1f,2.2f,2.3f,2.4f,2.5f,2.6f,2.7f,2.8f,2.9f,3f,3.1f,3.2f,3.3f,3.4f,3.5f,3.6f,3.7f,3.8f,3.9f,4f,4.1f,4.2f,4.3f,4.4f,4.5f,4.6f,4.7f,4.8f,4.9f,5f,5.1f,5.2f,5.3f,5.4f,5.5f,5.6f,5.7f,5.8f,5.9f,6f,6.1f,6.2f,6.3f,6.4f,6.5f,6.6f,6.7f,6.8f,6.9f,7f,7.1f,7.2f,7.3f,7.4f,7.5f,7.6f,7.7f,7.8f,7.9f,8f,8.1f,8.2f,8.3f,8.4f,8.5f,8.6f,8.7f,8.8f,8.9f,9f,9.1f,9.2f,9.3f,9.4f,9.5f,9.6f,9.7f,9.8f,9.9f,10f },
                                      {0f,0.1f,0.2f,0.3f,0.4f,0.5f,0.6f,0.7f,0.8f,0.9f,1f,1.1f,1.2f,1.3f,1.4f,1.5f,1.6f,1.7f,1.8f,1.9f,2f,2.1f,2.2f,2.3f,2.4f,2.5f,2.6f,2.7f,2.8f,2.9f,3f,3.1f,3.2f,3.3f,3.4f,3.5f,3.6f,3.7f,3.8f,3.9f,4f,4.1f,4.2f,4.3f,4.4f,4.5f,4.6f,4.7f,4.8f,4.9f,5f,5.1f,5.2f,5.3f,5.4f,5.5f,5.6f,5.7f,5.8f,5.9f,6f,6.1f,6.2f,6.3f,6.4f,6.5f,6.6f,6.7f,6.8f,6.9f,7f,7.1f,7.2f,7.3f,7.4f,7.5f,7.6f,7.7f,7.8f,7.9f,8f,8.1f,8.2f,8.3f,8.4f,8.5f,8.6f,8.7f,8.8f,8.9f,9f,9.1f,9.2f,9.3f,9.4f,9.5f,9.6f,9.7f,9.8f,9.9f,10f }
                                     };
    private float[,] W = new float[,]{
                                      { -0.011253f,0.012265f,-0.081878f,0.30568f,0.00062507f,0.29555f,0.40348f,0.040949f,-0.30028f,-0.069369f,0.09396f,-0.046677f,-0.031692f,-0.16402f,0.12704f,0.051248f,0.26566f,-0.36232f,0.35083f,0.26169f,0.28088f,-0.12358f,-0.18399f,0.064024f,-0.034351f,-0.21392f,0.054375f,-0.0008444f,0.45201f,0.14226f,0.019613f,-0.11341f,0.02125f,-0.00397f,-0.25149f,0.15151f,0.013401f,0.15541f,0.035043f,0.076662f,0.29775f,0.25489f,0.069817f,-0.25927f,-0.10006f,-0.47457f,0.12477f,0.0048218f,0.12287f,0.35871f,0.26587f,0.26906f,0.16234f,-0.011024f,-0.21362f,-0.12182f,-0.34828f,-0.050932f,-0.07173f,0.28646f,0.13637f,0.26321f,0.21148f,-0.040593f,-0.10902f,0.1244f,-0.043581f,0.12721f,0.12558f,0.0054951f,0.029367f,0.078487f,-0.46956f,-0.12902f,0.29742f,0.2968f,0.074514f,0.26758f,0.013487f,0.035728f,0.14244f,-0.12609f,0.037416f,-0.1944f,-0.00066573f,-0.035123f,-0.043024f,0.054476f,0.067797f,0.43795f,-0.021311f,0.062514f,0.112f,-0.00094943f,-0.098541f,0.083751f,-0.33859f,0.0296f,0.066203f,-0.22743f,0.68587f },
                                      {-0.6034f,0.13669f,-0.24783f,0.05355f,-0.42985f,0.089117f,-0.022445f,0.068189f,0.5187f,-0.086106f,-0.06839f,-0.21803f,-0.10265f,0.073589f,-0.33864f,0.093026f,0.060599f,-0.057745f,-0.097905f,-0.38401f,-0.11819f,0.31459f,0.009101f,-0.11984f,-0.26341f,0.21432f,-0.028925f,-0.3263f,0.16517f,0.013369f,-0.13869f,0.14547f,-0.17347f,0.026645f,-0.2183f,0.046154f,0.15179f,-0.23527f,-0.089156f,-0.013368f,-0.17113f,-0.10811f,-0.047204f,-0.064678f,-0.026098f,-0.040649f,-0.16942f,-0.2352f,0.4119f,0.38076f,0.010985f,-0.20486f,-0.090387f,-0.26549f,-0.0094386f,-0.2143f,-0.17107f,-0.092779f,-0.019518f,0.20038f,-0.1636f,-0.099036f,0.18626f,0.30633f,0.020014f,0.084146f,-0.26587f,-0.24628f,-0.11552f,-0.22316f,0.16577f,0.13558f,0.23173f,-0.08604f,0.1487f,-0.032612f,0.031692f,-0.25059f,-0.17752f,0.11068f,0.19942f,-0.12682f,0.18053f,0.20345f,0.12229f,-0.53551f,0.22552f,-0.19868f,0.13468f,-0.12758f,-0.010342f,-0.039243f,0.13186f,0.32078f,0.10999f,-0.22801f,-0.19452f,-0.24381f,0.21559f,0.054813f,0.31093f }
                                     };

    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        if (timer3 == 1)
        {
            leftSpotLight.transform.position = new Vector3(leftSpotLight.transform.position.x, leftSpotLight.transform.position.y, 0f);
            rightSpotLight.transform.position = new Vector3(rightSpotLight.transform.position.x, rightSpotLight.transform.position.y, 0f);
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
                    for (int j = 0; j <= 20; j++)
                    {
                        speed += W[i, j] * Mathf.Exp( -(X[i,0]-R[i,j])* (X[i,0] - R[i, j]));
                    }
                }
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
