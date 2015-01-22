/**
 * The public interface that all item renderers must expose to be used in a list-type component, such as ScrollingList, TileList, etc. Note that this interface is not implemented in the existing components, and does not need to be implemented, it is just a reference.
 */

/**************************************************************************

Filename    :   IListItemRenderer.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

package scaleform.clik.interfaces {
    
    import flash.display.Sprite;
    
    import scaleform.clik.core.UIComponent;
    import scaleform.clik.data.ListData;

    public interface IListItemRenderer extends IUIComponent {
        
    // Public getter / setters:
        function get index():uint;
        function set index(value:uint):void;
        
        function get owner():UIComponent;
        function set owner(value:UIComponent):void;
        
        function get selectable():Boolean;
        function set selectable(value:Boolean):void;
        
        function get selected():Boolean;
        function set selected(value:Boolean):void;
        
        function get displayFocus():Boolean;
        function set displayFocus(value:Boolean):void;
        
    // Public Methods:
        function setListData(listData:ListData):void;
        
        function setData(data:Object):void;
        
    }
    
}