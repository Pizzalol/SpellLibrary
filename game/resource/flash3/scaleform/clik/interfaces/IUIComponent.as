/**
 * The public interface for a UIComponent, the core of all CLIK components.
 */

/**************************************************************************

Filename    :   IUIComponent.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

package scaleform.clik.interfaces {
    
    import flash.events.Event;
    import flash.events.IEventDispatcher;
    import flash.geom.Rectangle;
    
    import scaleform.clik.core.UIComponent;
    import scaleform.clik.events.InputEvent;
    
    public interface IUIComponent extends IEventDispatcher {
        
    // Public Getter / Setters:
        
        // DisplayObject
        function get x():Number;
        function set x(value:Number):void;
        
        function get y():Number;
        function set y(value:Number):void;
        
        function get width():Number;
        function set width(value:Number):void;
        
        function get height():Number;
        function set height(value:Number):void;
        
        function get enabled():Boolean;
        function set enabled(value:Boolean):void;
        
        function get tabEnabled():Boolean;
        function set tabEnabled(value:Boolean):void;
        
        function get scale9Grid():Rectangle;
        function set scale9Grid(value:Rectangle):void;
        
        function get alpha():Number;
        function set alpha(value:Number):void;
        
        function get doubleClickEnabled():Boolean;
        function set doubleClickEnabled(value:Boolean):void;
        
        // CLIK
        function get focusTarget():UIComponent;
        function set focusTarget(value:UIComponent):void;
        
    // Public Methods:
        function validateNow(event:Event=null):void;
        function handleInput(event:InputEvent):void;
    }
}