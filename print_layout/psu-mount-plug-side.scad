include <../psu-mount.scad>;

rotate([-90,0,0]) {
  position_psu() {
    // % color("lightgrey", 0.5) psu();
  }
  mirror([psu_mirror_x,0,0]) {
    psu_mount_plug_side();
  }
}
