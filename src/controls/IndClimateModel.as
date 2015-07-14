// 12.02.13 - NE - Created.

package controls
{
	import controls.skins.IndClimateModel;
	
	import mx.collections.ArrayCollection;
	
	import spark.components.BorderContainer;
	import spark.components.HGroup;
	
	public class IndClimateModel extends spark.components.BorderContainer
	{
		private var _modelNumber:String;
		
		
		[Bindable]
		public function get modelNumber():String {
			return _modelNumber;
		}
		
		public function set modelNumber(mnum:String):void {
			_modelNumber = mnum;		
		}
		
		
		override public function stylesInitialized():void {  
			super.stylesInitialized();
			this.setStyle("skinClass",Class(controls.skins.IndClimateModel));
		}
		
	}
}