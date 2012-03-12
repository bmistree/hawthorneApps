if (typeof(my) === "undefined") my = {};

my.deltaTimer = function () {
    this.prev = -1;
    
    this.getDeltaTime = function () {
        var date = new Date();
        var now = date.getTime();
        var delta_time = 0;
        
        if (this.prev >= 0) {
            delta_time = (now - this.prev) * 0.001;
        }
        
        this.prev = now;
        
        return delta_time;
    }
};

            
