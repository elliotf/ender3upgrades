include <lumpyscad/lib.scad>;

resolution = 128;
extrusion_width = 0.5;
wall_thickness = 1.5;
tolerance = 0.2;

wire_angle = 25;

m5_t_slot_nut_length = 12;
screw_length = 10;
screw_t_slot_nut_engagement = 4;

mount_height = 14;
mount_length_past_end = 8;
mount_length_in_v_slot = 36;
mount_length = mount_length_in_v_slot+mount_length_past_end;
mount_depth = screw_length-v_slot_depth-screw_t_slot_nut_engagement;
wire_cavity_diam = 8;
wire_area_depth = 16;
base_thickness = 2;

zip_tie_width = 5;
zip_tie_thickness = 3;
zip_tie_id = wire_cavity_diam+wall_thickness*4;
zip_tie_od = zip_tie_id + zip_tie_thickness*2;
rounded_diam = 2;
wire_area_od = zip_tie_od+wall_thickness*4;
wire_area_width = 24;
wire_area_offset_z = mount_height*0.25;

module y_axis_strain_relief_mount() {
  slot_length = mount_length_in_v_slot - 10;

  module position_wire() {
    rotate([0,0,wire_angle]) {
      translate([0,-wire_area_od/2,wire_area_offset_z]) {
        rotate([0,-90,0]) {
          translate([0,0,0]) {
            children();
          }
        }
      }
    }
  }

  module body() {
    translate([mount_depth/2,mount_length/2-mount_length_past_end,0]) {
      rounded_cube(mount_depth,mount_length,mount_height,rounded_diam,resolution);
    }
    position_wire() {
      intersection() {
        translate([-wire_area_offset_z,wire_area_od/2,0]) {
          cube([mount_height,wire_area_od,wire_area_width],center=true);
        }
        hole(wire_area_od,200,resolution);
      }
    }
    hull() {
      translate([rounded_diam/2,mount_length_in_v_slot-slot_length/2,0]) {
        rounded_cube(rounded_diam,slot_length,v_slot_width,rounded_diam,resolution);
        translate([-v_slot_depth*0.25,0,0]) {
          rounded_cube(rounded_diam,slot_length,v_slot_opening,rounded_diam,resolution);
        }
      }
    }

    /*
    hull() {
      translate([0,0,-mount_height/2+base_thickness/2]) {
        translate([mount_depth/2,mount_length/2-mount_length_past_end,0]) {
          rounded_cube(mount_depth,mount_length,base_thickness,rounded_diam,resolution);
        }

        position_wire() {
          rotate([0,90,0]) {
            translate([wire_area_width/4,wire_cavity_diam/2,-wire_area_offset_z]) {
              cube([wire_area_width/2,1,base_thickness],center=true);
            }
          }
        }
      }
    }
    */
  }

  module holes() {
    position_wire() {
      hole(wire_cavity_diam,40,resolution);
      translate([wire_cavity_diam,0,0]) {
        // cube([wire_cavity_diam*2,wire_cavity_diam,40],center=true);
      }

      width = zip_tie_width;
      difference() {
        hole(zip_tie_od,width,resolution);
        hole(zip_tie_id,width+1,resolution);
      }
    }

    translate([mount_depth,mount_length_in_v_slot-slot_length/2,0]) {
      rotate([0,90,0]) {
        hole(m5_diam+tolerance*4,screw_length*2,8);
      }
    }
  }

  difference() {
    body();
    holes();
  }
}

y_axis_strain_relief_mount();
