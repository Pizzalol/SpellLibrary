/**
 *  Event structure and defintions for the CLIK Dialog: 
 *  Valid types:
 *      CLOSE - "dialogClose"
 *      SUBMIT - "dialogSubmit"
 */

/**************************************************************************

Filename    :   DialogEvent.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/
 
package scaleform.clik.events {
    
    import flash.events.Event;
    
    public class DialogEvent extends Event {
        
    // Constants:
        public static const CLOSE:String = "dialogClose";
        public static const SUBMIT:String = "dialogSubmit";
        
    // Public Properties:
        
    // Protected Properties:
        
    // Initialization:
        public function DialogEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=true) {
            super(type, bubbles, cancelable);
        }
        
    // Public getter / setters:
        
    // Public Methods:
        
    // Protected Methods:
        
    }
    
}