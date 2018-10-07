
package com.wizards.utils {
	
    
    import com.adobe.images.JPGEncoder;
    import com.adobe.images.PNGEncoder;
    import com.wizards.Global;
    import com.wizards.events.GraphEvent;
    
    import flash.display.BitmapData;
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.geom.Matrix;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.utils.ByteArray;
	
	public class DynamicBitmap extends Sprite {
		
		private var _target:DisplayObject;
		private var _image:ByteArray;
		private var _filename:String; 
			
		public function DynamicBitmap(target:DisplayObject, name:String)
		{
		    var bmd:BitmapData = new BitmapData(target.width, target.height, true, 0xFFFFFF);
				bmd.draw(target, new Matrix(), null, null, null, false);
		    
			_target = target; _filename = name;
			var ext:String = name.substr(-3);
			if (ext=='png') {
				_image = PNGEncoder.encode(bmd);
			}	else if (ext=='jpg'){
				_image = new JPGEncoder(86).encode(bmd);
			}
		}
		
		public function upload($script:String, $directory:String=null, $args:Object=null):void
		{
		    if (!_image) {
		        dispatchEvent(new GraphEvent('ImageConversionFailure', _target+' could not be converted to BitmapData\n\n'+'***make sure file extension is either .jpg or .png***')); return;
	        }
	        
	        Global.loaderView.show();
	        
		    var wrapper:URLRequestWrapper = new URLRequestWrapper(_image, _filename, $directory, $args);
		        wrapper.url = $script;
            var ldr:URLLoader = new URLLoader();
                ldr.dataFormat = URLLoaderDataFormat.BINARY;
                ldr.addEventListener(Event.COMPLETE, onLoadSuccess);
                ldr.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
                ldr.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onSecurityError);
                ldr.load(wrapper.request);
		}
			
//----------------------------------------------------------------//

		private function onLoadSuccess(evt:Event):void
		{
			Global.loaderView.hide();
			dispatchEvent(new GraphEvent('onLoadSuccess', evt.target));
		}
		
		private function ioErrorHandler(evt:IOErrorEvent):void
		{
			Global.loaderView.hide();
			dispatchEvent(new GraphEvent('onLoadFailure', 'Attempt to upload '+_target+' as Bitmap failed, check network connection.'));
		}
		
		private function onSecurityError(evt:SecurityErrorEvent):void
		{
			Global.loaderView.hide();
			dispatchEvent(new GraphEvent('onSecurityError', 'A Flash Player security violation has occurred'));
		}

//----------------------------------------------------------------//	
	    
	
		
	}
	
}







