﻿#if UNITY_EDITOR
using System.IO;
using System.Text;
using UnityEditor;
using UnityEditor.Android;

#if UNITY_ANDROID

public class GradleOnPost : IPostGenerateGradleAndroidProject
{
    public int callbackOrder { get; }

    public void OnPostGenerateGradleAndroidProject(string path)
    {
        UnityEngine.Debug.Log($"[Preprocess Multidex Android] OnPostGenerateGradleAndroidProject. Path: {path}");
        EditorUtility.RevealInFinder(path);
        string gradlePropertiesFile = path + "/../launcher/build.gradle";
        var gradleContentsSb = new StringBuilder();
        if (File.Exists(gradlePropertiesFile))
        {
            string gradlePropertiesContent = File.ReadAllText(gradlePropertiesFile);
            gradleContentsSb.Append(gradlePropertiesContent);
            File.Delete(gradlePropertiesFile);
        }

        StreamWriter writer = File.CreateText(gradlePropertiesFile);
        gradleContentsSb = gradleContentsSb.Replace("defaultConfig {", "defaultConfig {\n\t\tmultiDexEnabled=true");

        writer.Write(gradleContentsSb.ToString());
        writer.Flush();
        writer.Close();
        UnityEngine.Debug.LogFormat("[Preprocess Multidex Android] OnPostGenerateGradleAndroidProject. Final gradle.properties content:\n{0}", gradleContentsSb);
    }
}
#endif
#endif