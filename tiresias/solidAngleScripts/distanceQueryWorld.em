/**
Creates several objects around the avatar.  Whenever the avatar is
more than 50 meters away, changes their meshes to be invisible.
 */


system.require('std/core/repeatingTimer.em');


//residentials
var initialPosition = system.self.getPosition();
var initialPres = system.self;

var allVisible = false;


//show me what I missed in the world
system.registerSandboxMessageHandler(function()
                                     {
                                         allVisible = true;
                                     },{::},null);


//check which presences should be made invisible, and which shouldn't.

//lamp post marker.  always stays visible.
LAMP_POST_MESH = 'meerkat:///kittyvision/streetlamp3.dae/optimized/0/streetlamp3.dae';
system.createPresence(
    {
        mesh: LAMP_POST_MESH,
        pos: initialPosition + new util.Vec3(2,0,0),
        orient: new util.Quaternion(0,0,0,1),
        scale: 10
    });




VISIBILITY_POLLING_PERIOD = .5;

var allPresences = [];
var RANGE_QUERY = 50;
var repTimer =
    new std.core.RepeatingTimer(
        VISIBILITY_POLLING_PERIOD,
        function()
        {
            var currentPos = initialPres.getPosition();
            for (var s in allPresences)
            {
                if (allVisible)
                    allPresences[s].setVisible();
                else
                {
                    var dist = (allPresences[s].getPosition() - currentPos).length();
                    if (dist < RANGE_QUERY)
                        allPresences[s].setVisible();
                    else
                        allPresences[s].setInvisible();                        
                }
            }
        });



function AllPresencesElement(pres)
{
    this.pres = pres;
    this.mesh = pres.getMesh();
    this.isVisible = true;
}

AllPresencesElement.prototype.setVisible = function()
{
    if (this.isVisible)
        return;
    this.pres.setMesh(this.mesh);
    this.isVisible = true;
};

AllPresencesElement.prototype.setInvisible = function()
{
    if (!this.isVisible)
        return;
    this.pres.setMesh("");
    this.isVisible = false;
};

AllPresencesElement.prototype.getPosition = function()
{
    return this.pres.getPosition();
};

function registerHidden()
{
    allPresences.push(new AllPresencesElement(system.self));
}



/*** Residential section ***/

RESIDENTIAL_OFFSET = new util.Vec3(80,0,0);
RESIDENTIAL_PADDING = 24;
RESIDENTIAL_SCALE = 10;
RESIDENTIAL_GRID_ROWS = 5;
RESIDENTIAL_GRID_COLS = 5;
RESIDENTIAL_MESHES =['meerkat:///kittyvision/house18.dae/optimized/0/house18.dae',
                     'meerkat:///kittyvision/house17.dae/optimized/0/house17.dae',
                     'meerkat:///kittyvision/house23.dae/optimized/0/house23.dae',
                     'meerkat:///kittyvision/house13.dae/optimized/0/house13.dae',
                     'meerkat:///kittyvision/house16.dae/optimized/0/house16.dae'];



for (var s = 0; s < RESIDENTIAL_GRID_ROWS; ++s)
{
    for (var t= 0; t < RESIDENTIAL_GRID_COLS; ++t)
    {
        var whichHouse = Math.floor(Math.random()*RESIDENTIAL_MESHES.length);
        if (whichHouse == RESIDENTIAL_MESHES.length)
            whichHouse -=1;
        
        var newPosition = RESIDENTIAL_OFFSET+initialPosition;
        newPosition.x += s*RESIDENTIAL_PADDING;
        newPosition.z += t*RESIDENTIAL_PADDING;
        system.createPresence(
            {
                mesh: RESIDENTIAL_MESHES[whichHouse],
                pos: newPosition,
                orient: new util.Quaternion(0,0,0,1),
                scale: RESIDENTIAL_SCALE,
                callback: registerHidden
            });
    }
}



//*** Eiffel tower and large building
NUM_EIFFELS = 5;
EIFFEL_OFFSET =  new util.Vec3(0,25,90);
EIFFEL_PADDING = 15;
EIFFEL_SCALE = 40;
EIFFEL_MESH = 'meerkat:///elliotconte/models/model.dae/optimized/1/model.dae';

for (var s =0; s < NUM_EIFFELS; ++s)
{
    var newPosition = EIFFEL_OFFSET;
    newPosition.x -= s*EIFFEL_PADDING;
    newPosition.z -= s*EIFFEL_PADDING;
    system.createPresence(
    {
        mesh: EIFFEL_MESH,
        pos: newPosition,
        orient: new util.Quaternion(0,0,0,1),
        scale: EIFFEL_SCALE,
        callback: registerHidden
    });        
}

NUM_BUILDINGS = 5;
BUILDING_OFFSET = new util.Vec3(0,10,145);
BUILDING_MESH = 'meerkat:///bmistree/models/model.dae/optimized/6/model.dae';
BUILDING_SCALE = EIFFEL_SCALE;
for (var s =0; s < NUM_BUILDINGS; ++s)
{
    var newPosition = BUILDING_OFFSET;
    newPosition.x += s*EIFFEL_PADDING;
    newPosition.z -= s*EIFFEL_PADDING;
    system.createPresence(
    {
        mesh: BUILDING_MESH,
        pos: newPosition,
        orient: new util.Quaternion(0,0,0,1),
        scale: EIFFEL_SCALE,
        callback: registerHidden
    });                
}




//robot (to battle godzilla)
'meerkat:///emily2e/models/robot.dae/optimized/0/robot.dae';

//rocket
'meerkat:///elliotconte/models/rocket.dae/optimized/0/rocket.dae';

//explosion
'meerkat:///elliotconte/models/Explosion2.dae/optimized/0/Explosion2.dae';

//godzilla
'meerkat:///emily2e/models/godzilla.dae/optimized/0/godzilla.dae';

//blimp
'meerkat:///emily2e/models/Goodyear.dae/optimized/0/Goodyear.dae';

