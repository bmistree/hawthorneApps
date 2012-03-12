
system.require('module.em');

(function()
 {
     var CONTROLS_GUI_NAME = 'controlsModule';
     var tiresiasObj = null;
     
     addControlsModule = function (tObj)
     {
         tiresiasObj = tObj;
         var controlsMod =
             new TiresiasModule('What are the controls?');

         controlsMod.graphicsInit = false;
         
         controlsMod.guiMod = simulator._simulator.addGUITextModule(
             CONTROLS_GUI_NAME,
             getControlsHtml(),
             std.core.bind(graphicsInitFunc,undefined,controlsMod));
         
         controlsMod.start = std.core.bind(
             startControlsMod,undefined,controlsMod);
         controlsMod.stop  = std.core.bind(
             stopControlsMod,undefined,controlsMod);

         tiresiasObj.addModule(controlsMod);
     };


     function graphicsInitFunc(controlsMod)
     {
         controlsMod.graphicsInit = true;

         controlsMod.guiMod.bind(
            'killControls',
            std.core.bind(hKillControls,undefined,controlsMod));        
     }


     function hKillControls(controlsMod)
     {
        tiresiasObj.redraw();         
     }

     
     function startControlsMod(controlsMod)
     {
         if (!controlsMod.graphicsInit)
         {
             throw new Error('Error starting controls module.  ' +
                             'Graphics were not yet initialized for display.');
         }
         controlsMod.guiMod.call('startControls');
     }


     function stopControlsMod(controlsMod)
     {
         if (!controlsMod.graphicsInit)
         {
             throw new Error('Error stopping controls module.  ' +
                             'Graphics were not yet initialized for display.');
         }
         controlsMod.guiMod.call('stopControls');
     }
     

     function getControlsHtml(controlsMod)
     {
         var returner = "sirikata.ui('" + CONTROLS_GUI_NAME + "',";
         returner += 'function(){ ';

         returner += @

         $('<div>'       +
           'Left arrow: turn left<br/>' +
           'Right arrow: turn right<br/>' +
           'Back arrow: move backwards<br/>' +
           '"q": rise<br/>' +
           '"z": lower<br/>' +
           '"c": toggle between 1st and third person<br/>' +
           '</div>' //end div at top.
          ).attr({id:'controls',title:'controls'}).appendTo('body');

         var dialogOpen = false;
         var controlsWindow = new sirikata.ui.window(
             '#controls',
             {
	         autoOpen:   false,
	         height:    'auto',
	         width:        300,
                 height:       400,
                 position: 'right',
                 beforeClose: function(event,ui)
                 {
                     if (dialogOpen)
                         sirikata.event('killControls');
                     dialogOpen = false;
                 }
            }
         );
         controlsWindow.hide();


         startControls = function()
         {
             dialogOpen = true;
             controlsWindow.show();
         };

         stopControls = function()
         {
             dialogOpen = false;
             controlsWindow.hide();
         };
         
         @;

         returner += '});';
         return returner;
     }
 })();

