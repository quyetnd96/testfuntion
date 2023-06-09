using System.Linq;
using System.Text;
using System.Threading;
using UnityEngine;
using UnityEditor;
using UnityEditor.PackageManager;

namespace Water2D
{
    public class InstalledPackages : AssetPostprocessor
    {
        private static void OnPostprocessAllAssets(string[] importedAssets, string[] deletedAssets, string[] movedAssets, string[] movedFromAssetPaths)
        {
            var inPackages = importedAssets.Any(path => path.StartsWith("Packages/")) ||
                deletedAssets.Any(path => path.StartsWith("Packages/")) ||
                movedAssets.Any(path => path.StartsWith("Packages/")) ||
                movedFromAssetPaths.Any(path => path.StartsWith("Packages/"));

            if (inPackages)
            {
                InitializeOnLoad();
            }
        }

        [InitializeOnLoadMethod]
        private static void InitializeOnLoad()
        {
            var listRequest = Client.List(true);
            while (!listRequest.IsCompleted)
                Thread.Sleep(100);

            if (listRequest.Error != null)
            {
                Debug.Log("Error: " + listRequest.Error.message);
                return;
            }

            var packages = listRequest.Result;
            var text = new StringBuilder("Packages:\n");
            foreach (var package in packages)
            {
                if (package.name.Contains("lightweight"))
                    FlipPatcher.isPatched = true; //
    
            }

           
        }
    }
}

    