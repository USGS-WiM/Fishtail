// 07.01.14 - NE - Created.

package controls
{
	import controls.skins.IndClimateResponse;
	
	import mx.collections.ArrayCollection;
	
	import spark.components.BorderContainer;
	import spark.components.HGroup;
	import spark.components.SkinnableContainer;
	
	public class IndClimateResponse extends spark.components.SkinnableContainer
	{
		private var _modelNumber:String = '';
		
		private var _dataObj:Object = new Object();
		
		
		[Bindable]
		public function get modelNumber():String {
			return _modelNumber;
		}
		
		public function set modelNumber(mnum:String):void {
			_modelNumber = mnum;		
		}
		
		[Bindable] 
		public function get dataObj():Object {
			return _dataObj;
		}
		
		public function set dataObj(dO:Object):void {
			_dataObj = dO;
		}
		
		
		override public function stylesInitialized():void {  
			super.stylesInitialized();
			this.setStyle("skinClass",Class(controls.skins.IndClimateResponse));
		}
		
		public function updated(event):void {
			
		}
		
		
	}
}