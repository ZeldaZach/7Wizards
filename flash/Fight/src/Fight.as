package {
	import com.wizards.View;
	import com.wizards.gui.SingleWindow;
	
	import flash.geom.Rectangle;
	import flash.system.Security;
	
	[SWF(width='953', height='334', backgroundColor='0xeAAAAAA', framerate='30')]
	public class Fight extends SingleWindow
	{
		public const SIZE_PROJECT:Rectangle = new Rectangle(953, 334);
		
		public function Fight()
		{
			super(SIZE_PROJECT)
			_viewClass = View;
			
			super.initialize();
			
		}
		
	}
}
