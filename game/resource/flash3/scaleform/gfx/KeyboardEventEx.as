/**************************************************************************

Filename    :   KeyboardEventEx.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

package scaleform.gfx
{
    import flash.events.KeyboardEvent;
    
    public final class KeyboardEventEx extends KeyboardEvent
    {
        public var controllerIdx : uint = 0;
        
        public function KeyboardEventEx(type:String) { super(type); }
    }
}