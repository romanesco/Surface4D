using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace Surface4D
{
    public class GenerateKleinbottle : MonoBehaviour
    {
        [SerializeField] bool _saveAssetInEditor = true;
        [SerializeField] string _path = "Assets/Kleinbottle.asset";
        static int N = 30;
        Vector4[] HCvertices = new Vector4[N * N];
        int[] HCtriangles = new int[3 * 2 * (N-1) * (N-1)];

        Color HCcolor(Vector4 v)
        {
            return new Color((1 + (v.x + 1) + (v.w + 1) / 2) * 0.25f,
                (1 + (v.y + 1) + (v.w + 1) / 2) * 0.25f,
                (1 + (v.z + 1) + (v.w + 1) / 2) * 0.25f,
                0.5f);
        }

        Mesh CreateMesh()
        {
                float a = 1.5f;
                float e = 0.5f;
                int nt = 0;

                for (int i = 0; i < N; i++)
                {
                    for (int j = 0; j < N; j++)
                    {
                        float u = (float)j / N * 2*Mathf.PI;
                        float v = (float)i / N * 2*Mathf.PI;
                        int k = i * N + j;
                        HCvertices[k].y = -a * (-2 + Mathf.Abs(-1 + a)) * Mathf.Sin(u)*(1 + e * Mathf.Sin(v));
                        HCvertices[k].x = a * (-2 + Mathf.Abs(-1 + a)) * Mathf.Cos(u)*(1 + e * Mathf.Sin(v));
                        HCvertices[k].z = -(((-2 + Mathf.Abs(-1 + a)) * (Mathf.Cos(v) * Mathf.Sin(u / 2) + Mathf.Cos(u / 2) * Mathf.Sin(2 * v))) / a);
                        HCvertices[k].w = ((-2 + Mathf.Abs(-1 + a)) * (Mathf.Cos(u / 2) * Mathf.Cos(v) - Mathf.Sin(u / 2) * Mathf.Sin(2 * v))) / a;

                        if (i < N - 1 && j < N - 1)
                        {
                            HCtriangles[nt++] = k;
                            HCtriangles[nt++] = k + N;
                            HCtriangles[nt++] = k + N + 1;
                            HCtriangles[nt++] = k;
                            HCtriangles[nt++] = k + N + 1;
                            HCtriangles[nt++] = k + 1;
                        }

                    }
                }
            Vector3[] vertices = new Vector3[N*N];
            Color[] colors = new Color[N*N];
            Vector2[] uvs = new Vector2[N*N];
            for (int i = 0; i < N*N; i++)
            {
                vertices[i] = HCvertices[i];
                uvs[i] = new Vector2(HCvertices[i].w, 0);
                colors[i] = HCcolor(HCvertices[i]);

            }
            var mesh = new Mesh();
            mesh.vertices = vertices;
            mesh.uv2 = uvs;
            mesh.colors = colors;
            mesh.triangles = HCtriangles;
            return mesh;
        }

        // Start is called before the first frame update
        void Start()
        {
            var mesh = CreateMesh();
        #if UNITY_EDITOR
            if (_saveAssetInEditor)
            {
                AssetDatabase.CreateAsset(mesh, _path);
                AssetDatabase.SaveAssets();
            }
        #endif

            gameObject.GetComponent<MeshFilter>().mesh = mesh;
        }

        // Update is called once per frame
        void Update()
        {

        }
        }
}
