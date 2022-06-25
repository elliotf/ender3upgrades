include <lumpyscad/lib.scad>;

y_rail_side_rail_dist_x = 135;
y_rail_side_rail_dist_z = 33;
y_rail_length = 330;
y_rail_length_front = 190;
side_rail_length = 290;
side_rail_length_front = 125;
side_rail_length_rear = side_rail_length-40-side_rail_length_front;
side_connector_length = 250;
x_rail_length = side_connector_length+40;

x_rail_pos_z = 200;

vertical_side_rail_length = 400;

psu_length = 215;
psu_width = 115;
psu_height = 30;

psu_terminal_area_depth = 15;
psu_metal_thickness = 2;

// meanwell LRS-350-24
module psu() {
  psu_fan_from_end = 48; // not very accurate, only for visualization
  psu_fan_from_side = 38; // not very accurate, only for visualization
  psu_fan_diam = 52; // not very accurate, only for visualization

  module body() {
    cube([psu_width,psu_length,psu_height],center=true);
  }

  module holes() {
    for(x=[left,right],y=[32.5,150]) {
      translate([0,-psu_length/2+y,-psu_height/2]) {
        // side holes
        translate([x*psu_width/2,0,12.5]) {
          rotate([0,90,0]) {
            hole(4,10,resolution);
          }
        }
        translate([x*(50/2),0,0]) {
          hole(4,10,resolution);
        }
      }
    }

    translate([left*(psu_width/2-psu_fan_from_side),psu_length/2-psu_fan_from_end,psu_height/2]) {
      hole(psu_fan_diam,0.5,resolution);
    }

    translate([0,front*(psu_length/2),psu_height/2]) {
      height = psu_height-psu_metal_thickness;
      width = psu_width-psu_metal_thickness*2;

      cube([width,psu_terminal_area_depth*2,height*2],center=true);
    }
  }

  difference() {
    color("#bbb") body();
    color("#777") holes();
  }
}

module fake_ender3_frame(frame_color="#555", opacity=1) {
  module body() {
    // side braces/feet
    for(x=[left,right]) {
      translate([x*(side_connector_length/2+40/2),side_rail_length/2-side_rail_length_front,40/2]) {
        rotate([90,0,0]) {
          rotate([0,0,90]) {
            color(frame_color, opacity) extrusion_4040(side_rail_length);
          }
        }
      }
    }

    // vertical
    for(x=[left,right]) {
      translate([x*(side_connector_length/2+40/2),40/2,40]) {
        translate([0,0,vertical_side_rail_length/2]) {
          color(frame_color, opacity) extrusion_2040(vertical_side_rail_length);
        }
        nema_type = NEMA17_34;
        translate([0,20/2+NEMA_width(nema_type)/2,NEMA_length(nema_type)]) {
          rotate([0,0,90*x]) {
            NEMA(nema_type);
          }
        }
      }
    }

    // top rail
    translate([0,40/2,40+vertical_side_rail_length+20/2]) {
      rotate([0,90,0]) {
        color(frame_color, opacity) extrusion_2020(side_connector_length+40*2);
      }
    }

    // x rail
    translate([0,front*20/2,x_rail_pos_z]) {
      rotate([0,90,0]) {
        color(frame_color, opacity) extrusion_2020(y_rail_length);
      }
    }

    // left/right connector
    color(frame_color, opacity) difference() {
      translate([0,40/2,40/2]) {
        rotate([0,90,0]) {
          extrusion_4040(side_connector_length);
        }
      }
      translate([0,20,40/2+y_rail_side_rail_dist_z]) {
        cube([20,40,40],center=true);
      }
      translate([-side_connector_length/2+58,10,0]) {
        hole(3,40,resolution);
      }
    }

    // y rail
    translate([0,y_rail_length/2-y_rail_length_front,40/2+y_rail_side_rail_dist_z]) {
      rotate([90,0,0]) {
        rotate([0,0,90]) {
          color(frame_color, opacity) extrusion_2040(y_rail_length);
        }
      }
    }
  }

  module holes() {
    wiring_cut_from_x_min = 15;
    wiring_cut_width = 40;
    wiring_cut_height = 20;
    translate([-side_connector_length/2+wiring_cut_from_x_min+wiring_cut_width/2,0,0]) {
      cube([wiring_cut_width,100,wiring_cut_height*2],center=true);
    }

  }

  difference() {
    body();
    color("lightgrey") holes();
  }
}
