


(function()
 {
     var uniqueInter = 0;
     
     function Tutil()
     {
     };

     Tutil.prototype.uniqueInt = function()
     {
         return ++uniqueInter;
     };

     TiresiasUtil = new Tutil();
     
 })();