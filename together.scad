include <./frame-mockup.scad>;
include <./psu-mount.scad>;
//include <./horizontal-electronics-mount.scad>;
//use <./vertical-electronics-mount.scad>;
use <./new-vertical-electronics-mount.scad>;
//use <./electronics-mount.scad>;

% fake_ender3_frame();

//translate([left*(side_connector_length/2+40),-side_rail_length_front+side_rail_length,40]) {
psu_assembly();
//horizontal_electronics_mount_assembly();
//vertical_electronics_mount_assembly();
new_vertical_electronics_mount_assembly();

//vertical_skr_e3_mini_electronics_mount_assembly();
