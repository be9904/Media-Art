using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnvironmnetManager : MonoBehaviour
{
    public static EnvironmnetManager instance;

    public GameObject[] Walls;
    public GameObject Floor;

    public Material blackMat;
    public Material mtrl_wall;
    public Material mtrl_floor;

    public bool isReturn=false;

    private void Awake()
    {
        instance = this;
    }
        // Start is called before the first frame update
    void Start()
    {
        for(int i = 0; i < 5; i++)
        {
            Walls[i].GetComponent<Renderer>().material = blackMat;
        }
        Floor.GetComponent<Renderer>().material = blackMat;
    }

    public void MatChange()
    {
        for (int i = 0; i < 5; i++)
        {
            Walls[i].GetComponent<Renderer>().material = mtrl_wall;
        }
        Floor.GetComponent<Renderer>().material = mtrl_floor;
    }

    private void Update()
    {
        if (isReturn)
        {
            //나중에는 천천히 돌아오는 연출으로 진화시키기: 쉐이더에 컬러 add 항 넣고, 컴포넌트 받아와서 1을 빼 준다..!
            for (int i = 0; i < 5; i++)
            {
                Walls[i].GetComponent<Renderer>().material = blackMat;
            }
            Floor.GetComponent<Renderer>().material = blackMat;
        }
    }
}
