// Interactive STL viewers + a gallery lightbox, both opt-in. three.js (from the
// CDN import map in the page <head>) loads only when the visitor asks for 3D, so
// landing — and offline `scad site --serve` — costs zero WebGL/CDN. The static
// hero + ortho galleries carry the page without any of this.

let threePromise = null;
// Memoized three.js load; reset to null on failure so a later retry can succeed.
function loadThree() {
  if (!threePromise) {
    threePromise = Promise.all([
      import('three'),
      import('three/addons/loaders/STLLoader.js'),
      import('three/addons/controls/OrbitControls.js'),
    ]).then(([THREE, stl, orbit]) => ({
      THREE, STLLoader: stl.STLLoader, OrbitControls: orbit.OrbitControls,
    })).catch((err) => { threePromise = null; throw err; });
  }
  return threePromise;
}

function ensureViewer(el) {
  if (el.dataset.initialized) return;
  el.dataset.initialized = '1';  // set synchronously: a second trigger is a no-op
  el.textContent = 'Loading 3D…';
  loadThree().then((three) => {
    el.textContent = '';
    initViewer(el, three);
  }).catch(() => {
    el.textContent = 'Could not load the 3D viewer (needs network access to load three.js).';
    delete el.dataset.initialized;  // clear the flag so reconnect + retry works
  });
}

function reveal(el) {
  el.hidden = false;
  requestAnimationFrame(() => ensureViewer(el));  // let the box get layout first
}

function bootstrap() {
  document.querySelectorAll('.view-3d').forEach((btn) => {
    btn.addEventListener('click', () => {
      const el = btn.nextElementSibling;
      if (!el || !el.matches('.viewer[data-stl]')) return;
      btn.setAttribute('aria-expanded', 'true');
      btn.hidden = true;
      reveal(el);
    });
  });
  document.querySelectorAll('details.parts').forEach((d) => {
    d.addEventListener('toggle', () => {
      if (!d.open) return;
      d.querySelectorAll('.viewer[data-stl]').forEach(reveal);
    });
  });
  initLightbox();
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', bootstrap);
} else {
  bootstrap();
}

function initViewer(el, { THREE, STLLoader, OrbitControls }) {
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
    if (w === 0 || h === 0) return;  // lets a viewer revealed in a just-opened <details> size correctly
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

// One overlay, reused. Any gallery thumbnail or the hero opens it in-page; the
// underlying <a href="...png"> stays the no-JS / middle-click fallback.
function initLightbox() {
  const overlay = document.createElement('div');
  overlay.className = 'lightbox';
  overlay.hidden = true;
  overlay.setAttribute('role', 'dialog');
  overlay.setAttribute('aria-modal', 'true');
  const closeBtn = document.createElement('button');
  closeBtn.className = 'lightbox-close';
  closeBtn.setAttribute('aria-label', 'Close');
  closeBtn.textContent = '×';
  const img = document.createElement('img');
  overlay.append(closeBtn, img);
  document.body.appendChild(overlay);

  let lastFocus = null;

  function open(src, alt) {
    img.src = src;
    img.alt = alt || '';
    img.classList.remove('zoomed');
    lastFocus = document.activeElement;
    overlay.hidden = false;
    document.body.style.overflow = 'hidden';
    closeBtn.focus();
    document.addEventListener('keydown', onKey);
  }
  function close() {
    overlay.hidden = true;
    img.src = '';
    document.body.style.overflow = '';
    document.removeEventListener('keydown', onKey);
    if (lastFocus) lastFocus.focus();
  }
  function onKey(e) {
    if (e.key === 'Escape') { close(); return; }
    if (e.key === 'Tab') { e.preventDefault(); closeBtn.focus(); }  // single focusable: trap here
  }

  closeBtn.addEventListener('click', close);
  overlay.addEventListener('click', (e) => { if (e.target === overlay) close(); });
  img.addEventListener('click', (e) => { e.stopPropagation(); img.classList.toggle('zoomed'); });

  document.addEventListener('click', (e) => {
    const a = e.target.closest('.gallery a, figure.hero a');
    if (!a) return;
    if (e.metaKey || e.ctrlKey || e.shiftKey || e.button !== 0) return;  // keep open-in-new-tab
    e.preventDefault();
    const thumb = a.querySelector('img');
    open(a.getAttribute('href'), thumb ? thumb.alt : '');
  });
}
