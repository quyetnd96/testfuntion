
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(TestSeri))]
public class DrawSeri : Editor
{
    TestSeri TestSeri;
    SerializedProperty testClass;
    SerializedProperty testField;
    private void OnEnable()
    {
        TestSeri = target as TestSeri;
        testClass = serializedObject.FindProperty(nameof(TestSeri.isGetSetLevel));
        testField = serializedObject.FindProperty(nameof(TestSeri.field1));
    }
    public override void OnInspectorGUI()
    {
        serializedObject.Update();
        EditorGUILayout.BeginHorizontal();
        EditorGUILayout.PropertyField(testClass);
        EditorGUILayout.PropertyField(testField);
        EditorGUILayout.EndHorizontal();
        UpdateValueFieldByValueClass();
        serializedObject.ApplyModifiedProperties();
    }
    private void UpdateValueFieldByValueClass()
    {
        TestSeri.field1.isGetSetLevel = testClass.boolValue;
    }
}
