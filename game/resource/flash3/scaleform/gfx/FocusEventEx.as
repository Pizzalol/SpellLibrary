/**************************************************************************

Filename    :   FocusEventEx.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

package scaleform.gfx
{
    import flash.events.FocusEvent;
    
    public final class FocusEventEx extends FocusEvent
    {
        public var controllerIdx : uint = 0;
       
        public function FocusEventEx(type:String) { super(type); }
    }
}