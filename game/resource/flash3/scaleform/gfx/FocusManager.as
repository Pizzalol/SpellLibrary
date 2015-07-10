/**************************************************************************

Filename    :   FocusManager.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

package scaleform.gfx
{
    import flash.display.DisplayObjectContainer;
    import flash.display.InteractiveObject;
    import flash.display.Sprite;
    
    public final class FocusManager
    {
        static public function set alwaysEnableArrowKeys(enable:Boolean) : void {}
        static public function get alwaysEnableArrowKeys() : Boolean { return false; }
        
        static public function set disableFocusKeys(disable:Boolean) : void {}
        static public function get disableFocusKeys() : Boolean { return false; }
        
        static public function moveFocus(keyToSimulate : String, startFromMovie:InteractiveObject = null, includeFocusEnabledChars : Boolean = false, controllerIdx : uint = 0) : InteractiveObject { return null; }
        
        static public function findFocus(keyToSimulate : String, parentMovie:DisplayObjectContainer = null, loop : Boolean = false, startFromMovie:InteractiveObject = null, includeFocusEnabledChars : Boolean = false, controllerIdx : uint = 0) : InteractiveObject { return null; }
        
        static public function setFocus(obj:InteractiveObject, controllerIdx:uint = 0) : void { trace("FocusManager.setFocus is only usable with GFx. Use stage.focus property in Flash."); }
        static public function getFocus(controllerIdx:uint = 0) : InteractiveObject { trace("FocusManager.getFocus is only usable with GFx. Use stage.focus property in Flash."); return null; }
        
        static public function get numFocusGroups() : uint { return 1; }
        
        static public function setFocusGroupMask(obj:InteractiveObject, mask:uint) : void {}
        static public function getFocusGroupMask(obj:InteractiveObject) : uint { return 0x1; }
        
        static public function setControllerFocusGroup(controllerIdx:uint, focusGroupIdx:uint) : Boolean { return false; }
        static public function getControllerFocusGroup(controllerIdx:uint) : uint { return 0; }
        
        static public function getControllerMaskByFocusGroup(focusGroupIdx:uint) : uint { return 0; }
        
        static public function getModalClip(controllerIdx:uint = 0) : Sprite { return null; }
        static public function setModalClip(mc:Sprite, controllerIdx:uint = 0) : void {}
    }
}