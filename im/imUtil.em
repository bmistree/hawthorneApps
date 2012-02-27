

(function()
{
    var uniqueInt = 1;
    
    function htmlEscape(str)
    {
        return str;
    }
    
    function getUniqueInt()
    {
        return ++uniqueInt;
    }

    function dPrint(toPrint)
    {
        system.__debugPrint(toPrint);
    }
    
    IMUtil = {
        htmlEscape: htmlEscape,
        getUniqueInt: getUniqueInt,
        dPrint: dPrint
    };


    

})();
