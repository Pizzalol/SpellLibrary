/**************************************************************************

Filename    :   TextFieldEx.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

package scaleform.gfx
{
   import flash.text.TextField
   import flash.display.BitmapData;

   public final class TextFieldEx extends InteractiveObjectEx
   {   	
        public static const VALIGN_NONE:String          = "none";        
        public static const VALIGN_TOP:String 			= "top";
		public static const VALIGN_CENTER:String 		= "center";
		public static const VALIGN_BOTTOM:String 		= "bottom";
        
        public static const TEXTAUTOSZ_NONE:String      = "none";
        public static const TEXTAUTOSZ_SHRINK:String    = "shrink";
        public static const TEXTAUTOSZ_FIT:String       = "fit";

        public static const VAUTOSIZE_NONE:String       = "none";        
        public static const VAUTOSIZE_TOP:String 		= "top";
		public static const VAUTOSIZE_CENTER:String 	= "center";
		public static const VAUTOSIZE_BOTTOM:String 	= "bottom";
	   
		// The flash.text.TextField specification includes appendText.
		static public function appendHtml(textField:TextField, newHtml:String) : void  { }
        
		static public function setIMEEnabled(textField:TextField, isEnabled:Boolean): void { }

        // Sets the vertical alignment of the text inside the textfield.
        // Valid values are "none", "top" (same as none), "bottom" and "center"
		static public function setVerticalAlign(textField:TextField, valign:String) : void { }
        static public function getVerticalAlign(textField:TextField) : String { return "none"; }

        // Sets the vertical auto size of the text inside the textfield.
        // Valid values are "none", "top" (same as none), "bottom" and "center"
		static public function setVerticalAutoSize(textField:TextField, vautoSize:String) : void { }
        static public function getVerticalAutoSize(textField:TextField) : String { return "none"; }
	  
        // Enables automatic resizing of the text's font size to shrink or fit the textfield.
        // Valid values are "none", "shrink", and "fit"
        static public function setTextAutoSize(textField:TextField, autoSz:String) : void { }
        static public function getTextAutoSize(textField:TextField) : String { return "none"; }

        static public function setImageSubstitutions(textField:TextField, substInfo:Object) : void {}
        static public function updateImageSubstitution(textField:TextField, id:String, image:BitmapData) : void { }
        
        // Disable auto-translation support for the target textfield (see GFx::Translator)
        static public function setNoTranslate(textField:TextField, noTranslate:Boolean) : void {}
        static public function getNoTranslate(textField:TextField) : Boolean { return false; }

		static public function setBidirectionalTextEnabled(textField:TextField, en:Boolean) : void {}
		static public function getBidirectionalTextEnabled(textField:TextField) : Boolean { return false; }

        // Sets gets selection text color
        static public function setSelectionTextColor(textField:TextField, selColor:uint) : void {}
        static public function getSelectionTextColor(textField:TextField) : uint { return 0xFFFFFFFF; }

        // Sets gets selection background color
        static public function setSelectionBkgColor(textField:TextField, selColor:uint) : void {}
        static public function getSelectionBkgColor(textField:TextField) : uint { return 0xFF000000; }

        // Sets gets inactive selection text color (for not focused textfield)
        static public function setInactiveSelectionTextColor(textField:TextField, selColor:uint) : void {}
        static public function getInactiveSelectionTextColor(textField:TextField) : uint { return 0xFFFFFFFF; }

        // Sets gets inactive selection background color (for not focused textfield)
        static public function setInactiveSelectionBkgColor(textField:TextField, selColor:uint) : void {}
        static public function getInactiveSelectionBkgColor(textField:TextField) : uint { return 0xFF000000; }
   }
}
