
system.require('module.em');

(function()
 {
     var SOLID_ANGLE_GUI_NAME = 'solidAngleModule';
     var tiresiasObj = null;
     var previousPosition = null;
     var displacementOffset = new util.Vec3(1000,0,0);

     
     addSolidAngleModule = function (tObj)
     {
         tiresiasObj = tObj;
         var solidAngleMod =
             new TiresiasModule('How does discovery work (note this will teleport you briefly)?');

         solidAngleMod.graphicsInit = false;
         
         solidAngleMod.guiMod = simulator._simulator.addGUITextModule(
             SOLID_ANGLE_GUI_NAME,
             getSolidAngleHtml(),
             std.core.bind(graphicsInitFunc,undefined,solidAngleMod));
         
         solidAngleMod.start = std.core.bind(
             startSolidAngleMod,undefined,solidAngleMod);
         solidAngleMod.stop  = std.core.bind(
             stopSolidAngleMod,undefined,solidAngleMod);

         tiresiasObj.addModule(solidAngleMod);
         
     };


     function graphicsInitFunc(solidAngleMod)
     {
         solidAngleMod.graphicsInit = true;

         solidAngleMod.guiMod.bind(
             'killSolidAngle',
             std.core.bind(hKillSolidAngle,undefined,solidAngleMod));        
     }


     function hKillSolidAngle(solidAngleMod)
     {
         tiresiasObj.mPresence.setPosition(previousPosition);
         tiresiasObj.redraw();         
     }

     
     function startSolidAngleMod(solidAngleMod)
     {
         if (!solidAngleMod.graphicsInit)
         {
             throw new Error('Error starting solid angle module.  ' +
                             'Graphics were not yet initialized for display.');
         }
         solidAngleMod.guiMod.call('startSolidAngle');

         previousPosition = tiresiasObj.mPresence.getPosition();
         tiresiasObj.mPresence.setPosition(previousPosition + displacementOffset);
     }


     function stopSolidAngleMod(solidAngleMod)
     {
         if (!solidAngleMod.graphicsInit)
         {
             throw new Error('Error stopping solidAngle module.  ' +
                             'Graphics were not yet initialized for display.');
         }
         solidAngleMod.guiMod.call('stopSolidAngle');
     }
     

     function getSolidAngleHtml(solidAngleMod)
     {
         var returner = "sirikata.ui('" + SOLID_ANGLE_GUI_NAME + "',";
         returner += 'function(){ ';

         returner += @

         $('<div>'       +
           '<p>Many virtual worlds use a <i>range query</i> ("return all ' +
           'objects within <i>n</i> meters") to display content.</p>  ' +
           
           '<p>We are currently simulating this type of query for <i>n</i>=50.  ' +
           'Move around and notice how this effect distorts your view of ' +
           'the world.  You should be able to see a few small objects nearby, ' +
           'such as a lamp post, but have difficulty seeing distant, ' +
           'large objects (see if you can find Godzilla or the set of large ' +
           'buildings around you by moving around).  Notice how large objects seem ' +
           'to "pop" in and out, marring the virtual world metaphor.</p>' +
           
           '<p>Instead of using a range query, Sirikata uses a <i>solid angle ' +
           'query</i> (roughly, "return all objects that take up more than <i>x</i> '+
           'pixels on a viewer\\'s monitor").   The technical challenge of this ' +
           'approach is that we turn what had been a local query (check for ' +
           'objects within an <i>n</i> meter radius of the querier on my server ' +
           'and each of my neighbor servers) into a potentially global query over all servers ' +
           'in the system.  This is because an object thousands of meters away ' +
           'can still satisfy a solid angle query, if large enough.</p>' +

           '<p>Sirikata uses a novel modification of Bounding Volume Hierarchies '+
           'to conservatively cull which servers a querier needs to contact.  This ' +
           'allows the world to scale while still providing solid angle queries.</p>' +
           '</div>' //end div at top.
          ).attr({id:'solidAngle',title:'solidAngle'}).appendTo('body');

         var dialogOpen = false;
         var solidAngleWindow = new sirikata.ui.window(
             '#solidAngle',
             {
	         autoOpen:   false,
	         height:    'auto',
	         width:        300,
                 height:       400,
                 position: 'right',
                 beforeClose: function(event,ui)
                 {
                     if (dialogOpen)
                         sirikata.event('killSolidAngle');
                     dialogOpen = false;
                 }
            }
         );
         solidAngleWindow.hide();


         startSolidAngle = function()
         {
             dialogOpen = true;
             solidAngleWindow.show();
         };

         stopSolidAngle = function()
         {
             dialogOpen = false;
             solidAngleWindow.hide();
         };
         
         @;

         returner += '});';
         return returner;
     }
 })();

