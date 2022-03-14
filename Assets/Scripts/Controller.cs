using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Controller : MonoBehaviour
{
    private bool first_frame = true;
    private int counter = 0;
    // Start is called before the first frame update
    void Awake()
    {
       
    }

    // Update is called once per frame
    void Update()
    {
        counter += 1;
        

        if (transform.localEulerAngles.x != 0 && first_frame)
        {
            //print(transform.localEulerAngles.x);
            

            first_frame = false;
        }
        
    }

    //---------------------------------------


    //コントローラーを振動させる処理


    //time: 振動させる秒数


    //---------------------------------------


    IEnumerator Vivration(float time)
    {


        //握られているコントローラーを検出


        //var activeController = OVRInput.GetActiveController();


        //振動させる


        OVRInput.SetControllerVibration(0.51f, 0.51f, OVRInput.Controller.RTouch);


        //振動を止めるまで待機


        yield return new WaitForSeconds(time);


        //振動を止める


        OVRInput.SetControllerVibration(0, 0, OVRInput.Controller.RTouch);


    }
}
