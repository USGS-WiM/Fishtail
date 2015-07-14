// class for wrapping text on button label

package controls
{
	import flash.text.TextFieldAutoSize;
	import spark.components.Button;
	
	public class WrapButton extends Button
	{
		public function WrapButton()
		{
			super();
		}
		
		override protected function createChildren():void
		{
			super.createChildren();
			
			//textField.multiline = true;
			//textField.wordWrap = true;
			//textField.autoSize = TextFieldAutoSize.CENTER;
			
			//this.setStyle("cornerRadius", 0);
			//this.setStyle("chromeColor", 0x00FF00);
		
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			//textField.y = (this.height - textField.height) >> 1;
			
			/*this.setStyle("cornerRadius", 0);
			this.setStyle("chromeColor", 00);*/
			
			//height = textField.height + getStyle("paddingTop") + getStyle("paddingBottom");
		}
	}
}