/**
 *  Event structure and defintions for the CLIK ButtonBar: 
 *  Valid types:
 *      BUTTON_SELECT - "buttonSelect"
 */

/**************************************************************************

Filename    :   ButtonBarEvent.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/
 
package scaleform.clik.events {
    
    import flash.events.Event;
    
    import scaleform.clik.controls.Button;
    
    public class ButtonBarEvent extends Event {
        
    // Constants:
        public static const BUTTON_SELECT:String = "buttonSelect";
        
    // Public Properties:
        public var index:int = -1;
        public var renderer:Button;
        
    // Protected Properties:
        
    // Initialization:
        public function ButtonBarEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=true, 
										index:int=-1, renderer:Button=null) {
            super(type, bubbles, cancelable);
            this.index = index;
            this.renderer = renderer;
        }
        
    // Public getter / setters:
        
    // Public Methods:
        override public function clone():Event {
            return new ButtonBarEvent(type, bubbles, cancelable, index, renderer);
        }
        
        override public function toString():String {
            return formatToString("ButtonBarEvent", "type", "bubbles", "cancelable", "index", "renderer");
        }
        
    // Protected Methods:
        
    }
    
}