using System.Collections.Generic;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;
using UnityEngine.UIElements;


// Create a new type of Settings Asset.
class SettingsManager : ScriptableObject
{
    public static string k_MyCustomSettingsPath = "Assets/Water2D/Settings.asset";

    [SerializeField]
    private string w2d_version;

    [SerializeField]
    private int w2d_Metaball_layer;

    [SerializeField]
    private int w2d_Background_layer;

    [SerializeField]
    private LayerMask w2d_Metaball_collision_layermask;

    [SerializeField]
    private bool w2d_FlipCameraTexture;

    [SerializeField]
    private int SampleID; 

    static SettingsManager settings;

    internal static SettingsManager GetOrCreateSettings()
    {
        string tmp;
        k_MyCustomSettingsPath = Water2D.CoreUtils.MainPath() + "Core/Editor/Settings/Settings.asset";
        settings = AssetDatabase.LoadAssetAtPath<SettingsManager>(k_MyCustomSettingsPath);
        if (settings == null)
        {
            settings = ScriptableObject.CreateInstance<SettingsManager>();
            settings.w2d_version = "1.0.0";
            tmp = settings.w2d_version;

            int metaLayer = CreateLayer("Water");
            settings.w2d_Metaball_layer = metaLayer;

            int backLayer = CreateLayer("Background");
            settings.w2d_Background_layer = backLayer;

            settings.w2d_Metaball_collision_layermask = 1;

            settings.w2d_FlipCameraTexture = false;
            tmp = settings.w2d_FlipCameraTexture.ToString();

            settings.SampleID = 2; // 128x128

            AssetDatabase.CreateAsset(settings, k_MyCustomSettingsPath);
            AssetDatabase.SaveAssets();
        }
        else
        {
            // try to create layer background
            int backLayer = CreateLayer("Background");
            settings.w2d_Background_layer = backLayer;
        }
        return settings;
    }

    internal static SerializedObject GetSerializedSettings()
    {
        return new SerializedObject(GetOrCreateSettings());
    }

    public static int CreateLayer(string name)
    {
        if (string.IsNullOrEmpty(name))
            throw new System.ArgumentNullException(name, "New layer name string is either null or empty.");

        var tagManager = new SerializedObject(AssetDatabase.LoadAllAssetsAtPath("ProjectSettings/TagManager.asset")[0]);
        var layerProps = tagManager.FindProperty("layers");
        var propCount = layerProps.arraySize;
        int id = -1;
        SerializedProperty firstEmptyProp = null;

        for (var i = 0; i < propCount; i++)
        {
            var layerProp = layerProps.GetArrayElementAtIndex(i);

            var stringValue = layerProp.stringValue;

            if (stringValue == name) return i;

            if (i < 8 || stringValue != string.Empty) continue;

            if (firstEmptyProp == null)
            {
                firstEmptyProp = layerProp;
                id = i;
            }
        }

        if (firstEmptyProp == null)
        {
            UnityEngine.Debug.LogError("Maximum limit of " + propCount + " layers exceeded. Layer \"" + name + "\" not created.");
            return -1;
        }

        firstEmptyProp.stringValue = name;
        tagManager.ApplyModifiedProperties();
        return id;
    }

    public static string GetVersionString()
    {
        if (settings == null)
            GetOrCreateSettings();

        return settings.w2d_version;
    }

}




// Create MyCustomSettingsProvider by deriving from SettingsProvider:
class MyCustomSettingsProvider : SettingsProvider
{
    private SerializedObject m_CustomSettings;
    int selectableLayerFieldMetaball;
    int selectableLayerFieldBackground;
    int selectableLayerMaskFieldMetaballCollision;
    bool toggleFlipCameraTex;
    bool activeBtn = true;
    int currentID_sampleSize;




    static string k_MyCustomSettingsPath = "";// "Assets/Water2D/Settings.asset";
    public MyCustomSettingsProvider(string path, SettingsScope scope = SettingsScope.User)
        : base(path, scope) { }

    public static bool IsSettingsAvailable()
    {
        k_MyCustomSettingsPath = Water2D.CoreUtils.MainPath() + "Core/Editor/Settings/Settings.asset";
        return File.Exists(k_MyCustomSettingsPath);
    }

    public override void OnActivate(string searchContext, VisualElement rootElement)
    {
        // This function is called when the user clicks on the MyCustom element in the Settings window.
        m_CustomSettings = SettingsManager.GetSerializedSettings();
        selectableLayerFieldMetaball = AssetUtility.LoadPropertyAsInt("w2d_Metaball_layer", m_CustomSettings);
        selectableLayerFieldBackground = AssetUtility.LoadPropertyAsInt("w2d_Background_layer", m_CustomSettings);
        selectableLayerMaskFieldMetaballCollision = AssetUtility.LoadPropertyAsInt("w2d_Metaball_collision_layermask", m_CustomSettings);
        toggleFlipCameraTex = AssetUtility.LoadPropertyAsBool("w2d_FlipCameraTexture", m_CustomSettings);
        currentID_sampleSize = AssetUtility.LoadPropertyAsInt("SampleID", m_CustomSettings);
        
    }

    bool _lastCameraFlipState;

    // Advance setup // Optimizations
    enum SampleSizeEnum
    {
        size_32x32,
        size_64x64,
        size_128x128,
        size_256x256,
        size_512x512,
        size_1024X1024,
        size_2048x2048
    };

    /// <summary>
    /// is the size in pixels of texture generated procedurally to pass to the shader effect. Try to stay low in
    /// size to get better performance. On mobile devices is recommended do not exceed 128 pixels. However, if
    /// the quality is most valuable for you, you may set higher dimensions.
    /// </summary>
    SampleSizeEnum sampleSize;


    public override void OnGUI(string searchContext)
    {
        //GUI.enabled = false;
        EditorGUILayout.HelpBox("Water 2D PRO v" + m_CustomSettings.FindProperty("w2d_version").stringValue, MessageType.None);
        //EditorGUILayout.PropertyField(m_CustomSettings.FindProperty("w2d_version"), new GUIContent("Version"));
        //GUI.enabled = true;
        EditorGUILayout.BeginVertical("Box");

        int metaballLayerID = EditorGUILayout.LayerField("Metaball Layer", AssetUtility.LoadPropertyAsInt("w2d_Metaball_layer", m_CustomSettings));
        AssetUtility.SaveProperty("w2d_Metaball_layer", metaballLayerID, m_CustomSettings);

        int backLayerID = EditorGUILayout.LayerField("Background Layer", AssetUtility.LoadPropertyAsInt("w2d_Background_layer", m_CustomSettings));
        AssetUtility.SaveProperty("w2d_Background_layer", backLayerID, m_CustomSettings);
        EditorGUILayout.EndVertical();

        EditorGUILayout.Space();
        EditorGUILayout.Space();

        EditorGUILayout.BeginVertical("Box");
        EditorGUILayout.BeginVertical("Box");
        GUI.enabled = activeBtn;
        if (GUILayout.Button("Flip Patch"))
        {
            Water2D.FlipPatcher.TryToPatch();
            activeBtn = false;
        }
        GUI.enabled = true;
        EditorGUILayout.HelpBox("This patch try to fix the output render in Editor and Builds when texture is inverted. \nShould be use in conjunction with 'Flip Camera Texture' below.", MessageType.None);

        EditorGUILayout.EndVertical();

        toggleFlipCameraTex = EditorGUILayout.Toggle("Flip Camera Texture", toggleFlipCameraTex);
        AssetUtility.SaveProperty("w2d_FlipCameraTexture", toggleFlipCameraTex, m_CustomSettings);
        GUI.color = Color.gray;
        EditorGUILayout.HelpBox("'Flip Camera Texture' will Force to reverse manually the output.", MessageType.None);

        if (toggleFlipCameraTex != _lastCameraFlipState)
        {
            _lastCameraFlipState = toggleFlipCameraTex;
            UnityEditor.EditorPrefs.SetBool("_flipTexEditor", toggleFlipCameraTex);
            if (ResizeQuadEffectController.instance != null)
                ResizeQuadEffectController.instance.RebuildRenderTexturesAll();
        }
        EditorGUILayout.EndVertical();

        EditorGUILayout.Space();
        EditorGUILayout.Space();

        GUI.color = Color.white;
        EditorGUILayout.BeginVertical("Box");
        EditorGUILayout.LabelField("Sample texture size");
        SampleSizeEnum sEnum = (SampleSizeEnum) currentID_sampleSize;
        sEnum = (SampleSizeEnum)EditorGUILayout.EnumPopup("", sEnum, EditorStyles.miniButton);
        EditorGUILayout.HelpBox("The size in pixels of the final render texture generated by the camera. For mobiles devices you should not exceed 128x128.", MessageType.None);

        EditorGUILayout.EndVertical();


        if (currentID_sampleSize != (int)sEnum)
            currentID_sampleSize = (int)sEnum;

        AssetUtility.SaveProperty("SampleID", currentID_sampleSize, m_CustomSettings);
        UnityEditor.EditorPrefs.SetInt("SampleID", currentID_sampleSize);


        int _size = 0;
        switch ((int)currentID_sampleSize)
        {
            case 0:
                _size = 32;
                break;

            case 1:
                _size = 64;
                break;

            case 2:
                _size = 128;
                break;

            case 3:
                _size = 512;
                break;

            case 4:
                _size = 1024;
                break;

            case 5:
                _size = 2048;
                break;

            default:
                break;
        }


        ResizeQuadEffectController.RebuildTextures();
        

    }

    // Register the SettingsProvider
    [SettingsProvider]
    public static SettingsProvider CreateMyCustomSettingsProvider()
    {
        if (IsSettingsAvailable())
        {
            var provider = new MyCustomSettingsProvider("Project/Water2D", SettingsScope.Project);

            // Automatically extract all keywords from the Styles.
            //provider.keywords = GetSearchKeywordsFromGUIContentProperties<Styles>();
            return provider;
        }

        // Settings Asset doesn't exist yet; no need to display anything in the Settings window.
        return null;
    }
}