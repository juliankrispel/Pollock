(function() {
  var $canvas, bindPainter, onImageDrop;

  angular.module('PainterApp', ['uiSlider']);

  $canvas = document.querySelector('canvas');

  window.addEventListener('dragover', function(event) {
    return event.preventDefault();
  }, false);

  angular.module('PainterApp').controller('PainterCtrl', function($scope) {
    var bbox;
    bbox = document.body.getBoundingClientRect();
    window.s = $scope;
    $scope.painter = {
      canvasHeight: bbox.height,
      canvasWidth: bbox.width,
      images: []
    };
    window.onresize = function() {
      bbox = document.body.getBoundingClientRect();
      $scope.painter.canvasHeight = bbox.height;
      $scope.painter.canvasWidth = bbox.width;
      return $scope.$apply();
    };
    $scope.brushTypes = ['circle', 'scircle', 'square', 'weird', 'sort'];
    $scope.brushMovements = ['Random', 'HalfPipe'];
    $scope.removeImage = function(index) {
      return $scope.painter.images.splice(index, 1);
    };
    window.addEventListener('drop', function(event) {
      return onImageDrop(event, function(img) {
        $scope.painter.images.push({
          url: img.src
        });
        return $scope.$apply();
      });
    }, false);
    return $scope.start = function() {
      $scope.painterStarted = true;
      if ($scope.painter.images.length < 1) {
        return false;
      }
      startPainter($canvas, document.querySelectorAll('.image'), function(painter) {
        return bindPainter(painter, $scope);
      });
      return setTimeout(function() {
        $scope.painter.canvasHeight = bbox.height;
        $scope.painter.canvasWidth = bbox.width;
        return $scope.$apply();
      }, 1);
    };
  });

  bindPainter = function(myPainter, scope) {
    var list, name, _i, _len, _results;
    scope.painter['hasLoaded'] = true;
    list = myPainter.PS.getAllChannels();
    _results = [];
    for (_i = 0, _len = list.length; _i < _len; _i++) {
      name = list[_i];
      _results.push((function(name) {
        myPainter.PS.subscribe(name, 'gui', function(value) {
          scope.painter[name] = value;
          return scope.$apply();
        });
        scope.painter[name] = myPainter.PS.getValue(name);
        return scope.$watch('painter.' + name, function() {
          var value;
          value = scope.painter[name];
          if (!isNaN(value)) {
            value = parseInt(value);
          }
          return myPainter.PS.setValue(name, 'gui', value);
        });
      })(name));
    }
    return _results;
  };

  onImageDrop = function(event, callback) {
    var file, fileType, reader;
    event.preventDefault();
    file = event.dataTransfer.files[0];
    fileType = file.type;
    if (!fileType.match(/image\/\w+/)) {
      console.log("Only image files supported.");
      return false;
    }
    reader = new FileReader();
    reader.onload = function() {
      var _inputImage;
      _inputImage = new Image();
      _inputImage.src = reader.result;
      return _inputImage.onload = function() {
        return callback(_inputImage);
      };
    };
    return reader.readAsDataURL(file);
  };

}).call(this);
