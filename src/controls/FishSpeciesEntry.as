// 12.02.13 - NE - Created.

package controls
{
	import controls.skins.FishSpeciesEntry;
	
	import mx.collections.ArrayCollection;
	
	import spark.components.BorderContainer;
	import spark.components.HGroup;
	
	public class FishSpeciesEntry extends spark.components.BorderContainer
	{
		private var _speciesName:String;
		
		private var _speciesNumber:String;
		
		private var _tempClass:String;
		
		private var _tempClassColor:uint;
		
		private var _isHuc:Boolean = false;
		
		private var _dataObj:Object;
		
		
	
		
		[Bindable]
		public function get speciesName():String {
			return _speciesName;
		}
		
		public function set speciesName(sn:String):void {
			_speciesName = sn;		
		}
		
		[Bindable]
		public function get speciesNumber():String {
			return _speciesNumber;
		}
		
		public function set speciesNumber(snum:String):void {
			_speciesNumber = snum;		
		}
		
		[Bindable]
		public function get tempClass():String {
			return _tempClass;
		}
		
		public function set tempClass(tc:String):void {
			_tempClass = tc;		
		}
		
		[Bindable]
		public function get tempClassColor():uint {
			return _tempClassColor;
		}
		
		public function set tempClassColor(tcc:uint):void {
			_tempClassColor = tcc;		
		}
		
		[Bindable]
		public function get isHuc():Boolean {
			return _isHuc;
		}
		
		public function set isHuc(ih:Boolean):void {
			_isHuc = ih;		
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
			this.setStyle("skinClass",Class(controls.skins.FishSpeciesEntry));
		}
		
	}
}