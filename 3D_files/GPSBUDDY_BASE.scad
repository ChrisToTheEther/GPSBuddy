// GPS_BUDDY CASE 

$fn = 72;

// External case dimensions 
walkman_w = 133;
walkman_d = 88;
walkman_h = 29;
corner_rad = 11;

// PCB standoffs (ElectroCookie)  
pcb_width  = 89.0; 
pcb_depth  = 52.1;
pcb_mount_x = pcb_width/2 - 3; // Approx hole location
pcb_mount_y = pcb_depth/2 - 3;

//Internal dims
wall = 2.4;
seam_z = 14.5;          // Height of the front shell

//  OLED 
oled_w = 20;
oled_h = 36;
oled_x = 25S;    // Centered horizontally looks best on TPS-L2
oled_y = 2;

//  BUTTONS 
btn_diam = 7;
btn_spacing = 25;
btn_z = 6.0;          // Define height from the floor
btn_w = 6;          // Width of the rectangle
btn_h = 10;         // Height of the rectangle
// USB
usb_w = 12;
usb_h = 6.5;
usb_z = 5.5;

//  MAGNETS FOR BACKPLATE
magnet_d = 6.2;
magnet_h = 3;
magnet_offset = 12;

// BUTTON KEYCAP
btn_clearance = 0.4;    // Gap between button and hole (0.2-0.4 is  good)
btn_extrude = 3.0;      // How far button sticks out of the case
btn_flange_w = 2.0;     // How much wider the base is (prevents falling through)
btn_flange_t = 1.5;     // Thickness of base plate


// BASIC SHAPES


module rounded_box(w,d,h,r) {
    hull() {
        for(x=[-1,1], y=[-1,1])
            translate([x*(w/2-r), y*(d/2-r), 0])
                cylinder(r=r, h=h);
    }
}

module pill(w,h,d) {
    hull() {
        translate([-(w-h)/2,0,0]) cylinder(d=h,h=d,center=true);
        translate([(w-h)/2,0,0])  cylinder(d=h,h=d,center=true);
    }
}

// FRONT SHELL

module front_shell() {
    difference() {
        // POSITIVE BODY
        rounded_box(walkman_w, walkman_d, walkman_h, corner_rad);

        // BACK CUT OUT
        translate([0,0,seam_z + walkman_h/2])
            cube([walkman_w+40, walkman_d+40, walkman_h], center=true);

        // TRUE HOLLOW CAVITY
        
        translate([0,0,wall])
            rounded_box(walkman_w - 2*wall, walkman_d - 2*wall, walkman_h, corner_rad - wall);

        // OLED CUTOUT
        // Cuts through floor (Z=0) to inside
        translate([oled_x, oled_y, -1])
            rounded_box(oled_w, oled_h, wall*3, 2);

        // USB CUTOUT
        translate([-walkman_w/2, 0, wall+usb_z])
            rotate([0,90,0])
            rotate([0,0,90])
            pill(usb_w, usb_h, 20);

        // BUTTON HOLES
        for(i=[-1,1])
            translate([i*btn_spacing/2, -walkman_d/2, wall+btn_z])
                rotate([0,90,0])
                rotate([90,0,0])
                cube([btn_w, btn_h, 20], center=true);
          
                
        // MAGNET POCKETS
        for(x=[-1,1])
            translate([x*(walkman_w/2-magnet_offset), 0, seam_z-magnet_h])
                cylinder(d=magnet_d, h=magnet_h+1);
    }

    //  PCB STANDOFFS (To hold the board in the large case)
    
    intersection() {
        // Limit standoffs to inside the shell height
        translate([0,0,0]) rounded_box(walkman_w, walkman_d, seam_z, corner_rad);
        
        union() {
            for(mx = [-1,1], my = [-1,1]) {
                pcb_offset_x = -15; // Adjust this to shift left/right
              
                translate([(mx * pcb_mount_x) + pcb_offset_x, my * pcb_mount_y, wall])
                    difference() {
                        cylinder(d=6, h=4); // Post
                        cylinder(d=2.5, h=5); // Screw hole
                    }
            }
        }
    }
}


// BACK LID


module back_lid() {
    difference() {
        rounded_box(walkman_w, walkman_d, 4, corner_rad);
        
        // Lip to fit inside base
        translate([0,0,2])
             rounded_box(walkman_w - 2*wall - 0.4, walkman_d - 2*wall - 0.4, 3, corner_rad - wall);
             
        // Magnet holes
        for(x=[-1,1])
            translate([x*(walkman_w/2-magnet_offset), 0, 0])
                cylinder(d=magnet_d, h=10, center=true);
    }
}


// Button insert

module walkman_button() {
    // THE FLANGE 
    // This stays inside the case
    color("Silver")
    translate([0, 0, btn_flange_t/2])
        cube([btn_w + btn_flange_w, btn_h + btn_flange_w, btn_flange_t], center=true);

    // KEYCAP 
    color("DimGray")
    translate([0, 0, btn_flange_t])
    hull() {
        // Bottom  cap (at the flange)
        cube([btn_w - btn_clearance, btn_h - btn_clearance, 0.1], center=true);
        
        // Top cap 
        translate([0, 0, wall + btn_extrude])
            cube([btn_w - btn_clearance - 1, btn_h - btn_clearance - 0.5, 0.1], center=true);
    }
}

// RENDER: comment out shell or back_lid 
front_shell();
 //translate([0, 100, 0]) back_lid();
// Render the button next to the case
translate([0, -60, 0]) walkman_button();
