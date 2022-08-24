using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameManager : MonoBehaviour
{
    public static GameManager instance;
    private int is_day;

    public Material skybox_day;
    public Material skybox_night;
    public GameObject light_day;
    public GameObject light_night;
    public AudioSource audio_day;
    public AudioSource audio_night;

    void Awake(){
        instance = this;
        is_day = 0;
        audio_day.Play();
    }

    public void StickHold()
    {
        if(is_day == 0){
            audio_day.Stop();
            audio_night.Play();
            RenderSettings.skybox = skybox_night;
            RenderSettings.fogDensity = 0.08f;
            light_day.SetActive(false);
            light_night.SetActive(true);
        }
        is_day++;
    }

    public void StickRelease()
    {
        if(is_day > 0){
            audio_day.Play();
            audio_night.Stop();
            RenderSettings.skybox = skybox_day;
            RenderSettings.fogDensity = 0.01f;
            light_day.SetActive(true);
            light_night.SetActive(false);
        }
        is_day--;
    }
}
