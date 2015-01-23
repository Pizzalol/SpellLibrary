/**
 *  Event structure and defintions for a CLIK InputEvent: 
 *  Valid types:
 *      INPUT - "input"
 */

/**************************************************************************

Filename    :   InputEvent.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/
 
package scaleform.clik.events {
    
    import flash.events.Event;
    
    import scaleform.clik.ui.InputDetails;
    
    public class InputEvent extends Event {
        
    // Constants:
        public static const INPUT:String = "input";
        
    // Public Properties:
        public var details:InputDetails;
        
    // Protected Properties:
        
    // Initialization:
        public function InputEvent(type:String, details:InputDetails) {
            super(type, true, true);
            this.details = details;
        }
        
    // Public getter / setters:
        // This can be modified to use preventDefault, stopPropagation, or any other internal property depending on needs.
        public function get handled():Boolean { return isDefaultPrevented(); }
        public function set handled(value:Boolean):void {
            if (value) { preventDefault(); }
        }
        
    // Public Methods:	
        override public function clone():Event {
            return new InputEvent(type, details);
        }
        
        override public function toString():String {
            return formatToString("InputEvent", "type", "details");
        }
        
    }
    
}