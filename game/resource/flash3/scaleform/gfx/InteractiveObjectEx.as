/**************************************************************************

Filename    :   InteractiveObjectEx.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

package scaleform.gfx
{
   import flash.display.InteractiveObject;

   public class InteractiveObjectEx extends DisplayObjectEx
   {   	   

       static public function setHitTestDisable(o:InteractiveObject, f:Boolean) : void { }
       static public function getHitTestDisable(o:InteractiveObject) : Boolean { return false; }

       static public function setTopmostLevel(o:InteractiveObject, f:Boolean) : void { }
       static public function getTopmostLevel(o:InteractiveObject) : Boolean { return false; }
   }
}
