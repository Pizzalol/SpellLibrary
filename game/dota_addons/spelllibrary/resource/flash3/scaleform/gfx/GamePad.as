/**************************************************************************

Filename    :   GamePad.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

package scaleform.gfx
{   
    public final class GamePad
    {
        // The following constants will be filled in appropriately by 
        // Scaleform at runtime. Flash has no concept of a GamePad and
        // therefore the constants (and this class) has no use other
        // than for compiler sanity during content creation.
        
        public static const PAD_NONE:uint    = 0;
        public static const PAD_BACK:uint    = 0;
        public static const PAD_START:uint   = 0;
        public static const PAD_A:uint       = 0;
        public static const PAD_B:uint       = 0;
        public static const PAD_X:uint       = 0;
        public static const PAD_Y:uint       = 0;
        public static const PAD_R1:uint      = 0;  // RightShoulder;
        public static const PAD_L1:uint      = 0;  // LeftShoulder;
        public static const PAD_R2:uint      = 0;  // RightTrigger;
        public static const PAD_L2:uint      = 0;  // LeftTrigger;
        public static const PAD_UP:uint      = 0;
        public static const PAD_DOWN:uint    = 0;
        public static const PAD_RIGHT:uint   = 0;
        public static const PAD_LEFT:uint    = 0;
        public static const PAD_PLUS:uint    = 0;
        public static const PAD_MINUS:uint   = 0;
        public static const PAD_1:uint       = 0;
        public static const PAD_2:uint       = 0;
        public static const PAD_H:uint       = 0;
        public static const PAD_C:uint       = 0;
        public static const PAD_Z:uint       = 0;
        public static const PAD_O:uint       = 0;
        public static const PAD_T:uint       = 0;
        public static const PAD_S:uint       = 0;
        public static const PAD_SELECT:uint  = 0;
        public static const PAD_HOME:uint    = 0;
        public static const PAD_RT:uint      = 0;   // RightThumb;
        public static const PAD_LT:uint      = 0;   // LeftThumb;
        
        // Will return true if the current platform supports emitting analog events
        // for specific game pad controls (such as RT - right thumb, etc.)
        public static function supportsAnalogEvents():Boolean    { return false; }
    }
}