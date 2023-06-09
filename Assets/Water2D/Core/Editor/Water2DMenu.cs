namespace Water2D
{
	using UnityEngine;
	using UnityEditor;
    using UnityEngine.Rendering;
    using System.Collections;
    using Apptouch;

    public class DynamicWSpawnerMenu : Editor
    {

        static internal Water2D.Water2D_Spawner WSpawner;
        const string menuPathMain = "GameObject/Water2D PRO";
        const string menuPath = menuPathMain + "/Spawner";
        const string menuPathFiller = menuPathMain + "/Filler";
       

        SerializedObject tmpAsset;

        private static string _path;

        internal void OnEnable()
        {
            WSpawner = target as Water2D.Water2D_Spawner;
            if (_path == null) _path = EditorUtils.getMainRelativepath();

        }


        


        [MenuItem(menuPath + "/Regular Water", false, 10)]
        static void AddRegular()
        {
            FindAndDeactiveMainCamera();
            AddRegularSpawnerLegacy();
           
        }


        [MenuItem(menuPath + "/Toon Water", false, 11)]
        static void AddToon()
        {
            FindAndDeactiveMainCamera();
            Water2D_Spawner _spw = AddRegularSpawnerLegacy();
            _spw.Water2DType = Water2D_Spawner.EnumTypes.Toon;

        }

        [MenuItem(menuPath + "/Refracting Water", false, 12)]
        static void AddRefract()
        {
            FindAndDeactiveMainCamera();
            Water2D_Spawner _spw = AddRegularSpawnerLegacy();
            _spw.Water2DType = Water2D_Spawner.EnumTypes.Refracting;
            _spw.Distortion = 3f;
            _spw.DistortionSpeed = 5f;
           
        }

        [MenuItem(menuPath + "/Glossy Water", false, 12)]
        static void AddGlossy()
        {
            FindAndDeactiveMainCamera();
            Water2D_Spawner _spw = AddRegularSpawnerLegacy();
            _spw.Water2DType = Water2D_Spawner.EnumTypes.Glossy;
            _spw.StrokeColor = _spw.FillColor;
            _spw.AlphaStroke = 1.3f;
            _spw.GlossOffset = 1.7f;
         }

        [MenuItem(menuPath + "/Glossy Refracting", false, 12)]
        static void AddGlossyRefract()
        {
            FindAndDeactiveMainCamera();
            Water2D_Spawner _spw = AddRegularSpawnerLegacy();
            _spw.Water2DType = Water2D_Spawner.EnumTypes.Refract_Glossy;
            _spw.StrokeColor = _spw.FillColor;
            _spw.StrokeColor.a = 1f;
            _spw.AlphaStroke = 1.3f;
            _spw.GlossOffset = 1.7f;
            _spw.Intensity = 1.44f;
            SpawnersManager.CleanSceneCache();

        }


        [MenuItem(menuPath + "/Slime", false, 24)]
        static void AddSlime()
        {
            FindAndDeactiveMainCamera();

            Water2D_Spawner _spw = AddRegularSpawnerLegacy();
            _spw.Water2DType = Water2D_Spawner.EnumTypes.Refracting;
            _spw.Intensity = .6f;
            _spw.Distortion = .25f;
            _spw.Speed = 9f;
            _spw.size = 3.7f;
            _spw.TrailStartSize = 0f;
            _spw.LinearDrag = 1.7f;
            _spw.AngularDrag = 3.6f;
            _spw.GravityScale = .7f;
            _spw.ColliderSize = 0.025f;
            _spw.ScaleDown = true;
            _spw.LifeTime = 20f;
            SpawnersManager.CleanSceneCache();
        }

        [MenuItem(menuPath + "/Oil", false, 25)]
        static void AddOil()
        {
            FindAndDeactiveMainCamera();
            Water2D_Spawner _spw = AddRegularSpawnerLegacy();
            _spw.Water2DType = Water2D_Spawner.EnumTypes.Regular;

            _spw.DropCount = 180;
            _spw._lastDropCount = 180;
            _spw.AlphaCutOff = .4f;
            _spw.AlphaStroke = 4f;
            _spw.FillColor = new Color(41 / 255f, 41 / 255f, 41 / 255f, 128 / 255f);
            _spw.StrokeColor = new Color(0f, 0f, 0f, 1f);
            _spw.Speed = 15f;
            _spw.size = 3.7f;
            _spw.DelayBetweenParticles = 0.012f;
            _spw.TrailStartSize = 0f;
            _spw.LinearDrag = 2f;
            _spw.AngularDrag = 5f;
            _spw.GravityScale = .7f;
            _spw.ColliderSize = 0.025f;

            _spw.transform.name = "Oil2D";
            SpawnersManager.CleanSceneCache();
        }

        [MenuItem(menuPath + "/Bouncy Water", false, 26)]
        static void AddBouncyWater()
        {
            FindAndDeactiveMainCamera();
            Water2D_Spawner _spw = AddRegularSpawnerLegacy();
            _spw.Water2DType = Water2D_Spawner.EnumTypes.Regular;

            PhysicsMaterial2D pm = AssetDatabase.LoadAssetAtPath(_path + "Physics Materials/Bouncy Water.PhysicsMaterial2D", typeof(PhysicsMaterial2D)) as PhysicsMaterial2D;
            _spw.DropCount = 180;
            _spw._lastDropCount = 180;
            _spw.AlphaCutOff = .4f;
            _spw.AlphaStroke = 4f;
            _spw.FillColor = new Color(0f, 112 / 255f, 1f, .5f);
            _spw.StrokeColor = new Color(175 / 255f, 224 / 255f, .8f, .95f);
            _spw.Speed = 9f;
            _spw.size = 3.7f;
            _spw.DelayBetweenParticles = 0.012f;
            _spw.TrailStartSize = 0f;
            _spw.ColliderSize = 0.025f;
            _spw.PhysicMat = pm;
            SpawnersManager.CleanSceneCache();
        }

        [MenuItem(menuPathMain + "/Extras/Add Cameras", false, 37)]
        static void AddCameras()
        {
            FindAndDeactiveMainCamera();
            addCameras();

        }

        [MenuItem(menuPathMain + "/Extras/Clean Scene cache", false, 38)]
        static void CleanScene()
        {
            SpawnersManager.CleanSceneCache();

        }


        [MenuItem(menuPathFiller + "/Regular Water", false, 12)]
        static void AddBoxFiller()
        {
            FindAndDeactiveMainCamera();
            //AddRegularFiller();

            Water2D_Spawner _spw = AddRegularSpawnerLegacy();
            _spw.Water2DType = Water2D_Spawner.EnumTypes.Regular;

            _spw.Water2DEmissionType = Water2D_Spawner.EmissionType.FillerCollider;
            ColliderFiller cf = _spw.gameObject.AddComponent<ColliderFiller>();
            cf.water2D_Spawner = _spw;
            cf.collider = _spw.gameObject.AddComponent<BoxCollider2D>();
            cf.collider.isTrigger = true;
            cf.Refresh();
            cf.Fill();

            DestroyImmediate(_spw.transform.Find("Pipe(Clone)").gameObject);

        }

       

        static void FindAndDeactiveMainCamera()
        {
            GameObject cam = GameObject.FindGameObjectWithTag("MainCamera");
            if (cam && cam.name != "2-DefaultCamera") cam.SetActive(false);
        }





        static Water2D_Spawner AddRegularSpawnerLegacy()
        {
            if (_path == null) _path = EditorUtils.getMainRelativepath();

            Material m = AssetDatabase.LoadAssetAtPath(_path + "Materials/WaterRegularCutOut.mat", typeof(Material)) as Material;
            Object dropObj = AssetDatabase.LoadAssetAtPath(_path + "Prefabs/WaterDrop.prefab", typeof(Object)) as Object;
            Object pipeObj = AssetDatabase.LoadAssetAtPath(_path + "Prefabs/Pipe.prefab", typeof(Object)) as Object;
            GameObject waterGO = new GameObject("Water2D");
            waterGO.transform.position = getCameraPos();
            waterGO.transform.localEulerAngles = new Vector3(0, 0, 170f);

            //Pipe
            GameObject pipe = (GameObject)Instantiate(pipeObj);
            pipe.transform.SetParent(waterGO.transform);
            pipe.transform.localPosition = new Vector3(0, 1, 0);
            pipe.transform.localEulerAngles = new Vector3(0, 0, 0);
            pipe.transform.Find("ToonBadge").gameObject.SetActive(false);


            Water2D_Spawner _instanceW2D = waterGO.AddComponent<Water2D_Spawner>();
            _instanceW2D.Water2DVersion = SettingsManager.GetVersionString();
            _instanceW2D.Water2DType = Water2D_Spawner.EnumTypes.Regular;
            _instanceW2D.Water2DRenderType = "Legacy";
            _instanceW2D.DropObject = (GameObject)dropObj;


            SerializedObject m_CustomSettings = SettingsManager.GetSerializedSettings();
            int metaballLayer = AssetUtility.LoadPropertyAsInt("w2d_Metaball_layer", m_CustomSettings);
            int backgroundLayer = AssetUtility.LoadPropertyAsInt("w2d_Background_layer", m_CustomSettings);
            bool flipTex = AssetUtility.LoadPropertyAsBool("w2d_FlipCameraTexture", m_CustomSettings);
            _instanceW2D.DropObject.layer = metaballLayer;

            _instanceW2D.DropCount = 100;
            _instanceW2D._lastDropCount = 100;
            _instanceW2D.WaterMaterial = m;
            _instanceW2D.AlphaCutOff = .4f;
            _instanceW2D.AlphaStroke = 4f;
            _instanceW2D.FillColor = new Color(0f, 112 / 255f, 1f, .5f);
            _instanceW2D.StrokeColor = new Color(1f, 1f, 1f, 221/255f);
            _instanceW2D.Speed = 9f;
            _instanceW2D.size = 3.7f;
            _instanceW2D.DelayBetweenParticles = 0.012f;
            _instanceW2D.TrailStartSize = 0f;
            _instanceW2D.ColliderSize = 0.025f;

            addCameras();

            // Register to Spawners manager
            // SpawnersManager.ChangeSpawnerValues(_instanceW2D);

            return _instanceW2D;

        }


        static void addCameras()
        {

            if (_path == null) _path = EditorUtils.getMainRelativepath();

            Material m = AssetDatabase.LoadAssetAtPath(_path + "Materials/WaterRegularCutOut.mat", typeof(Material)) as Material;

            SerializedObject m_CustomSettings = SettingsManager.GetSerializedSettings();
            int metaballLayer = AssetUtility.LoadPropertyAsInt("w2d_Metaball_layer", m_CustomSettings);
            //int backgroundLayer = AssetUtility.LoadPropertyAsInt("w2d_Background_layer", m_CustomSettings);
            bool flipTex = AssetUtility.LoadPropertyAsBool("w2d_FlipCameraTexture", m_CustomSettings);

            // looking for Camera setup already in the scene
            ResizeQuadEffectController _camera = GameObject.FindObjectOfType<ResizeQuadEffectController>();

           // Water2D_Spawner _w2dPresentInScene = GameObject.FindObjectOfType<Water2D_Spawner>();

           // GameObject cams = null;
            if (!_camera)
            {

                ResizeQuadEffectController _quadResizer = GameObject.FindObjectOfType<ResizeQuadEffectController>();
                if (!_quadResizer)
                {
                    Object cameraSetup = AssetDatabase.LoadAssetAtPath(_path + "Prefabs/CamerasForRegular2.prefab", typeof(Object)) as Object;
                    //Object cameraSetup = AssetDatabase.LoadAssetAtPath(_path + "Prefabs/CamerasForRefracting.prefab", typeof(Object)) as Object;

                    GameObject cams = (GameObject)Instantiate(cameraSetup);
                    cams.name = "Cameras";

                    GameObject effectCamera = cams.transform.Find("1-EffectCamera").gameObject;
                    effectCamera.GetComponent<Camera>().cullingMask = 1 << metaballLayer;
                    effectCamera.GetComponent<Camera>().backgroundColor = new Color(0f, 0f, 0f, 0f);

                    _quadResizer = effectCamera.transform.Find("EffectQuad").GetComponent<ResizeQuadEffectController>();

                    GameObject DefaultCamera = cams.transform.Find("2-DefaultCamera").gameObject;
                    //currentMask | (1 << newLayer); //'removes' newLayer layer.
                    //currentMask & ~(1 << newLayer); //'removes' newLayer layer.
                    int _mask = DefaultCamera.GetComponent<Camera>().cullingMask;
                    DefaultCamera.GetComponent<Camera>().cullingMask = _mask & ~(1 << metaballLayer);

                }
                _quadResizer.FlipTexture = flipTex;
                if (PlayerSettings.colorSpace == ColorSpace.Linear)
                    _quadResizer.GetComponent<MeshRenderer>().sharedMaterial.SetFloat("_ComparisonThreshold", 0.05f);
                else
                    _quadResizer.GetComponent<MeshRenderer>().sharedMaterial.SetFloat("_ComparisonThreshold", 0.001f);

            }
            //_camera.gameObject.GetComponent<MeshRenderer>().sharedMaterial = m;

        }

        static Vector3 getCameraPos()
        {
            float offset = 0f;


            if (Camera.current)
                return new Vector3(Camera.current.transform.position.x, Camera.current.transform.position.y + offset, 0);
            else
                return new Vector3(0, offset, 0);
        }


        [MenuItem(menuPathMain + "/Settings", false, 60)]
        static void createsettings()
        {
            SettingsService.OpenProjectSettings("Project/Water2D");
            //SettingsManager.GetOrCreateSettings();
        }

        [MenuItem(menuPathMain + "/Documentation", false, 80)]
        static void OpenDoc()
        {
            Application.OpenURL("https://docs.google.com/document/d/1fcFz19jsL9tIdfFB1U72S9r4D2c7PSd4s0E_vnySa88");
        }
        [MenuItem(menuPathMain + "/Support", false, 81)]
        static void OpenMail()
        {
            Application.OpenURL("mailto:info@2ddlpro.com?subject=Water2D PRO&body=");
        }

        
    }
}