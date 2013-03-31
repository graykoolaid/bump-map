#include <fbxsdk.h>
#include <stdio.h>
#include <iostream>
#include <vector>
#include <D3D10.h>
#include <D3DX10.h>
#include <D3Dcompiler.h>
#include <xnamath.h>
#include <direct.h>
using namespace std;


void loadVectors(KFbxNode* pNode, int polygonCount, FbxMesh *mesh, FbxVector4* meshVertices);
void DisplayContent(KFbxNode* pNode);
void DisplayContent(FbxScene* pScene);
int Import(char* filename, vector<D3DXVECTOR3> *vec, vector<WORD> *ind, vector<D3DXVECTOR3> *norm, vector<D3DXVECTOR2> *tex, vector<int> *num );