
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using UnityEditor;
using UnityEngine;

[CustomPropertyDrawer(typeof(RangeAttribute))]
public class RangeDrawer : PropertyDrawer
{
    // Draw the property inside the given rect
    public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
    {
        // First get the attribute since it contains the range for the slider
        RangeAttribute range = attribute as RangeAttribute;

        // Now draw the property as a Slider or an IntSlider based on whether it's a float or integer.
        if (property.propertyType == SerializedPropertyType.Float)
            EditorGUI.Slider(position, property, range.min, range.max, label);
        else if (property.propertyType == SerializedPropertyType.Integer)
            EditorGUI.IntSlider(position, property, Convert.ToInt32(range.min), Convert.ToInt32(range.max), label);
        else
            EditorGUI.LabelField(position, label.text, "Use Range with float or int.");
    }
}
[CustomPropertyDrawer(typeof(TestAttribute))]
public class TestDrawer : PropertyDrawer
{
    public override float GetPropertyHeight(SerializedProperty property, GUIContent label)
    {
        // use the default property height, which takes into account the expanded state
        return EditorGUI.GetPropertyHeight(property);
    }
    // Draw the property inside the given rect
    public override void OnGUI(Rect position, SerializedProperty property, GUIContent label)
    {
        var boolRect = new Rect(position.x, position.y, 50, 20);
        var listRectPos = new Rect(position.x + 60, position.y, 300, 0);
        EditorGUI.PropertyField(boolRect, property.FindPropertyRelative("isGetSetLevel"), GUIContent.none);
        EditorGUI.PropertyField(listRectPos, property.FindPropertyRelative("testList"), label);
    }




    // public object GetParent(SerializedProperty prop)
    // {
    //     var path = prop.propertyPath.Replace(".Array.data[", "[");
    //     object obj = prop.serializedObject.targetObject;
    //     var elements = path.Split('.');
    //     foreach (var element in elements.Take(elements.Length - 1))
    //     {
    //         if (element.Contains("["))
    //         {
    //             var elementName = element.Substring(0, element.IndexOf("["));
    //             var index = Convert.ToInt32(element.Substring(element.IndexOf("[")).Replace("[", "").Replace("]", ""));
    //             obj = GetValue(obj, elementName, index);
    //         }
    //         else
    //         {
    //             obj = GetValue(obj, element);
    //         }
    //     }
    //     return obj;
    // }

    // public object GetValue(object source, string name)
    // {
    //     if (source == null)
    //         return null;
    //     var type = source.GetType();
    //     var f = type.GetField(name, BindingFlags.NonPublic | BindingFlags.Public | BindingFlags.Instance);
    //     if (f == null)
    //     {
    //         var p = type.GetProperty(name, BindingFlags.NonPublic | BindingFlags.Public | BindingFlags.Instance | BindingFlags.IgnoreCase);
    //         if (p == null)
    //             return null;
    //         return p.GetValue(source, null);
    //     }
    //     return f.GetValue(source);
    // }

    // public object GetValue(object source, string name, int index)
    // {
    //     var enumerable = GetValue(source, name) as IEnumerable;
    //     var enm = enumerable.GetEnumerator();
    //     while (index-- >= 0)
    //         enm.MoveNext();
    //     return enm.Current;
    // }
}

