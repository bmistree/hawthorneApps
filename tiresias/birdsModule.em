
system.require('module.em');

(function()
{

    var BIRDS_GUI_NAME = 'birdsModule';
    var birdsSandbox = null;
    
    
    addBirdsModule = function(tiresiasObj)
    {
        var birdsMod = new TiresiasModule('release the birds!');

        birdsMod.graphicsInit = false;
        birdsMod.guiMod = simulator._simulator.addGUITextModule(
             BIRDS_GUI_NAME,
             getBirdsHtml(),
             std.core.bind(graphicsInitFunc,undefined,birdsMod));

        birdsMod.start = std.core.bind(
             startBirdsMod,undefined,birdsMod);
        birdsMod.stop  = std.core.bind(
             stopBirdsMod,undefined,birdsMod);

        tiresiasObj.addModule(birdsMod);
    };

    function graphicsInitFunc(birdsMod)
    {
        birdsMod.graphicsInit = true;

        birdsMod.guiMod.bind(
            'beginFlyingBirds',
            std.core.bind(hBeginFlyingBirds,undefined,birdsMod));
    }

    function hBeginFlyingBirds(birdsMod)
    {
        if (birdsSandbox !== null)
            return;

        var caps = new util.Capabilities(util.Capabilities.IMPORT,
                                         util.Capabilities.CREATE_PRESENCE,
                                         util.Capabilities.MOVEMENT);

        
        birdsSandbox = caps.createSandbox(system.self,null);
        birdsSandbox.execute(
            function()
            {
                var BIRDS_SCRIPT_FILENAME = 'gitHawthorne/tiresias/birdsScripts/boids2o.em';
                system.import(BIRDS_SCRIPT_FILENAME);
            });

    }


    function startBirdsMod(birdsMod)
     {
         if (!birdsMod.graphicsInit)
         {
             throw new Error('Error starting birds module.  ' +
                             'Graphics were not yet initialized for display.');
         }
         birdsMod.guiMod.call('startBirds');
     }


     function stopBirdsMod(birdsMod)
     {
         if (!birdsMod.graphicsInit)
         {
             throw new Error('Error stopping birds module.  ' +
                             'Graphics were not yet initialized for display.');
         }
         birdsMod.guiMod.call('stopBirds');
     }
     
 
     function getBirdsHtml(birdsMod)
     {
         var returner = "sirikata.ui('" + BIRDS_GUI_NAME + "',";
         returner += 'function(){ ';

         returner += @

         $('<div>'       +
           '<p>Sirikata incorporates Emerson, a JavaScript-based scripting language ' +
           'with which ' +
           'users can control objects in the virtual world.  Over the ' +
           'summer of 2011, 11 undergraduates built applications with ' +
           'Emerson in-world.</p>' +
           
           '<p>This is a swarming example of one of those ' +
           'applications.  One of the defining features of Emerson is that '+
           'it allows and simplifies managing multiple objects in the world ' +
           'from a single script.  This simplifies discovery between objects ' +
           'as well as coordination.  As an example considering the swarm above, ' +
           'coordination just requires function calls, the scripter is ' +
           'not required to send messages over the network.  As a result, ' +
           'his flock of pterodactyls application does not have to deal with packet loss ' +
           'in the network, message re-ordering, consistency issues, and ' +
           'all the other challenges associated with distributed applications</p>' +
           
           '</div>' //end div at top.
          ).attr({id:'birds',title:'birds'}).appendTo('body');

         var birdsWindow = new sirikata.ui.window(
             '#birds',
             {
	        autoOpen:   false,
	        height:    'auto',
	        width:        300,
                height:       400,
                position: 'right'
            }
         );
         birdsWindow.hide();


         startBirds = function()
         {
             birdsWindow.show();
             sirikata.event('beginFlyingBirds');
         };

         stopBirds = function()
         {
             birdsWindow.hide();
         };
         @;

         returner += '});';
         return returner;
     }
        

})();
