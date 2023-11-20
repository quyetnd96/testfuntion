using UnityEditor;
using UnityEngine;

// IngredientDrawer
[CustomPropertyDrawer(typeof(Ingredient))]
public class IngredientDrawer : PropertyDrawer
{
    // Draw the property inside the given rect
    public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
    {
        // Using BeginProperty / EndProperty on the parent property means that
        // prefab override logic works on the entire property.
        EditorGUI.BeginProperty(position, label, property);

        // Draw label
        position = EditorGUI.PrefixLabel(position, GUIUtility.GetControlID(FocusType.Passive), label);

        // Don't make child fields be indented
        var indent = EditorGUI.indentLevel;
        EditorGUI.indentLevel = 0;

        // Calculate rects
        var nameRect = new Rect(position.x, position.y, 70, position.height);
        var boolRect = new Rect(position.x + 165, position.y, 10, position.height);
        // Draw fields - pass GUIContent.none to each so they are drawn without labels
        // EditorGUI.PropertyField(amountRect, property.FindPropertyRelative("amount"), GUIContent.none);
        // EditorGUI.PropertyField(unitRect, property.FindPropertyRelative("unit"), GUIContent.none);
        EditorGUI.PropertyField(nameRect, property.FindPropertyRelative("test"), GUIContent.none);
        EditorGUI.PropertyField(boolRect, property.FindPropertyRelative("isGetSetLevel"), GUIContent.none);




        // Set indent back to what it was
        EditorGUI.indentLevel = indent;

        EditorGUI.EndProperty();
    }
}