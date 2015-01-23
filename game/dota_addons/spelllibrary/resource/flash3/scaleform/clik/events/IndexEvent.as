/**
 *  Event structure and defintions for a generic "index has changed" event: 
 *  Valid types:
 *      INDEX_CHANGE - "indexChange"
 */

/**************************************************************************

Filename    :   IndexEvent.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/
 
package scaleform.clik.events {
    
    import flash.events.Event;
    
    import scaleform.clik.controls.Button;
    import scaleform.clik.interfaces.IListItemRenderer;
    
    public class IndexEvent extends Event {
        
    // Constants:
        public static const INDEX_CHANGE:String = "clikIndexChange"; //LM: Evaluate.
        
    // Public Properties:
        public var index:int = -1;
        public var lastIndex:int = -1;
        public var data:Object;
        
    // Protected Properties:
        
    // Initialization:
        public function IndexEvent (type:String, bubbles:Boolean=false, cancelable:Boolean=true, 
                                    index:int=-1, lastIndex:int=-1, data:Object=null) {
            super(type, bubbles, cancelable);
            
            this.index = index;
            this.lastIndex = lastIndex;
            this.data = data;
        }
        
    // Public getter / setters:
        
    // Public Methods:
        override public function clone():Event {
            return new IndexEvent(type, bubbles, cancelable, index, lastIndex, data);
        }
        
        override public function toString():String {
            return formatToString("IndexEvent", "type", "bubbles", "cancelable", "index", "lastIndex", "data");
        }
        
    // Protected Methods:
        
    }
    
}