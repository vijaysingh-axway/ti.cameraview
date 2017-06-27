

var TiCamera = require('ti.cameraview');
var win = Titanium.UI.createWindow();
var btn = Ti.UI.createButton({
  title: 'OPEN CAMERA'
});
var camera;
btn.addEventListener('click',function (){

 camera = TiCamera.createCamera({
               saveToPhotoGallery:true,
               torchMode:TiCamera.TORCH_MODE_OFF,
               flashMode:TiCamera.FLASH_MODE_ON,
               cameraType:TiCamera.CAMERA_TYPE_REAR,
               showControl:false,

                success: function(event)
                 {
                    win.backgroundImage = event.media;
                  }
                });
                camera.add(changeCamera);
                camera.add(torch);
                camera.add(capture);

                camera.open();
              });

var changeCamera = Ti.UI.createButton({
                                      right: 40,
                                      top: 50,
                                      title:'Change Camera',
                                      backgroundColor:'red'
                                      });
changeCamera.addEventListener('click', function(e){
                              if(camera.cameraType == TiCamera.CAMERA_TYPE_REAR) {
                              camera.setCameraType(TiCamera.CAMERA_TYPE_FRONT);
                              }
                              else
                              {
                              camera.setCameraType(TiCamera.CAMERA_TYPE_REAR);
                              }
                              });
var torch = Ti.UI.createButton({
                                     left: 40,
                                     top: 50,
                                     title:'Torch Mode',
                                     backgroundColor:'red'
                                     });
torch.addEventListener('click', function(e){
                             Ti.API.info(camera.torchMode);
                             Ti.API.info(TiCamera.TORCH_MODE_OFF);
                             Ti.API.info(TiCamera.TORCH_MODE_ON);
                             
                             if(camera.torchMode == TiCamera.TORCH_MODE_OFF) {
                             Ti.API.info('to on');
                             camera.setTorchMode(TiCamera.TORCH_MODE_ON);
                             }
                             else {
                             Ti.API.info('to off');
                             camera.setTorchMode(TiCamera.TORCH_MODE_OFF);
                             }
                           });

var capture = Ti.UI.createButton({
                                 bottom : 40,
                                 title: 'Capture',
                                 backgroundColor: 'red'
});

capture.addEventListener('click', function(e){

camera.captureImage();
});
win.add(btn);
win.open();
