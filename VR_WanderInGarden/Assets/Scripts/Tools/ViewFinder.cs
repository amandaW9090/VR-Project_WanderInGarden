using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;


public class ViewFinder : MonoBehaviour
{
    private MeshRenderer mr => GetComponent<MeshRenderer>();
    [SerializeField] private float distanceToPlayer;
    private bool showFinder;
    
    private Vector2 rectSize;
    private Rect rt;
    private Vector2 rtCorner=new Vector2();
    [SerializeField] private int photoMargin;
    public Transform photoBase;

    private void Start()
    {
        showFinder = false;
        mr.enabled = false;
        photoBase.gameObject.SetActive(false);
        
    }

    private void Update()
    {

        //to be replaced with VR button#
        if (Input.GetKeyDown(KeyCode.P))
        {
            showFinder = !showFinder;
            mr.enabled = showFinder;
            
        }

        //to be replaced with VR button#
        if (showFinder && Input.GetKeyDown(KeyCode.KeypadEnter))
            StartCoroutine("TakePhoto");
            
    }

    //private void Follow()
    //{
    //    transform.position = Camera.main.transform.position + Camera.main.transform.forward*distanceToPlayer;
    //}

    private IEnumerator TakePhoto()
    {
        if(GetVertices())
        {
            //玩家在拍照时不能自由移动#
            
            mr.enabled = false;
            Vector2 rectCenter = Camera.main.WorldToScreenPoint(transform.position);
            rt = new Rect(rtCorner, rectSize);
            Texture2D screenShot = new Texture2D((int)rt.width, (int)rt.height, TextureFormat.RGB24, false);

            yield return new WaitForEndOfFrame();
            screenShot.ReadPixels(rt, 0, 0,false);
            screenShot.Apply();

            photoBase.gameObject.SetActive(true);
            photoBase.position = rectCenter;

            Vector2 margin = new Vector2(photoMargin, photoMargin);
            photoBase.GetComponent<RectTransform>().sizeDelta = rectSize+2*margin;
            RawImage photo = photoBase.GetChild(0).GetComponent<RawImage>();
            if (photo!=null)
            {
                photo.gameObject.GetComponent<RectTransform>().offsetMin = margin;
                photo.gameObject.GetComponent<RectTransform>().offsetMax = -margin;
                photo.texture = screenShot;
            }

            //UI:照片下方出现button：discard/add to album

            //player can move around#
        }
    }

    /// <summary>
    /// get the screen position of finder's vertices
    /// </summary>
    /// <returns></returns>
    private bool GetVertices()
    {
        Mesh finderMesh= GetComponent<MeshFilter>().mesh;
        List<Vector3> screenPos = new List<Vector3>();
        for (int i = 0; i < finderMesh.vertices.Length; i++)
        {
            screenPos.Add(Camera.main.WorldToScreenPoint(finderMesh.vertices[i] + transform.position));
        }
        rectSize = new Vector2();
        rectSize.x = screenPos[1].x - screenPos[0].x;
        rectSize.y = screenPos[2].y - screenPos[0].y;
        //Debug.Log(rectSize.ToString());

        //whether this is a valid rect
        if(rectSize.x>0&&rectSize.y>0)
        {
            rtCorner = screenPos[0];
            return true;
        }
        return false;

    }

    /// <summary>
    /// change the size of finder
    /// </summary>
    private void SetPhotoSize()
    {
        //能否通过射线让玩家手动调整取景框四个顶点的位置#
    }
}
