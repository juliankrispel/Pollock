var canvas = document.getElementById('canvas').getContext('2d');

var imageCanvas = document.createElement('canvas');
imageCanvas.width = '300';
imageCanvas.height = '200';

var img = new Image();
var img2 = new Image();

img.src = 'img/test4.jpg';
img2.src = 'img/test3.jpg';

var imageContext = imageCanvas.getContext('2d');

function _composite(under, over) {
    return Math.round((under + over) / 2);
}


    function blend(under, over, mode){
        if(mode == 'difference')
            return Math.round(Math.abs(over - under) / 2);
        else
        return Math.round((over + under) / 2);
    }

    function composite(under, over, mode) {
        for(var i = 0; i < under.length; i+=4) {
            under[i] = blend(under[i], over[i]);
            under[i+1] = blend(under[i+1], over[i+1]);
            under[i+2] = blend(under[i+2], over[i+2]);
        }
    }

window.onload = function(){
    canvas.drawImage(img, -20, -10);
    imageContext.drawImage(img2, -20, -10);
    var imageData = canvas.getImageData(0,0,300,200);
    var destImageData = imageContext.getImageData(0,0,300,200);
    
    composite(imageData.data, destImageData.data);
//    for(var i = 0; i < imageData.data.length; i+=4){
//        imageData.data[i] = destImageData.data[i] < 255 ? Math.abs((destImageData.data[i] + imageData.data[i]) / 2) : imageData.data[i];
//        imageData.data[i+1] = destImageData.data[i] < 255 ? Math.abs((destImageData.data[i+1] + imageData.data[i+1]) / 2) : imageData.data[i];
//        imageData.data[i+2] = destImageData.data[i] < 255 ? Math.abs((destImageData.data[i+2] + imageData.data[i+2]) / 2) : imageData.data[i];
//    }

    canvas.putImageData(imageData, 0, 0);
 
}
