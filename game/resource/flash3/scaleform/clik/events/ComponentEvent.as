/**
 *  Event structure and defintions for all CLIK components: 
 *  Valid types:
 *      STATE_CHANGE - "stateChange"
 *      SHOW - "show"
 *      HIDE - "hide"
 */

/**************************************************************************

Filename    :   ComponentEvent.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/
 
package scaleform.clik.events {
    
    import flash.events.Event;
    
    public class ComponentEvent extends Event {
        
    // Constants:
        public static const STATE_CHANGE:String = "stateChange";
        public static const SHOW:String = "show";
        public static const HIDE:String = "hide";
        
    // Public Properties:
        
    // Protected Properties:
        
    // Initialization:
        public function ComponentEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=true) {
            super(type, bubbles, cancelable);
        }
        
    // Public getter / setters:
        
    // Public Methods:
        
    // Protected Methods:
        
    }
    
}