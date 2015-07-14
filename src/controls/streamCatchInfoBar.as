// 12.02.13 - NE - Created.

package controls
{
	import controls.skins.streamCatchInfoBar;
	
	import spark.components.BorderContainer;
	import spark.components.HGroup;
	
	public class streamCatchInfoBar extends spark.components.BorderContainer
	{
		private var _dataObj:Object;
		
		
		[Bindable] 
		public function get dataObj():Object {
			return _dataObj;
		}
		
		public function set dataObj(dO:Object):void {
			_dataObj = dO;
		}
		
		
		override public function stylesInitialized():void {  
			super.stylesInitialized();
			this.setStyle("skinClass",Class(controls.skins.streamCatchInfoBar));
		}
		
	}
}