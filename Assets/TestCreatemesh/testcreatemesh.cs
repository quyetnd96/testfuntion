using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(MeshFilter))]
public class testcreatemesh : MonoBehaviour
{
    public BaseDataVehicles baseData;
    private Mesh mesh;
    private MeshRenderer meshRenderer;
    [SerializeField] Material materialA;
    protected bool isDirty = true;
    public bool RealtimeUpdates = false;
    private MeshFilter meshFilter = null;
    #region Private methods

    private void ensureReferences()
    {
        // ensure a mesh filter
        if (meshFilter == null)
        {
            mesh = null;
            meshFilter = gameObject.GetComponent<MeshFilter>();
            if (meshFilter == null)
            {
                meshFilter = gameObject.AddComponent<MeshFilter>();
            }
        }

        // ensure a mesh
        if (mesh == null)
        {
            mesh = meshFilter.sharedMesh;
            if (mesh == null || mesh.name != "WaterVolume-" + gameObject.GetInstanceID())
            {
                mesh = new UnityEngine.Mesh();
                mesh.name = "WaterVolume-" + gameObject.GetInstanceID();
            }
        }

        // apply the mesh to the filter
        meshFilter.sharedMesh = mesh;
    }

    #endregion
    private void Build()
    {
        ensureReferences();
        // mesh = new Mesh();
        // mesh.MarkDynamic();

        // MeshFilter meshFilter = gameObject.AddComponent<MeshFilter>();
        // meshFilter.mesh = mesh;
        // meshRenderer = gameObject.AddComponent<MeshRenderer>();
        // meshRenderer.material = materialA;
        mesh.Clear();
        int lengthListPos = baseData.listPathReceivePos.Count * 2;
        Vector3[] ListPos = new Vector3[lengthListPos];
        int j = 0;
        for (int i = 0; i < lengthListPos; i++)
        {
            if (i % 2 == 0)
            {
                try
                {
                    ListPos[i] = baseData.listPathReceivePos[j];
                }
                catch
                {
                    Debug.Log(i + "_" + j);
                }
                j++;
            }
        }
        int k = 0;
        for (int i = 0; i < lengthListPos; i++)
        {
            if (i % 2 != 0)
            {
                try
                {
                    ListPos[i] = baseData.listPathReceivePos2[k];
                }
                catch
                {
                    Debug.Log(i + "_" + k);
                }
                k++;
            }
        }

        mesh.vertices = ListPos.ToArray();
        Vector2[] texCoords = new Vector2[mesh.vertices.Length];
        int countTriangles = (baseData.listPathReceivePos.Count - 1) * 2;
        List<int> triangles = new List<int>();
        for (int i = 0; i < countTriangles - 1; i++)
        {
            triangles.Add(i);
            triangles.Add(i + 2);
            triangles.Add(i + 1);
            triangles.Add(i + 2);
            triangles.Add(i + 3);
            triangles.Add(i + 1);

        }
        for (int i = 0; i < mesh.vertices.Length; i++)
        {
            texCoords[i] = new Vector2(mesh.vertices[i].x, mesh.vertices[i].z);
        }
        // mesh.uv = texCoords;
        mesh.SetUVs(0, texCoords);
        mesh.triangles = triangles.ToArray();
        mesh.RecalculateNormals();
        isDirty = false;
    }
    void OnValidate()
    {
        isDirty = true;
    }
    void Update()
    {
        // rebuild if needed
        if (isDirty || (!Application.isPlaying && RealtimeUpdates))
        {
            Build();
        }
    }
}
