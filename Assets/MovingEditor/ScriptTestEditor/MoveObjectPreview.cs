using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class MoveObjectPreview : MonoBehaviour
{
    static public MoveObjectPreview s_Preview = null;
    static public GameObject preview;
    static protected MoveObject movingObject;
    static MoveObjectPreview()
    {
        Selection.selectionChanged += SelectionChanged;
    }
    static public void CreateNewPreview(MoveObject origin)
    {
        // Debug.Log("here will create preview ever you have behaviour with object call editor");
        if (preview != null)
        {
            Object.DestroyImmediate(preview);
        }
        movingObject = origin;
        preview = Object.Instantiate(origin.gameObject);
        preview.hideFlags = HideFlags.DontSave;
        MoveObject plt = preview.GetComponentInChildren<MoveObject>();
        Object.DestroyImmediate(plt);
        Color c = new Color(0.2f, 0.2f, 0.2f, 0.4f);
        SpriteRenderer[] rends = preview.GetComponentsInChildren<SpriteRenderer>();
        for (int i = 0; i < rends.Length; ++i)
            rends[i].color = c;

    }
    static public void DestroyPreview()
    {
        if (preview == null)
            return;

        Object.DestroyImmediate(preview);
        preview = null;
        movingObject = null;
    }
    static void SelectionChanged()
    {
        // if select other gameobject => need destroy preview
        if (movingObject != null && Selection.activeGameObject != movingObject.gameObject)
        {
            DestroyPreview();
        }
    }

}
