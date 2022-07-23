use <../extrusion-clip.scad>;

linear_extrude(height=10,center=true,convexity=3) {
  extrusion_clip_wiring_holder(10,10);
}
