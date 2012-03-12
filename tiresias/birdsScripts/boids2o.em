//Originally written by Zhihong Xu as part of his 2011 summer project.  

system.require('std/core/repeatingTimer.em');
system.require('deltaTimer.em');

var nObstacles = 4;
var obstacles = new Array();


var nBoids = 10;
var speedLimit = 18;
var boidMesh = "meerkat:///kittyvision/models/pteranodon.dae/optimized/0/pteranodon.dae";
var obstacleMesh = 'meerkat:///elliotconte/models/DSTARIN.dae/optimized/1/DSTARIN.dae';



var timerPeriod = 0.02;
var maxPerchTime = 5;
var maxGoalTime = 10;
var goalTimer = maxGoalTime * util.rand();
var groundLevel = -10;

var viewer_pos = new util.Vec3(-50, 0, 50);
var viewer_orient = new util.Quaternion(0, 0, 0, 1);

var origin = new util.Vec3(-50, 0, 50);
var yaxis = new util.Vec3(0, 1, 0);
var xmin = origin.x - 20;
var xmax = origin.x + 20;
var ymin = origin.y - 9.7;
var ymax = origin.y + 20;
var zmin = origin.z - 40;
var zmax = origin.z;

var avatar = system.presences[0];
var boids = new Array();
var CD = new Array();
var CV = new Array();
var NC = new Array();
var dTimer = new my.deltaTimer();
var goal = new util.Vec3(rand(xmin, xmax), rand(ymin, ymax), rand(zmin, zmax));


//system.create_presence(terrainMesh, terrainInit);
createObstacles();
createBoids();

// function terrainInit(terrain) {
//     terrain.setPosition(new util.Vec3(origin.x, origin.y - 20, origin.z));
//     terrain.setScale(1000);
// }

function createObstacles() {
    system.__debugPrint('\nGot into createObstacles\n');
    for (var i = 0; i < nObstacles; i++) {
        system.create_presence(obstacleMesh, onObstacleCreation);
    }
}


// return a random number in [low, high)
function rand(low, high) {
    return util.rand() * (high - low) + low;
}

// return a random number in intervals [l1,h1) and [l2,h2) 
function randCoord(l1, h1, l2, h2) {
    var i1 = h1 - l1;
    var i2 = h2 - l2;
    if (util.rand() * (i1 + i2) < i1) {
        return rand(l1, h1);
    } else {
        return rand(l2, h2);
    }
}

function onObstacleCreation(newObstacle) {
    newObstacle.setScale(5);

    var record = new Object();

    record.radius = newObstacle.getScale();
    record.center = new util.Vec3(
        rand(xmin + record.radius, xmax - record.radius),
        rand(ymin + record.radius, ymax - record.radius),
        rand(zmin + record.radius, zmax - record.radius)
    );
    
    newObstacle.setPosition(record.center);
    
    obstacles.push(record);
}


// executed when a boid presence is created
function onBoidCreation(newBoid) {
    var dx = (xmax - xmin) * 0.125;
    var dy = (ymax - ymin) * 0.125;
    var dz = (zmax - zmin) * 0.125;

    var pos = new util.Vec3(
        randCoord(xmin, xmin + dx, xmax - dx, xmax),
        randCoord(ymin, ymin + dy, ymax - dy, ymax),
        randCoord(zmin, zmin + dz, zmax - dz, zmax)
    );
    
    newBoid.setScale(2);
    newBoid.setPosition(pos);
    newBoid.setVelocity(<0, 0, 0>);
    newBoid.V = new util.Vec3(rand(0,speedLimit), rand(0,speedLimit), rand(0,speedLimit));
    newBoid.tempV = newBoid.V;
    newBoid.up = yaxis;
    newBoid.towards = newBoid.V.normal();
    turn(newBoid, newBoid.towards, 100);
    newBoid.perching = false;
    newBoid.perch_timer = 0;
    
    boids.push(newBoid);
    
    if (boids.length == nBoids) {
        avatar.setPosition(viewer_pos);
        avatar.setOrientation(viewer_orient);
        var repTimer = new std.core.RepeatingTimer(timerPeriod, step);
    }
}

// create boids
function createBoids() {
    for (var i = 0; i < nBoids; i++) {
        system.create_presence(boidMesh, onBoidCreation);
    }    
}



function rulePerch(dt) {
    for (var i = 0; i < boids.length; i++) {
        if (boids[i].perching) {
            boids[i].perch_timer -= dt;
            if (boids[i].perch_timer <= 0) {
                boids[i].perching = false;
            }
        } else if (boids[i].position.y < groundLevel) {
            boids[i].towards = new util.Vec3(boids[i].towards.x, 0, boids[i].towards.z);
            boids[i].up = yaxis;
            boids[i].setPosition(<boids[i].position.x, groundLevel, boids[i].position.z>);
            boids[i].tempV = new util.Vec3(0, 0, 0);
            boids[i].perch_timer = maxPerchTime * util.rand();
            boids[i].perching = true;
        }   
    }
}


// boids keep some distance between each other
function ruleDist() {
    var thresholdDist = 2;

    for (var i = 0; i < boids.length; i++) {
        CD[i] = new util.Vec3(0, 0, 0);
        CV[i] = new util.Vec3(0, 0, 0);
        NC[i] = 0;
    }
    
    for (var i = 0; i < boids.length; i++) {
        for (var j = i + 1; j < boids.length; j++) {    
            var v = boids[i].position.sub(boids[j].position);
            var r2 = v.lengthSquared();
            var r = util.sqrt(r2);
            
            if (r < thresholdDist) {
                if (!boids[i].perching) {
                    boids[i].tempV = boids[i].tempV.add(v);
                }
                if (!boids[j].perching) {
                    boids[j].tempV = boids[j].tempV.sub(v);
                }
            }
            
            var x = 1 / r2;
            CD[i] = (CD[i]).add(boids[j].position.scale(x));
            CD[j] = (CD[j]).add(boids[i].position.scale(x));
            CV[i] = (CV[i]).add(boids[j].V.scale(x));
            CV[j] = (CV[j]).add(boids[i].V.scale(x));
            
            NC[i] += x;
            NC[j] += x;
        }
    }
    
    for (var i = 0; i < boids.length; i++) {
        CD[i] = (CD[i]).div(NC[i]);
        CV[i] = (CV[i]).div(NC[i]);
    }
}


// move a boid towards the centroid of other boids
function ruleCohesion() {
    for (var i = 0; i < boids.length; i++) {
        if (boids[i].perching) {
            continue;
        }
            
        var v = CD[i].sub(boids[i].position).scale(rand(0.008, 0.012));
        boids[i].tempV = boids[i].tempV.add(v); 
    }
}


// align a boid's velocity with the average velocity of other boids 
function ruleAlign() {    
    for (var i = 0; i < boids.length; i++) {
        if (boids[i].perching) {
            continue;
        }
        
        var v = CV[i].sub(boids[i].V).scale(rand(0.05, 0.12));
        boids[i].tempV = boids[i].tempV.add(v);
    }
}


// keep a boid within the bounds
function ruleBound() {
    var backtrackSpeed = 10;
    var v = new Object();
    for (var i = 0; i < boids.length; i++) {
        if (boids[i].perching) {
            continue;
        }
        if (boids[i].position.x < xmin) {
            v.x = backtrackSpeed;
        } else if (boids[i].position.x > xmax) {
            v.x = -backtrackSpeed;
        } else {
            v.x = 0;
        }
        
        if (boids[i].position.y < ymin) {
            v.y = backtrackSpeed;
        } else if (boids[i].position.y > ymax) {
            v.y = -backtrackSpeed;
        } else {
            v.y = 0;
        }
        
        if (boids[i].position.z < zmin) {
            v.z = backtrackSpeed;
        } else if (boids[i].position.z > zmax) {
            v.z = -backtrackSpeed;
        } else {
            v.z = 0;
        }
        
        boids[i].tempV = boids[i].tempV.add(new util.Vec3(v.x, v.y, v.z));
    }
}


function ruleGoal(dt) {
    if (goalTimer <= 0) {
        goal = new util.Vec3(rand(xmin, xmax), rand(ymin, ymax), rand(zmin, zmax));
        goalTimer = maxGoalTime * util.rand();
    } else {
        goalTimer -= dt;
    }
    
    for (var i = 0; i < boids.length; i++) {
        if (boids[i].perching) {
            continue;
        }
        var v = goal.sub(boids[i].position);
        boids[i].tempV = boids[i].tempV.add(v.scale(0.03));
    }
}


function lookat(towards, upHint) {
    var right = towards.cross(upHint).normal();
    var up = right.cross(towards).normal();
    var angle = - util.acos((right.x + up.y - towards.z - 1) * 0.5);
    var axis = (new util.Vec3(-towards.y - up.z, right.z + towards.x, up.x - right.y)).normal();
    return new util.Quaternion(axis, angle);
}


// turn boid to direction towards
function turn(boid, towards, dt) {
    var right;
    if (towards.length() < 1e-8) {
        towards = boid.towards.normal();
    }
    
    var dut = util.acos(towards.dot(boid.towards));
    if (dut > 2.5 * dt) {
        var factor = 2.5 * dt / dut;
        towards = towards.scale(factor).add(boid.towards.scale(1 - factor)).normal();
    }
    
    
    if (util.abs(towards.x) < 1e-8 && util.abs(towards.z) < 1e-8) { // boid parallel to y axis, use old up
        right = towards.cross(boid.up).normal();
    } else {
        right = towards.cross(yaxis).normal();
    }
    
    var up = right.cross(towards).normal();
    var dua = util.acos(up.dot(boid.up));
    if (dua > 3.14 * dt) {
        var factor = 3.14 * dt / dua;
        up = up.scale(factor).add(boid.up.scale(1 - factor)).normal();
        right = towards.cross(up).normal();
    }
    
    up = up.normal();
    right = right.normal();
    towards = towards.normal();
    boid.up = up;
    boid.towards = towards;

    var angleArg = (right.x + up.y - towards.z - 1) * 0.5;
    //errors in math precision can cause >1, <-1...just clamp instead.
    if (angleArg > 1)
        angleArg = 1;
    else if (angleArg < -1)
        angleArg = -1;
    var angle = - util.acos(angleArg);
    //var angle = - util.acos((right.x + up.y - towards.z - 1) * 0.5);
    //system.print(((right.x + up.y - towards.z - 1) * 0.5).toString() + "\n");
    var axis = (new util.Vec3(-towards.y - up.z, right.z + towards.x, up.x - right.y)).normal();

    var quater = new util.Quaternion(axis, angle)
    
    boid.setOrientation(new util.Quaternion(axis, angle));
}

// perform one step of simulation
function step() {
    
    var dt = dTimer.getDeltaTime();
    if (dt <= 0) {
        return;
    }
    
    rulePerch(dt);
    ruleDist();
    ruleBound();
    ruleCohesion();
    ruleAlign();
    ruleGoal(dt);
    
    for (var i = 0; i < boids.length; i++) {
        
        var timeLeft = dt;
        var speed = boids[i].tempV.length();
        if (speed > speedLimit) {
            boids[i].tempV = boids[i].tempV.scale(speedLimit / speed);
        }
        boids[i].V = boids[i].tempV;
        
        var old_pos = boids[i].getPosition();
        var P = boids[i].V.normal();
        var r = boids[i].getScale();

        for (var j = 0; j < obstacles.length; j++) {
            var D = r + obstacles[j].radius;
            var OC = old_pos.sub(obstacles[j].center);    
            var b = 2 * OC.dot(P);
            var c = OC.lengthSquared() - D * D;
            var determinant = b * b - 4 * c;
            if (determinant <= 0) {
                continue;
            }
            
            speed = boids[i].V.length();
            var t = -(b + util.sqrt(determinant)) / 2 / speed;
            
            
            if (t < 0 || t > timeLeft) {
                continue;
            }
            
            timeLeft -= t;
            old_pos = old_pos.add(P.scale(t));
            var N = old_pos.sub(obstacles[j].center).normal();
            var newV = N.scale(-N.dot(P)).add(P).normal().scale(speed);
            boids[i].V = newV;
            boids[i].tempV = newV;
            break;
        }
        var new_pos = old_pos.add(boids[i].V.scale(timeLeft));

        boids[i].setPosition(new_pos);
        turn(boids[i], boids[i].V, dt);
    }
}





