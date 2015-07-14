// 12.03.13 - NE - Created.

package controls
{
	import controls.skins.IndFishResponse;
	
	import mx.collections.ArrayCollection;
	
	import spark.components.BorderContainer;
	import spark.components.HGroup;
	import spark.components.SkinnableContainer;
	
	public class IndFishResponse extends spark.components.SkinnableContainer
	{
		private var _speciesName:String = '';
		
		private var _speciesNumber:String = '';
		
		private var _tempClass:String = '';
		
		private var _tempClassColor:uint = 0xFFFFFF;
		
		private var _dataObj:Object = new Object();
		
		public var indFishResponseContainer:SkinnableContainer;
		
		
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
		public function get dataObj():Object {
			return _dataObj;
		}
		
		public function set dataObj(dO:Object):void {
			_dataObj = dO;
		}
		
		
		override public function stylesInitialized():void {  
			super.stylesInitialized();
			this.setStyle("skinClass",Class(controls.skins.IndFishResponse));
		}
		
		public function updated(event):void {
			var tempObj:Object = dataObj;
			
			if (tempObj[speciesNumber+"A"] != null && tempObj[speciesNumber+"A"] == "P") {
				indFishResponseContainer.document.currentEllipse.visible = true;
			} else {
				indFishResponseContainer.document.currentEllipse.visible = false;
			}
			
			if (tempObj[speciesNumber+"A46"] != null && tempObj[speciesNumber+"A46"] == "P") {
				indFishResponseContainer.document.f1Ellipse.visible = true;
			} else {
				indFishResponseContainer.document.f1Ellipse.visible = false;
			}
			
			if (tempObj[speciesNumber+"A81"] != null && tempObj[speciesNumber+"A81"] == "P") {
				indFishResponseContainer.document.f2Ellipse.visible = true;
			} else {
				indFishResponseContainer.document.f2Ellipse.visible = false;
			}
		}
		
		
	}
}