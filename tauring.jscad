// title: Rope Ring with inner-wall bug
// author: tobben
// based on work by: Eduard Bespalov
// license: MIT License
// description: creating twisted rope ring 
//              with intersecting faces around [0,0,0]
//              they all have normals ca [0,0,1] or [0,0,-1]
//              can be removed manually from ASCII-STL...

function main(params) {
    return union(
        cord(0),
        cord(120),
        cord(240));
}

function cord(delta){
    var sqrt3 = Math.sqrt(3) / 2;
    var radius = 0.75;
    var sqrt2 = 1/Math.sqrt(2);
    var sin225 = sin(45/2);
    var cos225 = cos(45/2);

	var hex = CSG.Polygon.createFromPoints([
			[radius, 0, 0],
            [radius*cos225, radius*sin225, 0],
            [radius*sqrt2,radius*sqrt2,0],
            [radius*sin225, radius*cos225, 0],
            [0,radius,0],
            [-radius*sin225, radius*cos225, 0],
            [-radius*sqrt2,radius*sqrt2,0],
            [-radius*cos225, radius*sin225, 0],
            [-radius,0,0],
            [-radius*cos225, -radius*sin225, 0],
            [-radius*sqrt2,-radius*sqrt2,0],
            [-radius*sin225, -radius*cos225, 0],
            [0,-radius,0],
            [radius*sin225, -radius*cos225, 0],
            [radius*sqrt2,-radius*sqrt2,0],
            [radius*cos225, -radius*sin225, 0]
	]);
	var angle = 1, //generate slice every x deg
		fingerRadius = 20,
		loops = 1,
        swing=0.9,
        twists=16;
	return hex.solidFromSlices({
		numslices: 360 * loops / angle+1,
		callback: function(t, slice) {
			return  this.translate([swing*sin(twists*angle*slice+delta), 
            swing*cos(twists*angle*slice+delta), 0]).rotate(
						[0,fingerRadius,0],
						[1, 0, 0],
						angle * slice);
		}
	});
}
