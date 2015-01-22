/**
 *  Event structure and defintions for the CLIK Slider. 
 *  Valid types:
 *      VALUE_CHANGE - "valueChange"
 */

/**************************************************************************

Filename    :   SliderEvent.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/
 
package scaleform.clik.events {
    
    import flash.events.Event;
    
    import scaleform.clik.controls.Button;
    
    public class SliderEvent extends Event {
        
    // Constants:
        public static const VALUE_CHANGE:String = "valueChange";
        
    // Public Properties:
        public var value:Number = -1;
        
    // Protected Properties:
        
    // Initialization:
        public function SliderEvent( type:String, bubbles:Boolean=false, cancelable:Boolean=true, value:Number=-1) {
            super(type, bubbles, cancelable);
            this.value = value
        }
        
    // Public getter / setters:
        
    // Public Methods:
        override public function clone():Event {
            return new SliderEvent(type, bubbles, cancelable, value);
        }
        
        override public function toString():String {
            return formatToString("SliderEvent", "type", "bubbles", "cancelable", "value");
        }
        
    // Protected Methods:
        
    }
    
}