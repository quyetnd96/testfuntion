Optimization size built:
Prefab :
- Make Prefabs in Level reference from Prefab in Asset
- note:
- Some Prefabs be changed when editer or GD set map need to cache infor and clear when build - because when build all prefabs will be split and some prefabs have been changed - will be determine is different prefabs and increasing size build
- Example infor when build done: some level have size build bigger than real size of it.
- Example explain for it https://www.youtube.com/watch?v=4JLpJHIdx7E&t=3s
Texture :
- compress texture to size it draw on scene
- note properties of texture when import to unity
- you can use again some texture UI in the similary popup - you need optimize it to use again
Model Mesh:
- with Model 3D some object don't move on scene need to tick static batching to down draw call
- model can be compress with quality{no,low,medium,high} - to down size
- some Mesh can be drawed by GPU instance -https://www.youtube.com/watch?v=cwbyvbtJ9UY
Model Anim:
- Anim is also compress size because properties -
Sound:
- Compress size like example link: https://codethunder978933933.wordpress.com/2020/08/24/toi-uu-audio-asset-trong-unity/

