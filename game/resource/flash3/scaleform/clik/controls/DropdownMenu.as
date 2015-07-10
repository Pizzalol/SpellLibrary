/**
 * The DropdownMenu wraps the behavior of a button and a list. Clicking on this component opens a list that contains the elements to be selected. The DropdownMenu displays only the selected element in its idle state. It can be configured to use either the ScrollingList or the TileList, to which either a ScrollBar or ScrollIndicator can be paired with. The list is populated via an installed DataProvider. The DropdownMenu’s list element is populated via a DataProvider. The dataProvider is assigned via code, as shown in the example below:
 * <i>dropdownMenu.dataProvider = ["item1", "item2", "item3", "item4"];</i>
 *
 * <p><b>Inspectable Properties</b></p>
 * <p>
 * The inspectable properties of the DropdownMenu component are:<ul>
 * <li><i>autoSize</i>: Determines if the button will scale to fit the text that it contains and which direction to align the resized button. Setting the autoSize property to {@code autoSize="none"} will leave its current size unchanged.</li>
 * <li><i>dropdown</i>: Symbol name of the list component (ScrollingList or TileList) to use with the DropdownMenu component.</li>
 * <li><i>enabled</i>: Disables the button if set to false.</li>
 * <li><i>focusable</i>: By default buttons receive focus for user interactions. Setting this property to false will disable focus acquisition.</li>
 * <li><i>menuDirection:</i>The list open direction. Valid values are "up" and "down".</li>
 * <li><i>menuMargin</i>: The margin between the boundary of the list component and the list items created internally. This margin also affects the automatically generated scrollbar.</li>
 * <li><i>menuOffset</i>: Horizontal and vertical offsets of the dropdown list from the dropdown button position. A positive horizontal value moves the list to the right of the dropdown button horizontal position. A positive vertical value moves the list away from the button.</li>
 * <li><i>menuPadding</i>: Extra padding at the top, bottom, left, and right for the list items. Does not affect the automatically generated scrollbar.</li>
 * <li><i>menuRowCount</i>: The number of rows that the list should display.</li>
 * <li><i>menuWidth</i>: If set, this number will be enforced as the width of the menu.</li> 
 * <li><i>thumbOffset</i>: Scrollbar thumb top and bottom offsets. This property has no effect if the list does not automatically create a scrollbar instance.</li>
 * <li><i>scrollBar</i>: Symbol name of the dropdown list’s scroll bar. Created by the dropdown list instance. If value is empty, then the dropdown list will have no scroll bar.</li>
 * <li><i>visible</i>: Hides the component if set to false.</li>
 * </p>
 * 
 * <p><b>States</b></p>
 * <p>
 * The DropdownMenu is toggled when opened, and therefore needs the same states as a ToggleButton or CheckBox that denote the selected state. These states include <ul>
 * <li>an up or default state.</li>
 * <li>an over state when the mouse cursor is over the component, or when it is focused.</li>
 * <li>a down state when the button is pressed.</li>
 * <li>a disabled state.</li>
 * <li>a selected_up or default state.</li>
 * <li>a selected_over state when the mouse cursor is over the component, or when it is focused.</li>
 * <li>a selected_down state when the button is pressed.</li>
 * <li>a selected_disabled state.</li></ul>
 * </p>
 * 
 * <p><b>Events</b></p>
 * <p>
 * All event callbacks receive a single Object parameter that contains relevant information about the event. The following properties are common to all events. <ul>
 * <li><i>type</i>: The event type.</li>
 * <li><i>target</i>: The target that generated the event.</li></ul>
 *
 * <ul>
 *  <li><i>ComponentEvent.SHOW</i>: The visible property has been set to true at runtime.</li>
 *  <li><i>ComponentEvent.HIDE</i>: The visible property has been set to false at runtime.</li>
 *  <li><i>FocusHandlerEvent.FOCUS_IN</i>: The component has received focus.</li>
 *  <li><i>FocusHandlerEvent.FOCUS_OUT</i>: The component has lost focus.</li>
 *  <li><i>Event.SELECT</i>: The selected property has changed.</li>
 *  <li><i>ButtonEvent.PRESS</i>: The button has been pressed.</li>
 *  <li><i>ButtonEvent.CLICK</i>: The button has been clicked.</li>
 *  <li><i>ButtonEvent.DRAG_OVER</i>: The mouse cursor has been dragged over the button (while the left mouse button is pressed).</li>
 *  <li><i>ButtonEvent.DRAG_OUT</i>: The mouse cursor has been dragged out of the button (while the left mouse button is pressed).</li>
 *  <li><i>ButtonEvent.RELEASE_OUTSIDE</i>: The mouse cursor has been dragged out of the button and the left mouse button has been released.</li>
 *  <li><i>ListEvent.INDEX_CHANGE</i>: The selected index has changed.</li>
 * </ul>
 * </p>
*/
    
/**************************************************************************

Filename    :   DropdownMenu.as

Copyright   :   Copyright 2012 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

package scaleform.clik.controls 
{
    import flash.display.MovieClip;
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.system.ApplicationDomain;
    
    import scaleform.clik.constants.InvalidationType;
    import scaleform.clik.constants.InputValue;
    import scaleform.clik.constants.NavigationCode;
    import scaleform.clik.constants.WrappingMode
    import scaleform.clik.controls.Button;
    import scaleform.clik.data.DataProvider;
    import scaleform.clik.events.InputEvent;
    import scaleform.clik.events.ListEvent;
    import scaleform.clik.interfaces.IDataProvider;
    import scaleform.clik.managers.PopUpManager;
    import scaleform.clik.ui.InputDetails;
    import scaleform.clik.utils.Padding;
    
    [Event(name="change", type="flash.events.Event")]
    
    public class DropdownMenu extends Button 
    {
    // Constants:
    
    // Public Properties:
        /** Symbol name of the list component (ScrollingList or TileList) to use with the DropdownMenu component. */
        [Inspectable(type="String", defaultValue="CLIKScrollingList")]
        public var dropdown:Object = "CLIKScrollingList";
        [Inspectable(type="String", defaultValue="CLIKListItemRenderer")]
        public var itemRenderer:Object = "CLIKListItemRenderer";
        /** Symbol name of the dropdown list’s scroll bar. Created by the dropdown list instance. If value is empty, then the dropdown list will have no scroll bar. */
        [Inspectable(type="String")]
        public var scrollBar:Object;
        
        /** 
         * Determines how focus "wraps" when the end or beginning of the component is reached.
            <ul>
                <li>WrappingMode.NORMAL: The focus will leave the component when it reaches the end of the data</li>
                <li>WrappingMode.WRAP: The selection will wrap to the beginning or end.</li>
                <li>WrappingMode.STICK: The selection will stop when it reaches the end of the data.</li>
            </ul>
         */
        [Inspectable(enumeration="normal,stick,wrap", defaultValue="normal")]
        public var menuWrapping:String = WrappingMode.NORMAL;
        /** Direction the list opens. Valid values are "up" and "down". **/
        [Inspectable(enumeration="up,down", defaultValue="down")]
        public var menuDirection:String = "down";
        [Inspectable(defaultValue = "-1")]
        public var menuWidth:Number = -1;
        [Inspectable(defaultValue = "1")]
        public var menuMargin:Number = 1;
        [Inspectable(defaultValue = "5")]
        public var menuRowCount:Number = 5;
        [Inspectable(defaultFixedLength = "true")]
        public var menuRowsFixed:Boolean = true;
        // Inspectable menuPadding is handled by inspectableMenuPadding setter
        public var menuPadding:Padding;
        // Inspectable menuOffset is handled by inspectableMenuOffset setter
        public var menuOffset:Padding;
        // Inspectable thumbOffset is handled by inspectableThumbOffset setter
        public var thumbOffsetTop:Number;
        public var thumbOffsetBottom:Number;
        
    // Protected Properties:
        protected var _selectedIndex:int = -1;
        protected var _dataProvider:IDataProvider;
        protected var _labelField:String = "label";
        protected var _labelFunction:Function;
        protected var _popup:MovieClip;
        
    // UI Elements
        protected var _dropdownRef:MovieClip = null;
        
    // Initialization:
        /**
         * The constructor is called when a DropdownMenu or a sub-class of DropdownMenu is instantiated on stage or by using {@code attachMovie()} in ActionScript. This component can <b>not</b> be instantiated using {@code new} syntax. When creating new components that extend DropdownMenu, ensure that a {@code super()} call is made first in the constructor.
         */
        public function DropdownMenu() { 
            super();
        }
        
        override protected function initialize():void {
            dataProvider = new DataProvider(); // Default Data.
            menuOffset = new Padding(0, 0, 0, 0);
            menuPadding = new Padding(0, 0, 0, 0);
            super.initialize();
        }
        
    // Public Methods:
        // ** Override inspectables from base class
        override public function get autoRepeat():Boolean { return false; }
        override public function set autoRepeat(value:Boolean):void  { }
        override public function get data():Object { return null; }
        override public function set data(value:Object):void { }
        override public function get label():String { return ""; }
        override public function set label(value:String):void { }
        
        // These overrides must be valid
        override public function get selected():Boolean { return super.selected; }
        override public function set selected(value:Boolean):void { super.selected = value; }
        override public function get toggle():Boolean { return super.toggle; }
        override public function set toggle(value:Boolean):void { super.toggle = value;  }
        
        /** 
         * Extra padding at the top, bottom, left, and right for the list items. Does not affect the automatically generated ScrollBar.
         */
        [Inspectable(name="menuPadding", defaultValue="top:0,right:0,bottom:0,left:0")]
        public function set inspectableMenuPadding(value:Object):void {
            if (!componentInspectorSetting) { return; }
            menuPadding = new Padding(value.top, value.right, value.bottom, value.left);
        }
        
        /**
         * Offsets for the dropdown list from the dropdown button position. Does not affect the automatically generated ScrollBar.
         */
        [Inspectable(name="menuOffset", defaultValue="top:0,right:0,bottom:0,left:0")]
        public function set inspectableMenuOffset(value:Object):void {
            if (!componentInspectorSetting) { return; }
            menuOffset = new Padding(value.top, value.right, value.bottom, value.left);
        }
        
        /**
         * Scrollbar thumb top and bottom offsets. This property has no effect if the list does not automatically create a scrollbar instance.
         */
        [Inspectable(name="thumbOffset", defaultValue="top:0,bottom:0")]
        public function set inspectableThumbOffset(value:Object):void {
            if (!componentInspectorSetting) { return; }
            thumbOffsetTop = Number(value.top);
            thumbOffsetBottom = Number(value.bottom);
        }
        
        /**
         * Enable/disable focus management for the component. Setting the focusable property to 
         * {@code focusable=false} will remove support for tab key, direction key and mouse
         * button based focus changes.
         */
        [Inspectable(defaultValue="true")]
        override public function get focusable():Boolean { return _focusable; }
        override public function set focusable(value:Boolean):void { 
            super.focusable = value;
        }
        
        /**
         * The index of the item that is selected in a single-selection list. The DropdownMenu will always have 
         * a {@code selectedIndex} of 0 or greater, unless there is no data.
         */
        public function get selectedIndex():int { return _selectedIndex; }
        public function set selectedIndex(value:int):void {
            if (_selectedIndex == value) { return; }
            _selectedIndex = value;
            invalidateSelectedIndex();
            if (_dropdownRef != null) { 
                var dd:CoreList = _dropdownRef as CoreList;
                var offset:uint = (dd is ScrollingList) ? (dd as ScrollingList).scrollPosition : 0;
                dispatchEventAndSound(new ListEvent(ListEvent.INDEX_CHANGE, true, false, _selectedIndex, 
                                            -1, -1, dd.getRendererAt(_selectedIndex, offset), _dataProvider[_selectedIndex]));
            }
        }
        
        /**
         * The data model displayed in the component. The dataProvider can be an Array or any object exposing the 
         * appropriate API, defined in the {@code IDataProvider} interface. If an Array is set as the 
         * {@code dataProvider}, functionality will be mixed into it by the {@code DataProvider.initialize} method. 
         * When a new DataProvider is set, the {@code selectedIndex} property will be reset to 0.
         * @see DataProvider
         * @see IDataProvider
         */
        public function get dataProvider():IDataProvider { return _dataProvider; }
        public function set dataProvider(value:IDataProvider):void {
            if (_dataProvider == value) { return; }
            if (_dataProvider != null) {
                _dataProvider.removeEventListener(Event.CHANGE, handleDataChange, false);
            }
            _dataProvider = value;
            var len:int = _dataProvider.length;
            if (!menuRowsFixed && len > 0 && len < menuRowCount)
                menuRowCount = len;
            if (_dataProvider == null) { return; }
            _dataProvider.addEventListener(Event.CHANGE, handleDataChange, false, 0, true);
            invalidateData();
        }
        
        /**
         * The name of the field in the {@code dataProvider} to be displayed as the label for the TextInput field.
         * A {@code labelFunction}  will be used over a {@code labelField} if it is defined.
         * @see #itemToLabel()
         */
        public function get labelField():String { return _labelField; }
        public function set labelField(value:String):void {
            _labelField = value;
            invalidateData();
        }
        
        /**
         * The function used to determine the label for an item. A {@code labelFunction} will override a 
         * {@code labelField} if it is defined.
         * @see #itemToLabel()
         */
        public function get labelFunction():Function { return _labelFunction; }
        public function set labelFunction(value:Function):void {
            _labelFunction = value;
            invalidateData();
        }
        
        /**
         * Convert an item to a label string using the {@code labelField} and {@code labelFunction}.
         * @param item The item to convert to a label.
         * @returns The converted label string.
         * @see #labelField
         * @see #labelFunction
         */
        public function itemToLabel(item:Object):String {
            if (item == null) { return ""; }
            if (_labelFunction != null) {
                return _labelFunction(item);
            } else if ( item is String ) {
                return item.toString();
            }
            else if (_labelField != null && item[_labelField] != null) {
                return item[_labelField];
            }
            return item.toString();
        }
        
        /**
         * Open the dropdown list. The {@code selected} and {@code isOpen} properties of the DropdownMenu are 
         * set to {@code true} when open. Input will be passed to the dropdown when it is open before it is 
         * handled by the DropdownMenu.
         */
        public function open():void {
            selected = true;
            stage.addEventListener(MouseEvent.MOUSE_DOWN, handleStageClick, false, 0, true);
            
            showDropdown();
        }
        
        /**
         * Close the dropdown list. The list is not destroyed, the {@code visible} property is set to {@code false}. 
         * The {@code selected} property of the DropdownMenu is set to {@code false} when closed.
         */
        public function close():void {
            selected = false;
            stage.removeEventListener(MouseEvent.MOUSE_DOWN, handleStageClick, false);
            
            hideDropdown();
        }
        
        /**
         * Returns {@code true} if the dropdown list is open, {@code false} if not.
         */
        public function isOpen():Boolean {
            return (_dropdownRef != null);
        }
        
        /** Mark the selectedIndex as invalid and schedule a draw() on next Stage.INVALIDATE event. */
        public function invalidateSelectedIndex():void {
            invalidate(InvalidationType.SELECTED_INDEX);
        }
        
        /** @exclude */
        override public function handleInput(event:InputEvent):void {
            if (event.handled) { return; }
            
            if (_dropdownRef != null && selected) { 
                _dropdownRef.handleInput(event);
                if (event.handled) { return; }
            }
            
            super.handleInput(event);
            
            var details:InputDetails = event.details;
            var keyPress:Boolean = details.value == InputValue.KEY_DOWN;
            switch (details.navEquivalent) {
                case NavigationCode.ESCAPE:
                    if (selected) {
                        if (keyPress) { close(); }
                        event.handled = true;
                    }
                default:
                    break;
            }
        }
        
        /** @exclude */
        override public function toString():String { 
            return "[CLIK DropdownMenu " + name + "]";
        }
        
    // Protected Methods:
        override protected function draw():void {
            if (isInvalid(InvalidationType.SELECTED_INDEX) || isInvalid(InvalidationType.DATA)) {
                _dataProvider.requestItemAt(_selectedIndex, populateText);
                invalidateData(); // Button will update label only when data is invalid
            }
            
            // We call super.draw later so the base can update the label if it was changed during selectedIndex or data invalidation
            super.draw();
        }

        override protected function changeFocus():void {
            super.changeFocus();
            
            // If open, close the menu
            if (_selected && _dropdownRef) { close(); }
        }
        
        override protected function handleClick(controllerIndex:uint = 0):void {
            !_selected ? open() : close();
            super.handleClick();
        }
        
        protected function handleDataChange(event:Event):void {
            invalidate(InvalidationType.DATA);
        }
        
        
        protected function populateText(item:Object):void {
            updateLabel(item);
            dispatchEventAndSound(new Event(Event.CHANGE));
        }
        
        protected function updateLabel(item:Object):void {
            _label = itemToLabel(item);
        }
        
        protected function handleStageClick(event:MouseEvent):void {
            if (this.contains(event.target as DisplayObject)) { return; }
            if (this._dropdownRef.contains(event.target as DisplayObject)) { return; }
            close();
        }
        
        protected function showDropdown():void {
            if (dropdown == null) { return; }

            var domain:ApplicationDomain = ApplicationDomain.currentDomain;
            if (loaderInfo != null && loaderInfo.applicationDomain != null) domain = loaderInfo.applicationDomain;
            
            var dd:MovieClip;
            if (dropdown is String && dropdown != "") {
                var classRef:Class = domain.getDefinition(dropdown.toString()) as Class;
                
                if (classRef != null) { dd = new classRef() as CoreList; }
            }
            
            if (dd) {
                if (itemRenderer is String && itemRenderer != "") { dd.itemRenderer = domain.getDefinition(itemRenderer.toString()) as Class; }
                else if (itemRenderer is Class) { dd.itemRenderer = itemRenderer as Class; }
                
                if (scrollBar is String && scrollBar != "") { dd.scrollBar = domain.getDefinition(scrollBar.toString()) as Class; }
                else if (scrollBar is Class) { dd.scrollBar = scrollBar as Class; }
                
                dd.selectedIndex = _selectedIndex;
                dd.width = (menuWidth == -1) ? (width + menuOffset.left + menuOffset.right) : menuWidth;
                dd.dataProvider = _dataProvider;
                dd.padding = menuPadding;
                dd.wrapping = menuWrapping;
                dd.margin = menuMargin;
                dd.thumbOffset = { top:thumbOffsetTop, bottom:thumbOffsetBottom };
                dd.focusTarget = this;
                dd.rowCount = (menuRowCount < 1) ? 5 : menuRowCount;
                dd.labelField = _labelField; 
                dd.labelFunction = _labelFunction;
                dd.addEventListener(ListEvent.ITEM_CLICK, handleMenuItemClick, false, 0, true);
                
                _dropdownRef = dd;
                PopUpManager.show(dd, x + menuOffset.left, 
                    (menuDirection == "down") ? y + height + menuOffset.top : y - _dropdownRef.height + menuOffset.bottom,
                    parent);
            }
        }
        
        protected function hideDropdown():void {
            if (_dropdownRef) {
                _dropdownRef.parent.removeChild(_dropdownRef);
                _dropdownRef = null;
            }
        }
        
        protected function handleMenuItemClick(e:ListEvent):void {
            selectedIndex = e.index;
            close();
        }
    }
}
