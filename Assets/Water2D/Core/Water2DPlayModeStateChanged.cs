#if UNITY_EDITOR
namespace Water2D
{
    using UnityEngine;
    using UnityEditor;


    // ensure class initializer is called whenever scripts recompile
    [InitializeOnLoadAttribute]
    public static class PlayModeStateChanged
    {

        static PlayModeStateChange _lastState;

        // register an event handler when the class is initialized
        static PlayModeStateChanged()
        {
            EditorApplication.playModeStateChanged += LogPlayModeState;
        }

        private static void LogPlayModeState(PlayModeStateChange state)
        {
            if (state == PlayModeStateChange.EnteredEditMode)
            {
             
                SpawnersManager.CleanSceneCache();

            }
           
                if (state == PlayModeStateChange.ExitingEditMode)
            {
                PhysicsSimulation.Stop();
               
            }

            


                _lastState = state;

        }
        /*
        [UnityEditor.Callbacks.DidReloadScripts]
        private static void CleanAfterCompile()
        {
            SpawnersManager.CleanSceneCache();
            ResizeQuadEffectController.RebuildTextures();
            Debug.Log("yeap");
        }
        */
    }

    public class AssetModification : AssetModificationProcessor
    {

        static void OnWillSaveAssets(string[] paths)
        {
            SpawnersManager.CleanSceneCache();
            ResizeQuadEffectController r_ = GameObject.FindObjectOfType<ResizeQuadEffectController>();
            if (r_) {
                //Debug.Log("saving");
                r_.AboutToRebuildAll();
            }

        }

        
    }

}
#endif