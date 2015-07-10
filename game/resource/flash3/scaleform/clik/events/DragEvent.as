/**
 *  Event structure and defintions for the CLIK DragManager: 
 *  Valid types:
 *      DRAG_START - "dragStart"
 *      DRAG_END - "dragEnd"
 *      DROP - "drop"
 */

/**************************************************************************

Filename    :   DragEvent.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/
 
package scaleform.clik.events {
    
    import flash.display.Sprite;
    import flash.events.Event;
    import scaleform.clik.interfaces.IDragSlot;
    
    public class DragEvent extends Event {
        
    // Constants:
        public static const DROP:String = "drop";
        public static const DRAG_START:String = "dragStart";
        public static const DRAG_END:String = "dragEnd";
        
    // Public Properties:
        public var dragData:Object;
        public var dragTarget:IDragSlot;
        public var dropTarget:IDragSlot;
        public var dragSprite:Sprite;
        
    // Protected Properties:
        
    // Initialization:
        public function DragEvent(type:String, data:Object, drag:IDragSlot, drop:IDragSlot, sprite:Sprite, bubbles:Boolean = true, cancelable:Boolean = true) {
            dragData = data;
            dragTarget = drag;
            dropTarget = drop;
            dragSprite = sprite;
            super(type, bubbles, cancelable);
        }
        
    // Public Getter / Setters:
        
    // Public Methods:
        
    // Protected Methods:
        
    }
}