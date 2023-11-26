using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(MonoClass))]
public class DrawMonoClass : Editor
{
    private void OnEnable()
    {

    }
    public override void OnInspectorGUI()
    {
        serializedObject.Update();
        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.PropertyField(serializedObject.FindProperty("child").FindPropertyRelative("boolVari"));
        EditorGUILayout.PropertyField(serializedObject.FindProperty("child"));
        EditorGUILayout.EndHorizontal();
        serializedObject.ApplyModifiedProperties();
    }
}
