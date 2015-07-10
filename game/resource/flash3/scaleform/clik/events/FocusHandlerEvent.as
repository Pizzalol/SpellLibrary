/**
 *  Event structure and defintions for the CLIK DragManager: 
 *  Valid types:
 *      FOCUS_IN - "CLIK_focusIn"
 *      FOCUS_OUT - "CLIK_focusOut"
 */

/**************************************************************************

Filename    :   FocusHandlerEvent.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

package scaleform.clik.events
{
    import flash.events.Event;
    
    public final class FocusHandlerEvent extends Event
    {
        
    // Constants:
        public static const FOCUS_IN:String = "CLIK_focusIn";
        public static const FOCUS_OUT:String = "CLIK_focusOut";
        
    // Public Properties:
        public var controllerIdx:uint = 0;
        
    // Protected Properties:
    
    // Initialization:
        public function FocusHandlerEvent(type:String, bubbles:Boolean = true, cancelable:Boolean = false, controllerIdx:uint = 0) { 
           super(type, bubbles, cancelable); 
           this.controllerIdx = controllerIdx;
        }
        
    // Public Methods:
        override public function clone():Event {
            return new FocusHandlerEvent(type, bubbles, cancelable, controllerIdx);
        }
        
        override public function toString():String {
            return formatToString("FocusHandlerEvent", "type", "bubbles", "cancelable", "controllerIdx");
        }
        
    // Protected Methods:
    
    }
    
}