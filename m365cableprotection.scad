basewidth = 16.5;
baselength = 31.5;
baseheight = 7;
verticaloffset = -0.5;

innerwidth = 12.5;
innerlength = 27.5;

pipediameter1 = 42.5;
pipediameter2 = 52.5;
pipewallthickness = 4;

topwidth = 13;
toplength = 28;
topheight = 3;

// left side
cable1diameter = 4; 
cable1type = 1;
cable1width = 0;

cable2diameter = 5;
cable2type = 1;
cable2width = 0;

cable3diameter = 3.5;
cable3type = 2;
cable3width = 6.8;

/*
// right side
cable1diameter = 6.5; 
cable1type = 1;
cable1width = 0;

cable2diameter = 3.5;
cable2type = 2;
cable2width = 7;

cable3diameter = 0;
cable3type = 0;
cable3width = 0;
*/

cablespacing = 0.8;
cableangle = 40;

$fn = 60;

module baseform() {
    translate([0,0,-baseheight/2]) hull() {
        translate([ (baselength-basewidth)/2 ,0,0 ]) 
            cylinder(r=basewidth/2, h=baseheight);
        translate([ -(baselength-basewidth)/2 ,0,0 ]) 
            cylinder(r=basewidth/2, h=baseheight);
    }
}

module pipe() {
    translate([-baselength,0,-pipediameter1/2+pipewallthickness/2])
        rotate([0,90,0])
            difference() {
                resize([pipediameter1,pipediameter2,baselength*2])
                    cylinder(r=pipediameter1/2, h=baselength*2);
                resize( [   pipediameter1-2*pipewallthickness, 
                            pipediameter2-2*pipewallthickness,
                            baselength*2+2]
                )
                    translate([0,0,-1])
                        cylinder(r=pipediameter1/2-pipewallthickness, h=baselength*2);
            }
}

module groove() {
    difference() {
        pipe();
        hull() {
            translate([ (innerlength-innerwidth)/2 ,0,-baseheight ]) 
                cylinder(r=innerwidth/2, h=baseheight*2);
            translate([ -(innerlength-innerwidth)/2 ,0,-baseheight ]) 
                cylinder(r=innerwidth/2, h=baseheight*2);
        }
    }
}

module top() {
    difference() {
        hull() {
            translate([ (toplength-topwidth)/2, 0,0])
                resize([topwidth,topwidth,topheight*2]) 
                    sphere(r=topwidth);
            translate([ -(toplength-topwidth)/2, 0,0])
                resize([topwidth,topwidth,topheight*2]) 
                    sphere(r=topwidth);
        }
        translate([-toplength/2,-topwidth/2,-topheight]) 
            cube([toplength,topwidth,topheight]);
    }
}

function cable1space() = cable1diameter;
function cable2space() = (cable2diameter>0) ? cable2diameter+cablespacing : 0;
function cable3space() = (cable3diameter>0) ? cable3diameter+cablespacing : 0;
function allcablespace() = cable1space()+cable2space()+cable3space();

module cables() {
    rotate([0, -cableangle,0])
        translate([ -allcablespace()/2, 0,0])
            union() {
                cable1();
                translate([ cable1diameter+cablespacing ,0,0])
                    cable2();
                translate([ cable1diameter+cable2diameter+2*cablespacing ,0,0])
                    cable3();
            }
}

module cable1() {
    if (cable1diameter>0) {
        cable(type=cable1type, diameter=cable1diameter, width=cable1width);
    }
}
module cable2() {
    if (cable2diameter>0) {
        cable(type=cable2type, diameter=cable2diameter, width=cable2width);
    }
}
module cable3() {
    if (cable3diameter>0) {
        cable(type=cable3type, diameter=cable3diameter, width=cable3width);
    }
}

module cable(type, diameter, width) {
    if(type == 1) {
        singlecable(diameter=diameter);
    }
    if(type == 2) {
        doublecable(diameter=diameter,width=width);
    }
}

module singlecable(diameter) {
    translate([diameter/2,0,-2*baseheight]) 
        cylinder(r=diameter/2, h=4*baseheight+topheight);
}

module doublecable(diameter,width) {
    translate([diameter/2,0,-2*baseheight]) 
        union() {
            translate([0, (width-diameter)/2,0 ])
                cylinder(r=diameter/2, h=4*baseheight+topheight);
            translate([0, -(width-diameter)/2,0 ])
                cylinder(r=diameter/2, h=4*baseheight+topheight);
        }
}

module body() {
    difference() {
        union() {
            difference() {
                translate([0,0,verticaloffset]) baseform();
                #groove();
            }
            translate([0,0,baseheight/2+verticaloffset]) top();
        }
        #cables();
    }
}

body();