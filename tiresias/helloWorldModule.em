
system.require('module.em');

(function()
 {
     var HELLO_WORLD_GUI_NAME = 'helloWorldModule';
     var tiresiasObj = null;
     
     addHelloWorldModule = function (tObj)
     {
         tiresiasObj = tObj;
         var helloWorldMod =
             new TiresiasModule('hello world');

         helloWorldMod.graphicsInit = false;
         
         helloWorldMod.guiMod = simulator._simulator.addGUITextModule(
             HELLO_WORLD_GUI_NAME,
             getHelloWorldHtml(),
             std.core.bind(graphicsInitFunc,undefined,helloWorldMod));
         
         helloWorldMod.start = std.core.bind(
             startHelloWorldMod,undefined,helloWorldMod);
         helloWorldMod.stop  = std.core.bind(
             stopHelloWorldMod,undefined,helloWorldMod);

         tiresiasObj.addModule(helloWorldMod);
     };


     function graphicsInitFunc(helloWorldMod)
     {
         helloWorldMod.graphicsInit = true;

         helloWorldMod.guiMod.bind(
            'killHelloWorld',
            std.core.bind(hKillHelloWorld,undefined,helloWorldMod));        
     }


     function hKillHelloWorld(helloWorldMod)
     {
        tiresiasObj.redraw();         
     }

     

     function startHelloWorldMod(helloWorldMod)
     {
         if (!helloWorldMod.graphicsInit)
         {
             throw new Error('Error starting hello world module.  ' +
                             'Graphics were not yet initialized for display.');
         }
         helloWorldMod.guiMod.call('startHelloWorld');
     }


     function stopHelloWorldMod(helloWorldMod)
     {
         if (!helloWorldMod.graphicsInit)
         {
             throw new Error('Error stopping hello world module.  ' +
                             'Graphics were not yet initialized for display.');
         }
         helloWorldMod.guiMod.call('stopHelloWorld');
     }
     
 
     function getHelloWorldHtml(helloWorldMod)
     {
         var returner = "sirikata.ui('" + HELLO_WORLD_GUI_NAME + "',";
         returner += 'function(){ ';

         returner += @

         $('<div>'       +
           'hello world' +
           '</div>' //end div at top.
          ).attr({id:'helloWorld',title:'helloWorld'}).appendTo('body');

         var dialogOpen = false;
         var helloWorldWindow = new sirikata.ui.window(
             '#helloWorld',
             {
	        autoOpen:   false,
	        height:    'auto',
	        width:        300,
                height:       400,
                position: 'right',
                 beforeClose: function(event,ui)
                 {
                     if (dialogOpen)
                         sirikata.event('killHelloWorld');
                     dialogOpen = false;
                 }
            }
         );
         helloWorldWindow.hide();


         startHelloWorld = function()
         {
             dialogOpen = true;
             helloWorldWindow.show();
         };

         stopHelloWorld = function()
         {
             dialogOpen = false;
             helloWorldWindow.hide();
         };
         
         @;

         returner += '});';
         return returner;
     }
 })();

