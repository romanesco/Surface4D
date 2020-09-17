# Surface4D
4D surface shader for Unity

## How to play the demo scene
- Create an empty 3D project in Unity.
- From Package Manager, install the **Mathematics** package.
- Drag and drop the downloaded **Surface4D** folder to **Assets** in the project browser.
- In **Project Settings** -> **Player** -> **XR Settings**, tick **Virtual Reality Supported**. 
- Open **Scenes/Hypercube** or **Scenes/Hypercube_Klein** by double clicking the icon in the project browser.
- (optional) Add the definition of a triangulated mesh in the 4D space that is written in C# as **Scripts/GenerateHypercube.cs** 
and **Scripts/GenerateKleinbottle.cs**.
To render the newly added mesh, first duplicate the scene's **Hypercube** object, and
assign the script to it as a component. Then, turn off **Generate Hypercube (Script)**. 
- Put on your HMD and start the game engine by pressing play button.
