/**************************************************************************

Filename    :   TextEventEx.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

package scaleform.gfx
{
    import flash.events.TextEvent;
    
    public final class TextEventEx extends TextEvent
    {   
        // These events are fired only if a StyleSheet has been applied to the 
        // target TextField.
        public static const LINK_MOUSE_OVER:String = "linkMouseOver";
        public static const LINK_MOUSE_OUT:String = "linkMouseOut";
        
        public var controllerIdx : uint = 0;
		public var buttonIdx : uint = 0; // MouseEventEx.LEFT_BUTTON, MouseEventEx.RIGHT_BUTTON, ...
        
        public function TextEventEx(type:String) { super(type); }
    }
}