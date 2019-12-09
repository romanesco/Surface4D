using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace Surface4D
{
    public class GenerateHypercube : MonoBehaviour
    {
        [SerializeField] bool _saveAssetInEditor = false;
        [SerializeField] string _path = "Assets/Hypercube.asset";

        Vector4[] HCvertices =
        {
        new Vector4(-1,-1,-1,-1), // 0
        new Vector4(-1,-1,-1, 1), // 1
        new Vector4(-1,-1, 1,-1), // 2
        new Vector4(-1,-1, 1, 1), // 3
        new Vector4(-1, 1,-1,-1), // 4
        new Vector4(-1, 1,-1, 1), // 5
        new Vector4(-1, 1, 1,-1), // 6
        new Vector4(-1, 1, 1, 1), // 7
        new Vector4( 1,-1,-1,-1), // 8
        new Vector4( 1,-1,-1, 1), // 9
        new Vector4( 1,-1, 1,-1), // 10
        new Vector4( 1,-1, 1, 1), // 11
        new Vector4( 1, 1,-1,-1), // 12
        new Vector4( 1, 1,-1, 1), // 13
        new Vector4( 1, 1, 1,-1), // 14
        new Vector4( 1, 1, 1, 1)  // 15
    };

        int[] HCtriangles =
        {
        // respect orientation (use even permutations only)
        // fix (x,y), move (z,w)
        // (x,y) = (-1,-1): 0,1,2,3
        0, 1, 2,  2, 1, 3,       
        // (x,y) = (-1, 1): 4,5,6,7
        4, 5, 6,  6, 5, 7,
        // (x,y) = ( 1,-1): 8,9,10,11
        8, 9, 10,  10, 9, 11,
        // (x,y) = ( 1, 1): 12,13,14,15
        12, 13,14,  14, 13, 15,

        // fix (x,z), move (w,y)
        // (x,z) = (-1,-1): 0,1,4,5
        0, 1, 4,  4, 1, 5,
        // (x,z) = (-1, 1): 2,3,6,7
        2, 3, 6,  6, 3, 7,
        // (x,z) = ( 1,-1): 8,9,12,13
        8, 9, 12,  12, 9, 13,
        // (x,z) = ( 1, 1): 10,11,14,15
        10, 11, 14,  14, 11, 15,

        // fix (x,w), move (y,z)
        // (x,w) = (-1,-1): 0,2,4,6
        0, 2, 4,  4, 2, 6,
        // (x,w) = (-1, 1): 1,3,5,7
        1, 3, 5,  5, 3, 7,
        // (x,w) = ( 1,-1): 8,10,12,14
        8, 10, 12,  12, 10, 14,
        // (x,w) = ( 1, 1): 9,11,13,15
        9, 11, 13,  13, 11, 15,

        // fix (y,z), move (x,w)
        // (y,z) = (-1,-1): 0,1,8,9
        0, 1, 8,  8, 1, 9,
        // (y,z) = (-1, 1): 2,3,10,11
        2, 3, 10,  10, 3, 11,
        // (y,z) = ( 1,-1): 4,5,12,13
        4, 5, 12,  12, 5, 13,
        // (y,z) = ( 1, 1): 6,7,14,15
        6, 7, 14,  14, 7, 15,

        // fix (y,w), move (z,x)
        // (y,w) = (-1,-1): 0,2,8,10
        0, 2, 8,  8, 2, 10,
        // (y,w) = (-1, 1): 1,3,9,11
        1, 3, 9,  9, 3, 11,
        // (y,w) = ( 1,-1): 4,6,12,14
        4, 6, 12,  12, 6, 14,
        // (y,w) = ( 1, 1): 5,7,13,15
        5, 7, 13,  13, 7, 15,

        // fix (z,w), move (x,y)
        // (z,w) = (-1,-1): 0,4,8,12
        0, 4, 8,  8, 4, 12,
        // (z,w) = (-1, 1): 1,5,9,13
        1, 5, 9,  9, 5, 13,
        // (z,w) = ( 1,-1): 2,6,10,14
        2, 6, 10,  10, 6, 14,
        // (z,w) = ( 1, 1): 3,7,11,15
        3, 7, 11,  11, 7, 15

    };

        Color HCcolor(Vector4 v)
        {
            return new Color((1 + (v.x + 1) + (v.w + 1) / 2) * 0.25f,
                (1 + (v.y + 1) + (v.w + 1) / 2) * 0.25f,
                (1 + (v.z + 1) + (v.w + 1) / 2) * 0.25f,
                0.5f);
        }

        Mesh CreateMesh()
        {
            int N = 16;
            Vector3[] vertices = new Vector3[N];
            Color[] colors = new Color[N];
            Vector2[] uvs = new Vector2[N];
            for (int i = 0; i < N; i++)
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
