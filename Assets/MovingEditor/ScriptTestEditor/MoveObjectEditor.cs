using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(MoveObject))]
public class MoveObjectEditor : Editor
{
    MoveObject m_MoveObject;
    private SerializedProperty m_MoveObjectTypeProperty;
    private SerializedProperty m_IsMovingAtStartProperty;
    private SerializedProperty m_StartMovingOnlyWhenVisibleProperty;
    private SerializedProperty m_PlatformSpeedProperty;
    private SerializedProperty m_PlatformNodesProperty;
    private SerializedProperty m_PlatformWaitTimeProperty;
    float m_PreviewPosition = 0;
    private void OnEnable()
    {
        m_PreviewPosition = 0;
        m_MoveObject = target as MoveObject;

        if (!EditorApplication.isPlayingOrWillChangePlaymode)
            MoveObjectPreview.CreateNewPreview(m_MoveObject);

        m_MoveObjectTypeProperty = serializedObject.FindProperty(nameof(m_MoveObject.moveType));
        m_IsMovingAtStartProperty = serializedObject.FindProperty(nameof(m_MoveObject.isMovingAtStart));
        m_StartMovingOnlyWhenVisibleProperty = serializedObject.FindProperty(nameof(m_MoveObject.startMovingOnlyWhenVisible));
        m_PlatformSpeedProperty = serializedObject.FindProperty(nameof(m_MoveObject.speed));
        m_PlatformNodesProperty = serializedObject.FindProperty(nameof(m_MoveObject.localNodes));
        m_PlatformWaitTimeProperty = serializedObject.FindProperty(nameof(m_MoveObject.waitTimes));
    }
    private void OnDisable()
    {
        MoveObjectPreview.DestroyPreview();
    }
    public override void OnInspectorGUI()
    {
        serializedObject.Update();

        EditorGUI.BeginChangeCheck();
        m_PreviewPosition = EditorGUILayout.Slider("Preview position", m_PreviewPosition, 0.0f, 1.0f);
        if (EditorGUI.EndChangeCheck())
        {
            MovePreview();
        }
        // make /n by separator
        EditorGUILayout.Separator();
        EditorGUILayout.Separator();

        EditorGUILayout.BeginVertical("box");
        EditorGUILayout.PropertyField(m_IsMovingAtStartProperty);

        if (m_IsMovingAtStartProperty.boolValue)
        {
            EditorGUI.indentLevel += 1;
            EditorGUILayout.PropertyField(m_StartMovingOnlyWhenVisibleProperty);
            EditorGUI.indentLevel -= 1;
        }
        EditorGUILayout.EndVertical();
        EditorGUILayout.PropertyField(m_MoveObjectTypeProperty);
        EditorGUILayout.PropertyField(m_PlatformSpeedProperty);

        EditorGUILayout.Separator();
        EditorGUILayout.Separator();

        if (GUILayout.Button("Add Node"))
        {
            // add node and set position first instantiate
            Undo.RecordObject(target, "added node");
            Vector3 position = m_MoveObject.localNodes[m_MoveObject.localNodes.Length - 1] + Vector3.right;

            int index = m_PlatformNodesProperty.arraySize;
            m_PlatformNodesProperty.InsertArrayElementAtIndex(index);
            m_PlatformNodesProperty.GetArrayElementAtIndex(index).vector3Value = position;

            m_PlatformWaitTimeProperty.InsertArrayElementAtIndex(index);
            m_PlatformWaitTimeProperty.GetArrayElementAtIndex(index).floatValue = 0;
        }
        // edit GUILayout for node be added
        EditorGUIUtility.labelWidth = 64;
        int delete = -1;
        for (int i = 0; i < m_MoveObject.localNodes.Length; ++i)
        {
            EditorGUI.BeginChangeCheck();

            EditorGUILayout.BeginHorizontal();
            int size = 64;
            // first vertical column is Node name and Button Deleted Node
            EditorGUILayout.BeginVertical(GUILayout.Width(size));

            EditorGUILayout.LabelField("Node " + i, GUILayout.Width(size));
            if (i != 0 && GUILayout.Button("Delete", GUILayout.Width(size)))
            {
                delete = i;
            }
            EditorGUILayout.EndVertical();

            // second vertical column is Variable of node as (Position, WaitTime)
            EditorGUILayout.BeginVertical();

            if (i != 0)
            {
                EditorGUILayout.PropertyField(m_PlatformNodesProperty.GetArrayElementAtIndex(i), new GUIContent("Pos"));
                EditorGUILayout.PropertyField(m_PlatformWaitTimeProperty.GetArrayElementAtIndex(i), new GUIContent("Wait Time"));
            }

            EditorGUILayout.EndVertical();
            EditorGUILayout.EndHorizontal();
        }
        EditorGUIUtility.labelWidth = 0;

        if (delete != -1)
        {
            m_PlatformNodesProperty.DeleteArrayElementAtIndex(delete);
            m_PlatformWaitTimeProperty.DeleteArrayElementAtIndex(delete);
        }

        serializedObject.ApplyModifiedProperties();

    }
    private void OnSceneGUI()
    {
        // Debug.Log("here will be called when mouse is on scene tab so it be using to update on mouse editor");
        MovePreview();
        for (int i = 0; i < m_MoveObject.localNodes.Length; ++i)
        {
            Vector3 worldPos;
            if (Application.isPlaying)
            {
                worldPos = m_MoveObject.worldNode[i];
            }
            else
            {
                worldPos = m_MoveObject.transform.TransformPoint(m_MoveObject.localNodes[i]);
            }


            Vector3 newWorld = worldPos;
            if (i != 0)
                newWorld = Handles.PositionHandle(worldPos, Quaternion.identity);

            Handles.color = Color.red;
            if (i == 0)
            {
                if (m_MoveObject.moveType != MoveObject.MovingType.LOOP)
                    continue;

                if (Application.isPlaying)
                {
                    Handles.DrawDottedLine(worldPos, m_MoveObject.worldNode[m_MoveObject.worldNode.Length - 1], 10);
                }
                else
                {
                    Handles.DrawDottedLine(worldPos, m_MoveObject.transform.TransformPoint(m_MoveObject.localNodes[m_MoveObject.localNodes.Length - 1]), 10);
                }
            }
            else
            {
                if (Application.isPlaying)
                {
                    Handles.DrawDottedLine(worldPos, m_MoveObject.worldNode[i - 1], 10);
                }
                else
                {
                    Handles.DrawDottedLine(worldPos, m_MoveObject.transform.TransformPoint(m_MoveObject.localNodes[i - 1]), 10);
                }

                if (worldPos != newWorld)
                {
                    Undo.RecordObject(target, "moved point");

                    m_PlatformNodesProperty.GetArrayElementAtIndex(i).vector3Value = m_MoveObject.transform.InverseTransformPoint(newWorld);
                    serializedObject.ApplyModifiedProperties();
                }
            }
        }
    }
    void MovePreview()
    {
        //compute pos from 0-1 preview pos
        if (Application.isPlaying)
            return;
        float step = 1.0f / (m_MoveObject.localNodes.Length - 1);

        int starting = Mathf.FloorToInt(m_PreviewPosition / step);

        if (starting > m_MoveObject.localNodes.Length - 2)
            return;
        float localRatio = (m_PreviewPosition - (step * starting)) / step;
        Vector3 localPos = Vector3.Lerp(m_MoveObject.localNodes[starting], m_MoveObject.localNodes[starting + 1], localRatio);

        MoveObjectPreview.preview.transform.position = m_MoveObject.transform.TransformPoint(localPos);

        SceneView.RepaintAll();
    }
}
