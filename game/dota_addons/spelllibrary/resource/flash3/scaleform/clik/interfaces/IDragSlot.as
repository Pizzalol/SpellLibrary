/**
 * The public interface for all CLIK DragSlots and their subclasses.
 */

/**************************************************************************

Filename    :   IDragSlot.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

package scaleform.clik.interfaces {
    
    import flash.display.Sprite;
    
    import scaleform.clik.core.UIComponent;
    import scaleform.clik.events.DragEvent;

    public interface IDragSlot extends IUIComponent {
        
    // Public Getter / Setters:
        function get data():Object;
        function set data(value:Object):void;
        
        function get content():Sprite;
        function set content(value:Sprite):void;
        
    // Public Methods:
        function handleDropEvent(e:DragEvent):Boolean;
        function handleDragStartEvent(e:DragEvent):void;
        function handleDragEndEvent(e:DragEvent, wasValidDrop:Boolean):void;
    }
}