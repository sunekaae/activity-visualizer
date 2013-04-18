use <write/Write.scad>
use <utils/build_plate.scad>

/* [Hidden] */

// Hourly  points for cube rendering
dailyActivity = *****DETAIL***** ;

// Format of activity data
dailyActivityFormat = *****FORMAT***** ; //[values:Values, points:Points for polygon]

// Daily  point totals 
dailytotal = *****TOTAL***** ;

// Badges (array of daily badges)
badge = *****BADGES***** ;
// e.g. [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0];
// 0 - none
// 1 - Nike+
// 2 - Square
// 3 - Sphere

// Start date
startDate = *****START***** ;

// End date
endDate = *****END***** ;

/* [Nike Data] */

// Fuel point goal
target = *****TARGET***** ;

// Label (e.g. Robert 104,329)
name = *****NAME***** ;

// Which one would you like to see?
part = "both"; // [both:One color,left:First color,right:Second color]

// Print ears to hold the corners down
ears = 1; // [0:No ears, 1:Ears]

// Ear size
earSize = 10;

// Ear height
earHeight = 0.4;

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
dailyWidthScale = 0.5; //[0.5:Narrow, 0.9:Wide, 1.01:Continuous]

// Thickness of base
baseH = 2;

// Wall thickness (vertical charts @ back)
wall = 5;

//label height
labelH = 10;

//label margin (adjust to make dates look good)
labelM = 20;

// Thickness of badge
badgeThickness = 0.5;

/* [Buid Plate] */

//for display only, doesn't contribute to final object
build_plate_selector = 0; //[0:Replicator 2,1: Replicator,2:Thingomatic,3:Manual]

//when Build Plate Selector is set to "manual" this controls the build plate x dimension
build_plate_manual_x = 100; //[100:400]

//when Build Plate Selector is set to "manual" this controls the build plate y dimension
build_plate_manual_y = 100; //[100:400]

numDays = len(dailyActivity);

numSamples = len(dailyActivity[0]);

fontH = labelH*0.7;
middle=width/2;
left = labelM+labelH; // leave room for Nike + logo
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

module badge(badge) {
	if (badge == 1) {
		plus();
		echo("plus");
		}
	if (badge == 2) {
		translate([-od,-od,0]) cube([2*od, 2*od, plush]);
		echo("square");
		}
	if (badge == 3) {
		scale([1,1,0.2]) sphere(r=od);
		echo("sphere");
		}
	}

plusscale = (labelH-2)/(2*od);
plusawardscale = (dailyWidthScale*xscale-2)/(2*od);
echo("plus scale",plusscale);

module ear() {
	if (ears == 1) cylinder(r=earSize, h=earHeight);
	}

module printIt() {

	// base

	if ((part=="both") || (part=="right")) color("blue") {
		translate([0,-labelH,0]) cube([width+g,height+labelH+3*wall+g,baseH]);
		translate([0,-labelH]) ear();
		translate([width+g,-labelH]) ear();
		translate([0,height+labelH+wall+g]) ear();
		translate([width+g,height+labelH+wall+g]) ear();
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
				if (dailyActivityFormat == "values") { // draw activity using blocks
					for (sample = [0:numSamples-1]) {
						assign (ypos = sample*yscale) {
							translate([width-xpos-xscale,ypos,baseH]) cube([xscale+g,yscale+g,
								heightScale*(dailyActivity[day][sample-1]+dailyActivity[day][sample]+dailyActivity[day][sample+1])/3 ]);
							}
						}
					}
				else { // draw polygons
					translate([width-xpos-xscale,0,baseH]) 
						scale([xscale,yscale,heightScale])
						rotate([90,0,90])
						linear_extrude(height = 1.01, center = false, convexity = 0, twist = 0, slices = 10) {
							polygon(
								points=dailyActivity[day]);
							}
					}
				translate([width-xpos-xscale+(xscale - dailyWidthScale*xscale)/2,height+wall,baseH]) cube([dailyWidthScale*xscale,wall,totalScale*dailytotal[day]]);
				// draw badges for the days
				if (len(badge)>0) if (badge[day]>0) {
					echo(str("badge day ",day));
					translate([width-xpos-dailyWidthScale*xscale/2-0.5,
							height+wall+g,
							baseH+totalScale*dailytotal[day]-dailyWidthScale*xscale/2])
						rotate([90,0,0]) 
							scale([plusawardscale,plusawardscale,badgeThickness]) badge(badge[day]);
					}
				}
			}
		}

	if ((part=="both") || (part=="right")) color("blue") {
		translate([0,height+2*wall,baseH]) cube([width+g,wall,totalScale*target]);
		}
	}

	translate([-middle,-height/2-labelH/2,0]) printIt();

	build_plate(build_plate_selector,build_plate_manual_x,build_plate_manual_y);

