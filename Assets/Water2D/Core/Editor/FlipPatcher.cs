using System;
using System.Threading;
using System.Threading.Tasks;
using UnityEditor;
using UnityEditor.PackageManager.Requests;
using UnityEditor.PackageManager;
using UnityEngine.Rendering;
using UnityEngine;

namespace Water2D
{


    public static class FlipPatcher
    {
        static ListRequest RequestList;
        static AddRequest RequestAdd;

        static double sinceStart;
        public static bool isPatched = false;

        
       

        //[MenuItem("Window/Flip patch - Step 1")]
        public static void TryToPatch()
        {

            if (isPatched)
            {
                EditorUtility.DisplayDialog("Water2D flip fix", "Flip already patched", "OK");
                return;
            }

            Debug.Log("here");
            RequestList = Client.List();    // List packages installed for the project
            EditorApplication.update += ListingProgress;
        }

       

        static void ListingProgress()
        {
            bool isLWRP = false;
            

            if (RequestList.IsCompleted)
            {
                if (RequestList.Status == StatusCode.Success)
                    foreach (var package in RequestList.Result)
                    {
                        if (package.name.Contains("lightweight"))
                            isLWRP = true;
                    }

                else if (RequestList.Status >= StatusCode.Failure)
                    Debug.Log(RequestList.Error.message);

                EditorApplication.update -= ListingProgress;

                if (!isLWRP)
                    Add();

                else
                    EditorUtility.DisplayDialog("Water2D flip fix", "Flip already patched", "OK");
                //UpdateChecker();
            }
        }

        static void Add()
        {
            // Add a package to the project
            RequestAdd = Client.Add("com.unity.render-pipelines.lightweight");
            EditorApplication.update += AddingProgress;
        }

        static void AddingProgress()
        {
            if (RequestAdd.IsCompleted)
            {
                if (RequestAdd.Result.status == PackageStatus.Available)
                {
                    Debug.Log("Installed: " + RequestAdd.Result.packageId);
                   // UpdateChecker();
                }
                else if (RequestAdd.Status >= StatusCode.Failure)
                    Debug.Log(RequestAdd.Error.message);




                EditorApplication.update -= AddingProgress;


            }
        }

        static double nowT = 0;
        static double tick1, tick2;
        static bool isSetrp = false;

        //[MenuItem("Window/Flip patch - Step 2")]
        public static void UpdateChecker()
        {
            Debug.Log("updatechecker");

            if (nowT == 0)
            {
                nowT = EditorApplication.timeSinceStartup;
                
                tick1 = nowT + 1;
                tick2 = tick1 + 2;
                EditorApplication.update += UpdateChecker;
                               
            }
            nowT = EditorApplication.timeSinceStartup;
            //Debug.Log(nowT);
            if (nowT > tick1 && !isSetrp)
            {
                RenderPipelineAsset rpAsset = AssetDatabase.LoadAssetAtPath(Apptouch.EditorUtils.getMainRelativepath() + "Render Pipeline/LightweightRenderPipelineAsset.asset", typeof(RenderPipelineAsset)) as RenderPipelineAsset;

                GraphicsSettings.renderPipelineAsset = rpAsset;
                Debug.Log("set rp asset");
                isSetrp = true;
            }

            if (nowT > tick2)
            {
                GraphicsSettings.renderPipelineAsset = null;
                EditorApplication.update -= UpdateChecker;
                EditorApplication.update -= AddingProgress;
                Debug.Log("NULL rp asset andd terminate");
                EditorUtility.DisplayDialog("Water2D flip fix", "Flip patched!", "ok");
            }

        }



    }
}