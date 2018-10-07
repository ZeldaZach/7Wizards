var timers = {}

function createTimer(options) {

    if(options.seconds > 0) {
        timers[options.span_id] = new Timer(options);
    }
}

function stopTimers() {
    for(var time in timers)
    {
        timers[time].stop();
    }
}

var Timer = Class.create({
    initialize: function(options) {
        this.interval = 1000;
        this.timerId = options.span_id; //tag id, where timer will shows
        this.seconds = options.seconds;
        this.timerUrl = options.timer_url; // on end, call url
        
        this.start();
    },

    start: function() {
        if(this.seconds > 0) {
            this.intervalId = window.setInterval(this.refresh.bind(this), this.interval);
        }
    },
  
    stop: function() {
        window.clearInterval(this.intervalId);
    },

    refresh: function() {
        var secInHours = 3600;
        var hours   = Math.floor(this.seconds / secInHours);
        var minutes = Math.floor((this.seconds - hours * secInHours) / 60);
        var seconds = this.seconds - minutes * 60 - hours * secInHours;
        
        if(hours   < 10 ) hours   = "0" + hours;
        if(minutes < 10 ) minutes = "0" + minutes;
        if(seconds < 10 ) seconds = "0" + seconds;

        if ($(this.timerId))
        {
            var time = minutes + ":" + seconds;
            if(hours > 0)
            {
                time = hours + ":" + time;
            }
            $(this.timerId).innerHTML = time;
            

        }

        this.seconds = this.seconds - 1;

        if(this.seconds < 0) {
            this.stop();
            this.request();

        } 
    },

    request: function() {
        if ($(this.timerId)){
            new Ajax.Request(this.timerUrl,
            {
                asynchronous:false,
                evalScripts:true
            });
        }
    }
});
