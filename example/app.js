

var Camera = require('ti.cameraview');
var win = Titanium.UI.createWindow();
var btn = Ti.UI.createButton({
  title: 'OPEN CAMERA'
});
btn.addEventListener('click',function (){
   Camera.openCamera({
               saveToPhotoGallery:true,
               torchMode:Camera.TORCH_MODE_ON,
                     flashMode:Camera.FLASH_MODE_ON,
                     success: function(event)
                     {
                        win.backgroundImage = event.media;
                     }
                     });
});
win.add(btn);
win.open();
