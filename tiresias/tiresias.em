
     
system.require('std/core/repeatingTimer.em');
system.require('std/core/simpleInput.em');

/**
 See README for usage explanation
 */

(function()
 {

     //right now, just an octopus.
     var TIRESIAS_MESH = "meerkat:///hoshoshoshosh/octopus_fixed.dae/optimized/0/octopus_fixed.dae";
     var TIRESIAS_POSITION_OFFSET = new util.Vec3(3,0,0);
     var TIRESIAS_PHYSICS = { treatment: 'ignore' };
     var FOLLOW_PERIOD = .5;

     var TIRESIAS_GUI_NAME = 'Tiresias the Guide';

     
     var allModules = {};
     var simpInput  = null;
     
     
     /**
      @param {presence} toGuide
      */
     Tiresias = function(toGuide)
     {
         this.toGuide = toGuide;
         

         //have to create a new presence for Tiresias.
         this.mPresence = null;
         system.createPresence(
             {
                 mesh: TIRESIAS_MESH,
                 scale: this.toGuide.getScale(),
                 pos: this.toGuide.getPosition() + TIRESIAS_POSITION_OFFSET,
                 physics: TIRESIAS_PHYSICS,
                 callback: std.core.bind(tiresiasConnected,undefined,this)
             }
         );
         this.graphicsRequested = false;
         this.graphicsInited = false;
         this.setupGraphics();
     };


     function tiresiasConnected(tiresiasObj)
     {
         tiresiasObj.mPresence = system.self;
         tiresiasObj.follow();
     }

     Tiresias.prototype.addModule = function(modToAdd)
     {
         allModules[modToAdd.modId] = modToAdd;
         this.redraw();         
     };


     var counter = 0;
     Tiresias.prototype.redraw = function()
     {
         var options = [];
         for (var s in allModules)
         {
             var toPush =
                 [allModules[s].moduleOptionText,allModules[s].modId];
             
             options.push(toPush);
         }

         ++counter;
     
         if (simpInput !== null)
         {
             simpInput.clear();
             simpInput = null;
         }

         simpInput = new std.core.SimpleInput(
             std.core.SimpleInput.SELECT_LIST,
             'Select an option ' + counter.toString(),
             std.core.bind(selectionMade,undefined,this),
             options);
     };

     
     //callback to list of selections
     function selectionMade(tiresias,whatSelected)
     {
         if (simpInput !== null)
             simpInput = null;
         
         if (!(whatSelected in allModules))
             throw new Error('Non-existent option selected');
         
         allModules[whatSelected].start();
     }
     
     /**
      should only be called once.  Sets up a repeating timer that
      re-adjusts the position of the following tiresias presence.
      */
     Tiresias.prototype.follow = function()
     {
         var followFunc = function(tireObj)
         {
             var curPos = tireObj.mPresence.getPosition();
             var avPos  = tireObj.toGuide.getPosition();
             var targetPos = avPos + TIRESIAS_POSITION_OFFSET;
             var newVel = (targetPos - curPos) / FOLLOW_PERIOD;
             tireObj.mPresence.setVelocity(newVel);
         };
         
         var repTimer = new std.core.RepeatingTimer(
             FOLLOW_PERIOD,std.core.bind(followFunc,undefined,this));
     };


     /**
      If have not already requested simulator to provide a graphics
      window, do so now.  If have requested graphics previously, but
      they are not init-ed yet, do nothing.

      Otherwise, go back to main display screen.
      */
     Tiresias.prototype.setupGraphics = function()
     {
         if (!this.graphicsRequested)
         {
             //have to actually add a module to the simulator for our
             //graphics
             this.guiMod = simulator._simulator.addGUITextModule(
                 TIRESIAS_GUI_NAME,
                 getTiresiasGuiText(),
                 std.core.bind(graphicsInitFunc,undefined,this));

             this.graphicsRequested = true;
             return;
         }


         //we requested graphics, but did not 
         if (!this.graphicsInited)
             return;


         system.__debugPrint('\nVery difficult question as to ' +
                           'what interface to provide between ' +
                           'interface and internal logic.  I am ' +
                           'guessing will want to make options for what is ' +
                           'displaying in window very pluggable.  ' +
                           'Then, this code drives which module is displayed.  ' +
                           'Does that make sense?\n');
         
     };

     function graphicsInitFunc(tireObj)
     {
         tireObj.graphicsInited = true;
         //gets to draw menu's default text.
         //may actually want a quick explanation of tiresias' purpose,
         //and what can actually do.
         tireObj.setupGraphics(); 
     }

     function getTiresiasGuiText()
     {
         var returner = "sirikata.ui('" + TIRESIAS_GUI_NAME + "',";
         returner += 'function(){ ';

         returner += @
         //gui for displaying friends list.
         $('<div>' +
           '</div>' //end div at top.
          ).attr({id:'tiresias-gui',title:'tiresiasHome'}).appendTo('body');

         
         var tiresiasWindow = new sirikata.ui.window(
            '#tiresias-gui',
            {
	        autoOpen: false,
	        height: 'auto',
	        width: 300,
                height: 400,
                position: 'right'
            }
         );
         tiresiasWindow.show();
         @;

         returner += '});';
         return returner;
     }
     
})();

