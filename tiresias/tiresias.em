
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

     
     system.require('std/core/repeatingTimer.em');

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
     };


     function tiresiasConnected(tiresiasObj)
     {
         tiresiasObj.mPresence = system.self;
         tiresiasObj.follow();
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
})();

