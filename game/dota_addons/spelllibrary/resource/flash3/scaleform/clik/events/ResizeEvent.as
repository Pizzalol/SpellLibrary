/**
 *  Event structure and defintions for a generic resize event for all CLIK components. 
 *  Valid types:
 *      RESIZE - "resize"
 *      SCOPE_ORIGINALS_UPDATE - "scopeOriginalsUpdate"
 */

/**************************************************************************

Filename    :   ResizeEvent.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/
 
package scaleform.clik.events {
    import flash.events.Event;
    
    public class ResizeEvent extends Event {
        
    // Constants:
        public static const RESIZE:String = "resize";
        public static const SCOPE_ORIGINALS_UPDATE:String = "scopeOriginalsUpdate";
        
    // Public Properties:
        public var scaleX:Number = 1;
        public var scaleY:Number = 1;
        
    // Protected Properties:
        
    // Initialization:
        public function ResizeEvent(type:String, scaleX:Number, scaleY:Number) {
            super(type, false, false);
            this.scaleX = scaleX;
            this.scaleY = scaleY;
        }
        
    // Public getter / setters:
        
    // Public Methods:
        override public function toString():String {
            return formatToString("ResizeEvent", "type", "scaleX", "scaleY");
        }
        
        override public function clone():Event {
            return new ResizeEvent(type, scaleX, scaleY);
        }
        
    // Protected Methods:
        
    }
    
}