var itemName = window.location.hash;
var storageName = 'julians-portrait';
if(window.location.hash && itemname) storageName = storageName + '#' + itemName;
var cache = window.localStorage.getItem(storageName) || null;
var currentTime = new Date();
currentTime.setSeconds(currentTime.getSeconds() + 30);

(function() {
    var lastTime = 0;
    var vendors = ['webkit', 'moz'];
    for(var x = 0; x < vendors.length && !window.requestAnimationFrame; ++x) {
        window.requestAnimationFrame = window[vendors[x]+'RequestAnimationFrame'];
        window.cancelAnimationFrame =
          window[vendors[x]+'CancelAnimationFrame'] || window[vendors[x]+'CancelRequestAnimationFrame'];
    }

    if (!window.requestAnimationFrame)
        window.requestAnimationFrame = function(callback, element) {
            var currTime = new Date().getTime();
            var timeToCall = Math.max(0, 16 - (currTime - lastTime));
            var id = window.setTimeout(function() { callback(currTime + timeToCall); },
              timeToCall);
            lastTime = currTime + timeToCall;
            return id;
        };

    if (!window.cancelAnimationFrame)
        window.cancelAnimationFrame = function(id) {
            clearTimeout(id);
        };
}());


(function(){
    var canvasElement = document.getElementById('canvas');
    var w = canvas.width;
    var h = canvas.height;
    var pixels = [];

    canvas = canvasElement.getContext('2d');

    if(cache && cache !== 'undefined'){
        cache = cache;
    }

    var images = [];
    var imagesLoaded = 0;

    for(var i = 3; i < 7; i++){
        var image = new Image();
        image.src = 'img/0' + i + '.jpg';
        image.imageCanvas = document.createElement('canvas');
        image.imageCanvas.width = 770;
        image.imageCanvas.height = 1027;
        image.context = image.imageCanvas.getContext('2d');

        image.onload = function(){
            this.context.drawImage(this, 0, 0 );
            imagesLoaded++;
            images.push(this.context);

            if(imagesLoaded == images.length)
                init();
        }
    }

    function init(){
        loadImageFromLocalStorage();
        generatePixels();
        draw();
    }

    function loadImageFromLocalStorage(){
        var localImage = new Image();
        localImage.src = cache;
        localImage.onload = function(){
            canvas.drawImage(localImage, 0, 0);
        }
    }

    function draw(){
        _(pixels).each(function(pixel){
            pixel.move();
        });
        var date = new Date();
        if(date > currentTime){
            currentTime = date;
            currentTime.setSeconds( currentTime.getSeconds() + 30 );
            var canvasImage = canvasElement.toDataURL("image/png");
            saveToLocalStorage();
        }
        requestAnimationFrame(draw);
    }

    function saveToLocalStorage(){
        try {
            window.localStorage.setItem(storageName, canvasImage);
        }catch(er){
            console.log(er);
        }
    }

    function generatePixels(){
        for(var i = 0; i < 5; i++){
            var pixel = new Pixel({
                canvas: canvas,
                imageCanvas: images 
            })
            pixels.push(pixel);
        }
    }

    function blend(under, over, mode){
        return Math.round((over * .5) + (under * .5));
    }

    function composite(under, over, mode) {
        for(var i = 0; i < under.length; i+=4){
            under[i] = blend(under[i], over[i]);
            under[i+1] = blend(under[i+1], over[i+1]);
            under[i+2] = blend(under[i+2], over[i+2]);
        }
    }

    function saturate(data, amount){
        for(var i = 0; i < data.length; i+=4){
            var max = _(data).max(function(color){ return color.})
        
        }
    }

    var Pixel = function(config){
        this.init(config);
    }

    _(Pixel.prototype).extend({
        //Defaults
        defaults: {
            x: 0,
            y: 0,
            xir: 1,
            ydir: 1,
            canvas: null,
            imageCanvas: null,
            brushWidth: 2,
            brushHeight: 2
        },

        init: function(config){
            //Extend new pixel with passed parameters
            _(this).extend(this.defaults, config);

            if(_.isArray(this.imageCanvas)){
                this.storeImageCanvasArray();
                this.pickImageCanvas();
            }

            this.resetCoordinates();
            this.resetDirection();
            this.resetImageData();
        },

        storeImageCanvasArray: function(){
            if(_.isArray(this.imageCanvas))
                this.imageCanvasArray = this.imageCanvas;
        },

        pickImageCanvas: function(){
            var max = this.imageCanvasArray.length;
            var index = getRandomInt(0, max - 1);
            this.imageCanvas = this.imageCanvasArray[index];
        },

        move: function(){
            // Change the coordinates to move in the right direction
            this.x = this.x + this.xdir;
            this.y = this.y + this.ydir;

            //Reset brush every now and then
//            if(percentTrue(3))
//                this.resetBrush();

            //Respawn every now and then
            if(percentTrue(1))
                this.resetCoordinates();

            //Change direction every now and then
            if(percentTrue(30))
                this.resetDirection();               

            //Get imageData from .imageCanvas and put it on canvas
            if(percentTrue(10))
                this.resetImageData();


            composite(this.imageData.data, destImageData.data);
//            saturate(this.imageData.data, 30);
            this.canvas.putImageData(this.imageData, this.x, this.y);
        },

        makeTransparent: function(imageData){
            console.log(image)
        },

        resetImageData: function(){
            this.imageData = this.imageCanvas.getImageData(this.x, this.y, this.brushWidth, this.brushHeight);
            var destImageData = this.canvas.getImageData(this.x, this.y, this.brushWidth, this.brushHeight);
        },

        resetCoordinates: function(){
            this.x = getRandomInt(1, w);
            this.y = getRandomInt(1, h);
        },

        resetDirection: function(){
            this.xdir = getRandomInt(-1, 1) * this.brushWidth;
            this.ydir = getRandomInt(-1, 1) * this.brushHeight;
        },

        resetBrush: function(){
            this.brushWidth = getRandom(1, 2);
            this.brushHeight = getRandom(1, 2);
        }
    
    });

    // Get Image Data
    function getImageData(context, w,h){
        //Set defaults for width and height
        if(!w) w = 1;
        if(!h) h = 1;

        return context.getImageData(0, 0, w, h);
    }

    // Generate random point
    function generateRandomCoordinates(){
        return [ getRandomInt(1, w), getRandomInt(1, h) ];
    }

    function getRandomInt(min, max){
        return Math.round(Math.random() * (max - min) + min);
    }

    function getRandom(min, max){
        var num = Math.random() * (max - min) + min;
        return num;
    }

    function percentTrue(percent){
        return (getRandomInt(1, 100) <= percent);
    }

})();
