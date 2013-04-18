use <write/Write.scad>
use <utils/build_plate.scad>
/* [Nike Data] */
// Hourly  points for cube rendering
dailyActivity = [] ;
// As points for polygon rendering
dailyActivityPoints = [[[0, -0.01], [0, 56], [1, 72], [2, 13], [3, 0], [4, 0], [5, 0], [6, 1], [7, 3], [8, 160], [9, 151], [10, 726], [11, 242], [12, 46], [13, 292], [14, 41], [15, 18], [16, 136], [17, 29], [18, 390], [19, 555], [20, 93], [21, 106], [22, 48], [23, 85], [24, -0.01]], [[0, -0.01], [0, 198], [1, 12], [2, 3], [3, 1], [4, 1], [5, 0], [6, 1], [7, 1], [8, 0], [9, 171], [10, 93], [11, 120], [12, 190], [13, 67], [14, 292], [15, 282], [16, 142], [17, 137], [18, 144], [19, 228], [20, 173], [21, 81], [22, 111], [23, 197], [24, -0.01]], [[0, -0.01], [0, 343], [1, 71], [2, 61], [3, 3], [4, 0], [5, 4], [6, 1], [7, 1], [8, 1], [9, 85], [10, 148], [11, 300], [12, 225], [13, 328], [14, 57], [15, 80], [16, 54], [17, 299], [18, 188], [19, 95], [20, 163], [21, 166], [22, 14], [23, 90], [24, -0.01]], [[0, -0.01], [0, 206], [1, 15], [2, 2], [3, 0], [4, 0], [5, 1], [6, 2], [7, 7], [8, 147], [9, 347], [10, 694], [11, 132], [12, 100], [13, 31], [14, 137], [15, 197], [16, 58], [17, 82], [18, 445], [19, 698], [20, 474], [21, 279], [22, 471], [23, 92], [24, -0.01]], [[0, -0.01], [0, 82], [1, 0], [2, 3], [3, 2], [4, 0], [5, 0], [6, 0], [7, 22], [8, 301], [9, 688], [10, 187], [11, 110], [12, 51], [13, 300], [14, 13], [15, 54], [16, 75], [17, 383], [18, 620], [19, 282], [20, 256], [21, 124], [22, 105], [23, 52], [24, -0.01]], [[0, -0.01], [0, 86], [1, 4], [2, 0], [3, 4], [4, 0], [5, 0], [6, 6], [7, 6], [8, 221], [9, 434], [10, 506], [11, 140], [12, 113], [13, 37], [14, 265], [15, 205], [16, 89], [17, 86], [18, 385], [19, 286], [20, 234], [21, 442], [22, 720], [23, 56], [24, -0.01]], [[0, -0.01], [0, 106], [1, 7], [2, 3], [3, 0], [4, 0], [5, 0], [6, 1], [7, 35], [8, 290], [9, 678], [10, 332], [11, 184], [12, 78], [13, 14], [14, 110], [15, 67], [16, 359], [17, 27], [18, 173], [19, 721], [20, 227], [21, 195], [22, 12], [23, 6], [24, -0.01]]] ;
// Daily  point totals
dailytotal = [3263, 2645, 2777, 4617, 3710, 4325, 3625] ;
// Scale height of data
heightScale = 0.1;
//  point goal
target = 0 ;
// Start date
startDate = "" ;
// End date
endDate = "" ;
// User name
name = "" ;
// Which one would you like to see?
part = "both"; // [both:One color,left:First color,right:Second color]
/* [Scale] */
// Left to right size
width = 200;
// Front to back size (not counting label)
height = 100;
// Scale height of data (0.1 means 0.1mm per Fuel point)
heightScale = 0.1;
// Scale height of totals (0.01 means 0.01mm per Fuel point)
totalScale = 0.01;
// Daily Fuel bar width
dailyWidthScale = 1.01; //[0.5:Narrow, 0.9:Wide, 1.01:Continuous]
// Thickness of base
baseH = 2;
// Wall thickness (vertical charts @ back)
wall = 5;
//label height
labelH = 10;
//label margin (adjust to make dates look good)
labelM = 20;
/* [Buid Plate] */
//for display only, doesn't contribute to final object
build_plate_selector = 0; //[0:Replicator 2,1: Replicator,2:Thingomatic,3:Manual]
//when Build Plate Selector is set to "manual" this controls the build plate x dimension
build_plate_manual_x = 100; //[100:400]
//when Build Plate Selector is set to "manual" this controls the build plate y dimension
build_plate_manual_y = 100; //[100:400]
numDays = max(len(dailyActivity), len(dailyActivityPoints));
if (len(dailyActivity)>0) {
        numSamples = len(dailyActivity[0]);
        }
if (len(dailyActivityPoints)>0) {
        numSamples = len(dailyActivityPoints[0]);
        }
fontH = labelH*0.7;
middle=width/2;
left = labelM;
right = width-labelM;
dateH = fontH*.7;
xscale = width / numDays;
yscale = height / numSamples;
g=0.01*1;
echo(str(numDays," days with ", numSamples," samples. xscale ",xscale," yscale ",yscale,"."));
od = 20;
thick = 4;
plush = 1;
pgap = 15;
pluslen = od*.7;
plusthick = 3;
gapangle = 26;
module plus() {
        difference() {
                cylinder(r=od,h=plush);
                translate([0,0,-1]) cylinder(r=od-thick,h=plush+2);
                translate([-pgap/2,-od-1,-1]) cube([pgap,od+1,plush+2]);
                rotate([0,0,gapangle]) translate([-thick,-od-1,-1]) cube([thick,thick+2,plush+2]);
                rotate([0,0,-gapangle]) translate([0,-od-1,-1]) cube([thick,thick+2,plush+2]);
                }
        rotate([0,0,gapangle]) translate([0,-(od-thick/2),0]) cylinder(r=thick/2,h=plush);
        rotate([0,0,-gapangle]) translate([0,-(od-thick/2),0]) cylinder(r=thick/2,h=plush);
        rotate([0,0,-15]) {
                translate([-plusthick/2,-pluslen/2,0]) cube([plusthick,pluslen,plush]);
                translate([0,pluslen/2,0]) cylinder(r=plusthick/2,plush);
                translate([0,-pluslen/2,0]) cylinder(r=plusthick/2,plush);
                }
        rotate([0,0,90]) {
                translate([-plusthick/2,-pluslen/2,0]) cube([plusthick,pluslen,plush]);
                translate([0,pluslen/2,0]) cylinder(r=plusthick/2,plush);
                translate([0,-pluslen/2,0]) cylinder(r=plusthick/2,plush);
                }
        }
plusscale = (labelH-2)/(2*od);
echo("plus scale",plusscale);
module printIt() {
        // base
        if ((part=="both") || (part=="right")) color("blue") {
                translate([0,-labelH,0]) cube([width+g,height+labelH+3*wall+g,baseH]);
                }
        // labels
        if ((part=="both") || (part=="left")) color("white") {
                translate([middle,-labelH/2,baseH]) color("white") write(name, h=fontH, center=true);
                translate([left,-labelH/2,baseH]) color("white") write(startDate, h=dateH, center=true);
                translate([right,-labelH/2,baseH]) color("white") write(endDate, h=dateH, center=true);
                translate([labelH/2,-labelH/2,baseH]) scale([plusscale,plusscale,1]) plus();
                }
        // daily activity
        if ((part=="both") || (part=="left")) color("white") {
                for (day = [0:numDays-1]) {
                        assign (xpos = day*xscale) {
                                if (len(dailyActivity)>0) { // show daily blocks
                                        for (sample = [0:numSamples-1]) {
                                                assign (ypos = sample*yscale) {
                                                        translate([width-xpos-xscale,ypos,baseH]) cube([xscale+g,yscale+g,
                                                                heightScale*(dailyActivity[day][sample-1]+dailyActivity[day][sample]+dailyActivity[day][sample+1])/3 ]);
                                                        }
                                                }
                                        }
                                else {
                                        translate([width-xpos-xscale,0,baseH])
                                                scale([xscale,yscale,heightScale])
                                                rotate([90,0,90])
                                                linear_extrude(height = 1, center = false, convexity = 0, twist = 0, slices = 10) {
                                                        polygon(
                                                                points=dailyActivityPoints[day]);
                                                        }
                                                }
                                        }
                                translate([width-xpos-xscale,height+wall,baseH]) cube([dailyWidthScale*xscale,wall,totalScale*dailytotal[day]]);
                                }
                        }
                }
        // hand coded row of data for testing. Inject above when we have real data.
//,
//                      paths = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,0]
        if ((part=="both") || (part=="right")) color("blue") {
                translate([0,height+2*wall,baseH]) cube([width+g,wall,totalScale*target]);
                }
        }
        translate([-middle,-height/2-labelH/2,0]) printIt();
        build_plate(build_plate_selector,build_plate_manual_x,build_plate_manual_y);