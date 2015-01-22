/**************************************************************************

Filename    :   DisplayObjectEx.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

package scaleform.gfx
{
   import flash.display.DisplayObject;

   public class DisplayObjectEx
   {   	   
       static public function disableBatching(o:DisplayObject, b:Boolean) : void { }
       static public function isBatchingDisabled(o:DisplayObject) : Boolean { return false; }

       static public function setRendererString(o:DisplayObject, s:String) : void { }
       static public function getRendererString(o:DisplayObject) : String { return null; }

       static public function setRendererFloat(o:DisplayObject, f:Number) : void { }
       static public function getRendererFloat(o:DisplayObject) : Number { return Number.NaN; }
   }
}
