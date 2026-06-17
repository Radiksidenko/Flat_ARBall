# Flat_ARBall

A native iOS Augmented Reality project showcasing the evolution of mobile AR by combining **ARKit**, **RealityKit**, and custom **Metal Surface Shaders**. 

This project demonstrates how today's iOS devices can handle complex physical environments, native occlusion, and advanced procedural rendering in real-time without relying on external game engines.

<a href="https://youtube.com/shorts/QR0sjllwmuw" target="_blank">
  <sub>▶️ Watch Demo Video</sub>
  <br>
  <img width="400" height="265" alt="image" src="https://github.com/user-attachments/assets/8fa38d6e-a8f1-434c-86f5-44885f76fcc9" />
</a>


| 2018 (ARKit 1.0) | 2026 (RealityKit + Metal) |
| :---: | :---: |
| <img width="320" height="568" alt="1" src="https://github.com/user-attachments/assets/05e1dff8-5175-4cac-911b-e4db117b82f6" /> https://github.com/Radiksidenko/arKitTest| <img width="294" height="639" alt="2" src="https://github.com/user-attachments/assets/df85ae88-38f6-4747-9190-26891e1ace70" />|

<video src="https://github.com/Radiksidenko/Flat_ARBall/releases/download/untagged-88fed55209e22f968ddb/Resized_Video.mp4" width="100%" controls></video>
---

* **Scene Understanding & Physics:** Uses ARKit's `.mesh` scene reconstruction. Spheres bounce naturally off complex real-world geometry (like a ping-pong table and net) using custom friction and restitution parameters.
* **Real-world Occlusion:** Built-in environment options (`.occlusion`) ensure that digital spheres are realistically hidden when rolling behind real physical objects.
* **Custom Metal Shader (`glassSphereShader`):** A custom RealityKit surface shader that computes:
  * Dynamic **Fresnel effects** and faint edge iridescence.
  * Simulated **Refractive Index (IOR)** changes via normal vector distortion.
* **Per-Frame Uniform Updates:** Uses Combine to hook into the RealityKit `SceneEvents.Update` loop, passing elapsed time uniformly into the Metal shader layout via `SIMD4<Float>`.

