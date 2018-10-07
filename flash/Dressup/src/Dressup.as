package {
	import com.wizards.View;
	import com.wizards.gui.SingleWindow;
	
	import flash.geom.Rectangle;
	import flash.system.Security;

	
	[SWF(width='952', height='559', backgroundColor='0xeAAAAAA', framerate='30')]
	public class Dressup extends SingleWindow
	{
		public const SIZE_PROJECT:Rectangle = new Rectangle(952, 559);
		
		public function Dressup()
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
