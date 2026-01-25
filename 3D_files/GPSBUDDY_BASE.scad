// GPS_BUDDY CASE 

$fn = 72;

// External case dimensions 
case_w = 120;
case_d = 65;
case_h = 39; //depth of case
corner_rad = 11;

// PCB standoffs (ElectroCookie)  
pcb_width  = 78.5; 
pcb_depth  = 36.0;
pcb_shift_x = -10;  // Horizontal shift
standoff_d  = 4.5;    // Narrowed for M2 compatibility
screw_hole_d = 1.8;   // fit for M2 screw threads
standoff_h  = 4.0;    // Height of the post


//Internal dims
wall = 2.2;
seam_z = 16.0;          // Height of the front shell

//  OLED 
oled_w = 36;
oled_h = 20;
oled_x = -10;    // Centered horizontally 
oled_y = 4;

//  BUTTONS 
btn_diam = 7;
btn_spacing = 25;
btn_z = 6.0;          // Define height from the floor
btn_w = 6;          // Width of the rectangle
btn_h = 10;         // Height of the rectangle

// USB
usb_w = 8;
usb_h = 3.5;
usb_z = 8.5;

//  MAGNETS FOR BACKPLATE
magnet_d = 6.2;
magnet_h = 3;
magnet_offset = 12;

// BUTTON KEYCAP
btn_clearance = 0.4;    // Gap between button and hole (0.2-0.4 is  good)
btn_extrude = 3.0;      // How far button sticks out of the case
btn_flange_w = 2.0;     // How much wider the base is (prevents falling through)
btn_flange_t = 1.5;     // Thickness of base plate

//Back lid Parameters for Bambu A1 Mini 
tolerance = 0.2; // 0.2mm is standard for a snug fit on Bambu Lab
lid_plate_h = 2.5; 
lip_h = 2.0;




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
        rounded_box(case_w, case_d, case_h, corner_rad);

        // BACK CUT OUT
        translate([0,0,seam_z + case_h/2])
            cube([case_w+40, case_d+40, case_h], center=true);

        // TRUE HOLLOW CAVITY
        
        translate([0,0,wall])
            rounded_box(case_w - 2*wall, case_d - 2*wall, case_h, corner_rad - wall);

        // OLED CUTOUT
        // Cuts through floor (Z=0) to inside
        translate([oled_x, oled_y, -1])
            rounded_box(oled_w, oled_h, wall*3, 2);

        // USB CUTOUT
        translate([-case_w/2, 0, wall+usb_z])
            rotate([0,90,0])
            rotate([0,0,90])
            pill(usb_w, usb_h, 20);

        // BUTTON HOLES
        for(i=[-1,1])
           // translate([i*btn_spacing/2, -case_d/2, wall+btn_z]) // adds buttons to top side
              //  rotate([0,90,0])
              //  rotate([90,0,0])
              //  cube([btn_w, btn_h, 20], center=true);
            translate([oled_x + (i * btn_spacing/2), oled_y - 20, -1])
                rotate([0,0,90])
                rounded_box(btn_w, btn_h, wall*3, 2);
          
                
        // MAGNET POCKETS
        for(x=[-1,1])
            translate([x*(case_w/2-magnet_offset), 0, seam_z-magnet_h])
                cylinder(d=magnet_d, h=magnet_h+1);
    }

    //  PCB STANDOFFS
    intersection() {
    // Limits standoffs to the inside of the shell
    translate([0,0,0]) rounded_box(case_w, case_d, seam_z, corner_rad);
    
    union() {
        for(mx = [-1, 1], my = [-1, 1]) {
            // Apply the shift and the half-distances
            translate([(mx * pcb_width/2) + pcb_shift_x, my * pcb_depth/2, wall]) {
                difference() {
                    // Outer Post
                    cylinder(d=standoff_d, h=standoff_h); 
                    
                    // M2 Screw Hole
                    translate([0, 0, -0.1])
                        cylinder(d=screw_hole_d, h=standoff_h + 0.2);
                }
            }
        }
    }
}
}


// BACK LID
module back_lid() {
    difference() {
        // THE BODY
        union() {
            // Exterior visible plate
            rounded_box(case_w, case_d, lid_plate_h, corner_rad);
            
            // The insert lip (shrunk by tolerance on all sides)
            translate([0, 0, lid_plate_h])
                rounded_box(case_w - 2*wall - tolerance, 
                            case_d - 2*wall - tolerance, 
                            lip_h, 
                            corner_rad - wall);
        }

        // MAGNET POCKETS 
        for(x=[-1,1])
            translate([x*(case_w/2 - magnet_offset), 0, lid_plate_h + lip_h - magnet_h])
                // +0.1 on diameter for easier magnet insertion
                cylinder(d=magnet_d + 0.1, h=magnet_h + 0.1); 
    }
}

// Button insert
module push_button() {
    b_w = btn_w - btn_clearance;
    b_h = btn_h - btn_clearance;
    b_r = 2 - (btn_clearance/2); // Adjust radius for clearance

    // THE FLANGE (Inside the case)
    color("Silver")
    translate([0, 0, 0])
        rounded_box(btn_w + btn_flange_w, btn_h + btn_flange_w, btn_flange_t, 2);

    // KEYCAP
    color("DimGray")
    translate([0, 0, btn_flange_t])
    hull() {
        // Bottom of cap (at the flange)
        rounded_box(b_w, b_h, 0.1, b_r);
        
        // Top of cap (at the surface)
        translate([0, 0, wall + btn_extrude])
            rounded_box(b_w, b_h, 0.1, b_r);
    }
}

// RENDER: comment out shell or back_lid 
//front_shell();
translate([0, 100, 0]) back_lid();
// Render the buttons next to the case
//translate([0, -60, 0]) push_button();
//translate([0, -80, 0]) push_button();
// uncomment bottom to check alignment 
//% translate([-15, 0, wall+4]) square([78.5, 36.0], center=true);
