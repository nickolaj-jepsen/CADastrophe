// Interactive STL viewer: one <div class="viewer" data-stl="..."> per model.
// three.js comes from the CDN import map pinned in the page template.
import * as THREE from 'three';
import { STLLoader } from 'three/addons/loaders/STLLoader.js';
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';

document.querySelectorAll('.viewer[data-stl]').forEach(initViewer);

function initViewer(el) {
  const scene = new THREE.Scene();
  scene.background = new THREE.Color(0xf2f3f5);

  // OpenSCAD parts are Z-up; keep that convention instead of three's Y-up.
  const camera = new THREE.PerspectiveCamera(45, 1, 0.1, 10000);
  camera.up.set(0, 0, 1);

  const renderer = new THREE.WebGLRenderer({ antialias: true });
  renderer.setPixelRatio(window.devicePixelRatio);
  el.appendChild(renderer.domElement);

  scene.add(new THREE.HemisphereLight(0xffffff, 0x556677, 1.2));
  const key = new THREE.DirectionalLight(0xffffff, 1.6);
  key.position.set(1, -1.5, 2);
  scene.add(key);
  const fill = new THREE.DirectionalLight(0xffffff, 0.5);
  fill.position.set(-2, 1, 0.5);
  scene.add(fill);

  const controls = new OrbitControls(camera, renderer.domElement);
  controls.enableDamping = true;

  new STLLoader().load(el.dataset.stl, (geometry) => {
    geometry.computeBoundingBox();
    const bb = geometry.boundingBox;
    const center = bb.getCenter(new THREE.Vector3());
    const size = bb.getSize(new THREE.Vector3());
    const diag = size.length();

    const mesh = new THREE.Mesh(geometry, new THREE.MeshStandardMaterial({
      color: 0x4f7cac, metalness: 0.05, roughness: 0.65,
    }));
    // Centre in X/Y, rest the part on the grid (z = 0 is the print bed).
    mesh.position.set(-center.x, -center.y, -bb.min.z);
    scene.add(mesh);

    // GridHelper lies in the XZ plane; rotate it into XY ("the bed").
    const span = Math.ceil(Math.max(size.x, size.y) * 1.6 / 10) * 10;
    const grid = new THREE.GridHelper(span, span / 10, 0xb0b6bd, 0xd5d9de);
    grid.rotation.x = Math.PI / 2;
    scene.add(grid);

    controls.target.set(0, 0, size.z / 2);
    camera.position.set(diag * 0.9, -diag * 0.9, diag * 0.7);
    camera.near = diag / 100;
    camera.far = diag * 20;
    camera.updateProjectionMatrix();
  }, undefined, (err) => {
    el.textContent = 'Could not load model: ' + (err.message || err);
  });

  function resize() {
    const w = el.clientWidth, h = el.clientHeight;
    if (w === 0 || h === 0) return;
    renderer.setSize(w, h);
    camera.aspect = w / h;
    camera.updateProjectionMatrix();
  }
  new ResizeObserver(resize).observe(el);
  resize();

  renderer.setAnimationLoop(() => {
    controls.update();
    renderer.render(scene, camera);
  });
}
