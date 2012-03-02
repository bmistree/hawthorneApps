
system.require('module.em');

(function()
 {
     var HELLO_WORLD_GUI_NAME = 'helloWorldModule';
     
     addHelloWorldModule = function (tiresiasObj)
     {
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

         var helloWorldWindow = new sirikata.ui.window(
             '#helloWorld',
             {
	        autoOpen:   false,
	        height:    'auto',
	        width:        300,
                height:       400,
                position: 'right'
            }
         );
         helloWorldWindow.hide();


         startHelloWorld = function()
         {
             helloWorldWindow.show();
         };

         stopHelloWorld = function()
         {
             helloWorldWindow.hide();
         };
         
         @;

         returner += '});';
         return returner;
     }
 })();

