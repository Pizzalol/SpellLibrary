/**************************************************************************

Filename    :   GamePadAnalogEvent.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

package scaleform.gfx
{
    import flash.events.Event;
    
    public final class GamePadAnalogEvent extends Event
    {
        public static const CHANGE:String   = "gamePadAnalogChange";
                
        public var code : uint          = 0;    // See scaleform.gfx.GamePad for valid pad codes
        public var controllerIdx : uint = 0;
        public var xvalue : Number      = 0;    // Normalized [-1, 1]
        public var yvalue : Number      = 0;    // Normalized [-1, 1]
        
        public function GamePadAnalogEvent(bubbles:Boolean, cancelable:Boolean, code:uint, 
                                           controllerIdx:uint = 0, xvalue:Number = 0, yvalue:Number = 0)
        {
            super(GamePadAnalogEvent.CHANGE, bubbles, cancelable);
            this.code = code;
            this.controllerIdx = controllerIdx;
            this.xvalue = xvalue;
            this.yvalue = yvalue;
        }
    }
}