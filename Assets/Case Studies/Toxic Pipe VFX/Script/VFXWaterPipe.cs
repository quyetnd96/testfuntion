using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VFXWaterPipe : MonoBehaviour
{
    public GameObject _water;
    public GameObject _pipe;
    private Renderer _rend;
    private Vector3 _newPos;
    private Vector3 _oldPos;
    private float x;
    private float z;

    Vector3 movement;

    // Start is called before the first frame update
    void Start()
    {
        if(_water) 
        {
            _rend = _water.GetComponent<Renderer>();
        }

        if(_pipe)
        {
            _oldPos = _pipe.transform.position;
            _newPos = _oldPos;
        }        
    }    

    // Update is called once per frame
    void Update()
    {
        if(_water && _pipe)
        {
            z = Input.GetAxis("Vertical") * 10 * Time.deltaTime;
            x = Input.GetAxis("Horizontal") * 10 * Time.deltaTime;  

            _pipe.transform.position = new Vector3(
                Mathf.Clamp(_pipe.transform.position.x + x, -4, 4), 
                _pipe.transform.position.y, 
                Mathf.Clamp(_pipe.transform.position.z + z, -4, 4));
                                 

            _oldPos = _pipe.transform.position;            

            if(_oldPos != _newPos)
            {                
                _rend.material.SetFloat("_CU", -(_pipe.transform.position.x / 10) + 0.5f);
                _rend.material.SetFloat("_CV", -(_pipe.transform.position.z / 10) + 0.5f);
            }   

            _newPos = _oldPos;                   
        }        
    }
}
