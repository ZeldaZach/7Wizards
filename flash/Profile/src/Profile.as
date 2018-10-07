package {
	import com.wizards.View;
	import com.wizards.gui.SingleWindow;
	
	import flash.geom.Rectangle;

	[SWF(width='633', height='537', backgroundColor='0xeAAAAAA', framerate='30')]
	public class Profile extends SingleWindow
	{
		public const SIZE_PROJECT:Rectangle = new Rectangle(633, 537);
		
		public function Profile()
		{
			super(SIZE_PROJECT);
		    _viewClass = View;
			initialize();
		}
		
		protected override function initialize():void
		{
			super.initialize();
			
		}
	}
}
