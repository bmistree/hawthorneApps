
system.require('tiresiasUtil.em');

(function()
 {

     /**
      @param {string} moduleOptionText -- The user-facing text
      describing this module.  Presented when Tiresias shows general
      options.

      
      */
     TiresiasModule = function(moduleOptionText)
     {
         this.moduleOptionText = moduleOptionText;
         this.modId = TiresiasUtil.uniqueInt();
     };

     //user clicked start to begin module
     TiresiasModule.prototype.start = function()
     {};

     //user clicked stop to end module.
     TiresiasModule.prototype.stop = function()
     {};
     
 })();