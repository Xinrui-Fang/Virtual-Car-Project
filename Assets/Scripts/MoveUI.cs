using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class MoveUI : MonoBehaviour
{
    public Transform User;
    public Transform UI;
    public Text Speed_panel;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        //print(UI.position);
        //UI.position.z = User.position.z + 1f;
        UI.position = User.position + new Vector3(0, 0, 1f);
        Speed_panel.text = "My current speed";
    }
}
