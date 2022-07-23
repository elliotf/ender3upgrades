include <../psu-mount.scad>;

rotate([-90,0,0]) {
  mirror([psu_mirror_x,0,0]) {
    psu_mount_non_plug_side();
  }
}
