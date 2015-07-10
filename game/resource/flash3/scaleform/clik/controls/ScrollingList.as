/**
    The ScrollingList is a list component that can scroll its elements. It can instantiate list items by itself 
    or use existing list items on the stage. A ScrollIndicator or ScrollBar component can also be attached to this
    list component to provide scoll feedback and control. This component is populated via a DataProvider. The 
    dataProvider is assigned via code, as shown in the example below:
    <i>scrollingList.dataProvider = ["item1", "item2", "item3", "item4", ];</i>

    <b>Inspectable Properties</b>
    A MovieClip that derives from the ScrollingList component will have the following inspectable properties:
    <ul>
        <li><i>enabled</i>: Disables the component if set to false. This disables both the attached scrollbar and the list items (both internally created and external renderers).</li>
        <li><i>focusable</i>: By default, ScrollingList can receive focus for user interactions. Setting this property to false will disable focus acquisition.</li>
        <li><i>itemRenderer</i>: The symbol name of the ListItemRenderer. Used to create list item instances internally. Has no effect if the rendererInstanceName property is set.</li>
        <li><i>rendererInstanceName</i>: Prefix of the external list item renderers to use with this ScrollingList component. The list item instances on the stage must be prefixed with this property value. If this property is set to the value ‘r’, then all list item instances to be used with this component must have the following values: ‘r1’, ‘r2’, ‘r3’,… The first item should have the number 1.</li>
        <li><i>margin</i>: The margin between the boundary of the list component and the list items created internally. This value has no effect if the rendererInstanceName property is set. This margin also affects the automatically generated scrollbar.</li>
        <li><i>rowHeight</i>: The height of list item instances created internally. This value has no effect if the rendererInstanceName property is set.</li>
        <li><i>padding:</i> Extra padding at the top, bottom, left, and right for the list items. This value has no effect if the rendererInstanceName property is set. Does not affect the automatically generated scrollbar.</li>
        <li><i>thumbOffset:</i> ScrollIndicator thumb offset for top and bottom. Passed through to ScrollIndicator. This property has no effect if the list does not automatically create a scrollbar instance.</li>
        <li><i>thumbSizeFactor:</i> Page size factor for the scrollbar thumb. A value greater than 1.0 will increase the thumb size by the given factor. This positive value has no effect if a scrollbar is not attached to the list.</li>
        <li><i>scrollBar</i>: Instance name of a ScrollBar component on the stage or a symbol name. If an instance name is specified, then the ScrollingList will hook into that instance. If a symbol name is specified, an instance of the symbol will be created by the ScrollingList.</li>
        <li><i>visible</i>: Hides the component if set to false. This does not hide the attached scrollbar or any external list item renderers.</li>
    </ul>
    
    <b>States</b>
    The ScrollingList component supports three states based on its focused and disabled properties.
    <ul>
        <li>default or enabled state.</li>
        <li>focused state, that typically highlights the component’s border area.</li>
        <li>disabled state.</li>
    </ul>
    
    <b>Events</b>
    All event callbacks receive a single Object parameter that contains relevant information about the event. The following properties are common to all events. <ul>
    <li><i>type</i>: The event type.</li>
    <li><i>target</i>: The target that generated the event.</li></ul>
    
    <ul>
        <li><i>ComponentEvent.SHOW</i>: The visible property has been set to true at runtime.</li>
        <li><i>ComponentEvent.HIDE</i>: The visible property has been set to false at runtime.</li>
        <li><i>FocusHandlerEvent.FOCUS_IN</i>: The button has received focus.</li>
        <li><i>FocusHandlerEvent.FOCUS_OUT</i>: The button has lost focus.</li>
        <li><i>ComponentEvent.STATE_CHANGE</i>: The button's state has changed.</li>
        <li><i>ListEvent.ITEM_PRESS</i>: A list item has been pressed down.</li>
        <li><i>ListEvent.ITEM_CLICK</i>: A list item has been clicked.</li>
        <li><i>ListEvent.ITEM_ROLL_OVER</i>: The mouse cursor has rolled over a list item.</li>
        <li><i>ListEvent.ITEM_ROLL_OUT</i>: The mouse cursor has rolled out of a list item.</li>
        <li><i>ListEvent.ITEM_DOUBLE_CLICK</i>: The mouse cursor has been double clicked on a list item.</li>
        <li><i>ListEvent.INDEX_CHANGE</i>: The selected index has changed.</li>
    </ul>
 */

/**************************************************************************

Filename    :   ScrollingList.as

Copyright   :   Copyright 2012 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

package scaleform.clik.controls {
    
    import flash.display.DisplayObject;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    import flash.system.ApplicationDomain;
    
    import scaleform.clik.constants.WrappingMode;
    import scaleform.clik.controls.ScrollBar;
    import scaleform.clik.constants.InvalidationType;
    import scaleform.clik.data.ListData;
    import scaleform.clik.events.InputEvent;
    import scaleform.clik.interfaces.IScrollBar;
    import scaleform.clik.interfaces.IListItemRenderer;
    import scaleform.clik.constants.InputValue;
    import scaleform.clik.ui.InputDetails;
    import scaleform.clik.constants.NavigationCode;
    import scaleform.clik.utils.Padding;
    
    [Event(name="change", type="flash.events.Event")]
    [Event(name="itemClick", type="scaleform.clik.events.ListEvent")]
    [Event(name="itemPress", type="scaleform.clik.events.ListEvent")]
    [Event(name="itemRollOver", type="scaleform.clik.events.ListEvent")]
    [Event(name="itemRollOut", type="scaleform.clik.events.ListEvent")]
    [Event(name="itemDoubleClick", type="scaleform.clik.events.ListEvent")]
    
    public class ScrollingList extends CoreList {
        
    // Constants:
        
    // Public Properties:
        //public var autoRowCount:Number; //LM: Do we need this? Might want to use an autoRowHeight:Boolean or something.
        /** 
         * Determines how focus "wraps" when the end or beginning of the component is reached.
            <ul>
                <li>WrappingMode.NORMAL: The focus will leave the component when it reaches the end of the data</li>
                <li>WrappingMode.WRAP: The selection will wrap to the beginning or end.</li>
                <li>WrappingMode.STICK: The selection will stop when it reaches the end of the data.</li>
            </ul>
         */
        [Inspectable(enumeration="normal,stick,wrap", defaultValue="normal")]
        public var wrapping:String = WrappingMode.NORMAL;
        /** ScrollIndicator thumb offset for top and bottom. Passed through to ScrollIndicator. This property has no effect if the list does not automatically create a scrollbar instance. */
        public var thumbOffset:Object;
        /** Page size factor for the scrollbar thumb. A value greater than 1.0 will increase the thumb size by the given factor. This positive value has no effect if a scrollbar is not attached to the list. */
        public var thumbSizeFactor:Number = 1;
        
    // Protected Properties:
        protected var _rowHeight:Number = NaN;
        protected var _autoRowHeight:Number = NaN;
        protected var _rowCount:Number = NaN;
        protected var _scrollPosition:uint = 0;
        protected var _autoScrollBar:Boolean = false;
        protected var _scrollBarValue:Object;
        protected var _margin:Number = 0;
        protected var _padding:Padding;
        
    // UI Elements:
        protected var _scrollBar:IScrollBar;
        
    // Initialization:
        public function ScrollingList() {
            super();
        }
        
        override protected function initialize():void {
            super.initialize();
        }
        
    // Public getter / setters:
        /**
         *  The margin between the boundary of the list component and the list items created internally. This value has no effect if the rendererInstanceName property is set. This margin also affects the automatically generated scrollbar.
         */
        [Inspectable(defaultValue="0")]
        public function get margin():Number { return _margin; }
        public function set margin(value:Number):void {
            _margin = value;
            invalidateSize();
        }
        
        /** 
         * Extra padding at the top, bottom, left, and right for the list items. Does not affect the automatically generated scrollbar. 
         */
        public function get padding():Padding { return _padding; }
        public function set padding(value:Padding):void {
            _padding = value;
            invalidateSize();
        }
        
        /** @exclude */
        [Inspectable(name="padding", defaultValue="top:0,right:0,bottom:0,left:0")]
        public function set inspectablePadding(value:Object):void {
            if (!componentInspectorSetting) { return; }
            padding = new Padding(value.top, value.right, value.bottom, value.left);
        }
        
        /**
         * The component to use to scroll the list. The {@code scrollBar} can be set as a library linkage ID,
         * an instance name on the stage relative to the component, or a reference to an existing ScrollBar 
         * elsewhere in the application. The automatic behaviour in this component only supports a vertical 
         * scrollBar, positioned on the top right, the entire height of the component.
         * @see ScrollBar
         * @see ScrollIndicator
         */
        [Inspectable(type="String")]
        public function get scrollBar():Object { return _scrollBar; }
        public function set scrollBar(value:Object):void {
            _scrollBarValue = value;
            invalidate(InvalidationType.SCROLL_BAR);
        }
        
        /**
         * The vertical scroll position of the list.
         */
        public function get scrollPosition():Number { return _scrollPosition; }
        public function set scrollPosition(value:Number):void {
            value = Math.max(0, Math.min(_dataProvider.length - _totalRenderers, Math.round(value)));
            if (_scrollPosition == value) { return; }
            _scrollPosition = value;
            invalidateData();
            /* //LM: Moved to invalidation.
            refreshData();
            updateScrollBar();*/
        }
        
        /**
         * The selected index of the {@code dataProvider}.  The {@code itemRenderer} at the {@code selectedIndex}
         * will be set to {@code selected=true}.
         */
        override public function set selectedIndex(value:int):void {
            if (value == _selectedIndex || value == _newSelectedIndex) { return; }
            _newSelectedIndex = value;
            invalidateSelectedIndex();
        }
        
        /**
         * The amount of visible rows.  Setting this property will immediately change the height of the component
         * to accomodate the specified amount of rows. The {@code rowCount} property is not stored or maintained.
         */
        public function get rowCount():uint { return _totalRenderers; }
        public function set rowCount(value:uint):void {
            var h:Number = rowHeight;
            if (isNaN(rowHeight)) { calculateRendererTotal(availableWidth, availableHeight); }
            h = rowHeight;
            height = (h * value) + (margin * 2); // + padding.horizontal;
        }
        
        /**
         * The height of each item in the list.  When set to {@code null} or 0, the default height of the
         * renderer symbol is used.
         */
        [Inspectable(defaultValue="0")]
        public function get rowHeight():Number { return isNaN(_autoRowHeight) ? _rowHeight : _autoRowHeight; }
        public function set rowHeight(value:Number):void {
            if (value == 0) {
                value = NaN;
                if (_inspector){ return; }
            }
            _rowHeight = value;
            _autoRowHeight = NaN;
            invalidateSize();
        }
        
        /** Retireve the available width of the component. */
        override public function get availableWidth():Number {
            return Math.round(_width) - (margin * 2)- (_autoScrollBar ? Math.round(_scrollBar.width) : 0);
        }
        
        /** Retrieve the available height of the component (internal height - margin). */
        override public function get availableHeight():Number {
            return Math.round(_height) - (margin * 2);
        }
        
    // Public Methods:
        /**
         * Scroll the list to the specified index.  If the index is currently visible, the position will not change. The scroll position will only change the minimum amount it has to to display the item at the specified index.
         * @param index The index to scroll to.
         */
        override public function scrollToIndex(index:uint):void {
            if (_totalRenderers == 0) { return; }
            if (index >= _scrollPosition && index < _scrollPosition + _totalRenderers) {
                return;
            } else if (index < _scrollPosition) {
                scrollPosition = index;
            } else {
                scrollPosition = index - (_totalRenderers-1);
            }
        }
        
        /** @exclude */
        override public function handleInput(event:InputEvent):void {
            if (event.handled) { return; } // Already Handled.
            
            // Pass on to selected renderer first
            var renderer:IListItemRenderer = getRendererAt(_selectedIndex, _scrollPosition);
            if (renderer != null) {
                renderer.handleInput(event); // Since we are just passing on the event, it won't bubble, and should properly stopPropagation.
                if (event.handled) { return; }
            }
            
            // Only allow actions on key down, but still set handled=true when it would otherwise be handled.
            var details:InputDetails = event.details;
            var keyPress:Boolean = (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD);
            switch(details.navEquivalent) {
                case NavigationCode.UP:
                    if (selectedIndex == -1) {
                        if (keyPress) { selectedIndex = scrollPosition + _totalRenderers - 1; }
                    } else if (_selectedIndex > 0) {
                        if (keyPress) { selectedIndex--; }
                    } else if (wrapping == WrappingMode.STICK) {
                        // Nothing.
                    } else if (wrapping == WrappingMode.WRAP) {
                        if (keyPress) { selectedIndex = _dataProvider.length-1; }
                    } else {
                        return;
                    }
                    break;
                
                case NavigationCode.DOWN:
                    if (_selectedIndex == -1) {
                        if (keyPress) selectedIndex = _scrollPosition;
                    } else if (_selectedIndex < _dataProvider.length-1) {
                        if (keyPress) { selectedIndex++; }
                    } else if (wrapping == WrappingMode.STICK) {
                        // Nothing
                    } else if (wrapping == WrappingMode.WRAP) {
                        if (keyPress) { selectedIndex = 0; }
                    } else {
                        return;
                    }
                    break;
                    
                case NavigationCode.END:
                    if (!keyPress) {
                        selectedIndex = _dataProvider.length-1;
                    }
                    break;
                    
                case NavigationCode.HOME:
                    if (!keyPress) { selectedIndex = 0; }
                    break;
                    
                case NavigationCode.PAGE_UP:
                    if (keyPress) { selectedIndex = Math.max(0, _selectedIndex - _totalRenderers); }
                    break;
                    
                case NavigationCode.PAGE_DOWN:
                    if (keyPress) { selectedIndex = Math.min(_dataProvider.length-1, _selectedIndex + _totalRenderers); }
                    break;
                    
                default:
                    return;
            }
            
            event.handled = true;
        }
        
        /** @exclude */
        override public function toString():String {
            return "[CLIK ScrollingList "+ name +"]";
        }
        
    // Protected Methods:
        override protected function configUI():void {
            super.configUI();
            if (padding == null) { padding = new Padding(); }
            if (_itemRenderer == null && !_usingExternalRenderers) { itemRendererName = _itemRendererName }
        }
        
        override protected function draw():void {
            if (isInvalid(InvalidationType.SCROLL_BAR)) {
                createScrollBar();
            }
            
            if (isInvalid(InvalidationType.RENDERERS)) {
                _autoRowHeight = NaN;
            }
            
            super.draw();
            
            if (isInvalid(InvalidationType.DATA)) {
                updateScrollBar();
            }
        }
        
        override protected function drawLayout():void {
            var l:uint = _renderers.length;
            var h:Number = rowHeight;
            var w:Number = availableWidth - padding.horizontal;
            var rx:Number = margin + padding.left;
            var ry:Number = margin + padding.top;
            var dataWillChange:Boolean = isInvalid(InvalidationType.DATA);
            for (var i:uint = 0; i < l; i++) {
                var renderer:IListItemRenderer = getRendererAt(i);
                renderer.x = rx;
                renderer.y = ry + i * h;
                renderer.width = w;
                renderer.height = h;
                if (!dataWillChange) { renderer.validateNow(); }
            }
            drawScrollBar();
        }
        
        protected function createScrollBar():void {
            if (_scrollBar) {
                _scrollBar.removeEventListener(Event.SCROLL, handleScroll, false);
                _scrollBar.removeEventListener(Event.CHANGE, handleScroll, false);
                _scrollBar.focusTarget = null;
                if (container.contains(_scrollBar as DisplayObject)) { container.removeChild(_scrollBar as DisplayObject); }
                _scrollBar = null;
            }

            if (!_scrollBarValue || _scrollBarValue == "") { return; }
            
            _autoScrollBar = false; // Reset
            
            var sb:IScrollBar;
            if (_scrollBarValue is String) {
                if (parent != null) {
                    sb = parent.getChildByName(_scrollBarValue.toString()) as IScrollBar;
                }
                if (sb == null) {
                    var domain : ApplicationDomain = ApplicationDomain.currentDomain;
                    if (loaderInfo != null && loaderInfo.applicationDomain != null) domain = loaderInfo.applicationDomain;
                    var classRef:Class = domain.getDefinition(_scrollBarValue.toString()) as Class;                    
                    
                    if (classRef) { 
                        sb = new classRef() as IScrollBar; 
                    }
                    if (sb) {
                        _autoScrollBar = true;
                        var sbInst:Object = sb as Object;
                        if (sbInst && thumbOffset) {
                            sbInst.offsetTop = thumbOffset.top;
                            sbInst.offsetBottom = thumbOffset.bottom;
                        }
                        sb.addEventListener(MouseEvent.MOUSE_WHEEL, blockMouseWheel, false, 0, true); // Prevent duplicate scroll events
                        //if (sb.scale9Grid == null) { sb.scale9Grid = new Rectangle(0,0,1,1); } // Prevent scaling
                        container.addChild(sb as DisplayObject);
                    }
                }
            } else if (_scrollBarValue is Class) {
                sb = new (_scrollBarValue as Class)() as IScrollBar;
                sb.addEventListener(MouseEvent.MOUSE_WHEEL, blockMouseWheel, false, 0, true);
                if (sb != null) {
                    _autoScrollBar = true;
                    (sb as Object).offsetTop = thumbOffset.top;
                    (sb as Object).offsetBottom = thumbOffset.bottom;
                    container.addChild(sb as DisplayObject);
                }
            } else {
                sb = _scrollBarValue as IScrollBar;
            }
            _scrollBar = sb;
            
            invalidateSize(); // Redraw to reset scrollbar bounds, even if there is no scrollBar.
            
            if (_scrollBar == null) { return; }
            // Now that we have a scrollBar, lets set it up.
            _scrollBar.addEventListener(Event.SCROLL, handleScroll, false, 0, true);
            _scrollBar.addEventListener(Event.CHANGE, handleScroll, false, 0, true);
            _scrollBar.focusTarget = this;
            _scrollBar.tabEnabled = false;
        }
        
        protected function drawScrollBar():void {
            if (!_autoScrollBar) { return; }
            _scrollBar.x = _width - _scrollBar.width - margin;
            _scrollBar.y = margin;
            _scrollBar.height = availableHeight;
            _scrollBar.validateNow();
        }
        
        protected function updateScrollBar():void {
            if (_scrollBar == null) { return; }
            var max:Number = Math.max(0, _dataProvider.length - _totalRenderers);
            if (_scrollBar is ScrollIndicator) {
                var scrollIndicator:ScrollIndicator = _scrollBar as ScrollIndicator;
                scrollIndicator.setScrollProperties(_dataProvider.length-_totalRenderers, 0, _dataProvider.length-_totalRenderers);
                //scrollIndicator.trackScrollPageSize = Math.max(1, _totalRenderers);
            } else {
                // Min/max
            }
            _scrollBar.position = _scrollPosition;
            _scrollBar.validateNow();
        }
        
        override protected function changeFocus():void {
            super.changeFocus();
            var renderer:IListItemRenderer = getRendererAt(_selectedIndex, _scrollPosition);
            if (renderer != null) {
                renderer.displayFocus = (focused > 0);
                renderer.validateNow();
            }
        }
        
        override protected function refreshData():void {
            _scrollPosition = Math.min(Math.max(0, _dataProvider.length - _totalRenderers), _scrollPosition);
            selectedIndex = Math.min(_dataProvider.length - 1, _selectedIndex);
            updateSelectedIndex();
            _dataProvider.requestItemRange(_scrollPosition, Math.min(_dataProvider.length - 1, _scrollPosition + _totalRenderers - 1), populateData);
        }
        
        override protected function updateSelectedIndex():void {
            if (_selectedIndex == _newSelectedIndex) { return; }
            if (_totalRenderers == 0) { return; } // Return if there are no renderers
            
            var renderer:IListItemRenderer = getRendererAt(_selectedIndex, scrollPosition);
            if (renderer != null) {
                renderer.selected = false; // Only reset items in range
                renderer.validateNow();
            }
            
            super.selectedIndex = _newSelectedIndex; // Reset the new selected index value if we found a renderer instance
            if (_selectedIndex < 0 || _selectedIndex >= _dataProvider.length) { return; }
            
            renderer = getRendererAt(_selectedIndex, _scrollPosition);
            if (renderer != null) {
                renderer.selected = true; // Item is in range. Just set it.
                renderer.validateNow();
            } else {
                scrollToIndex(_selectedIndex); // Will redraw
                renderer = getRendererAt(_selectedIndex, scrollPosition);
                renderer.selected = true; // Item is in range. Just set it.
                renderer.validateNow();
            }
        }
        
        override protected function calculateRendererTotal(width:Number, height:Number):uint {
            if (isNaN(_rowHeight) && isNaN(_autoRowHeight)) {
                var renderer:IListItemRenderer = createRenderer(0);
                _autoRowHeight = renderer.height;
                cleanUpRenderer(renderer);
            }
            
            return (availableHeight - padding.vertical) / rowHeight >> 0;
        }
        
        protected function handleScroll(event:Event):void {
            scrollPosition = _scrollBar.position;
        }
    
        protected function populateData(data:Array):void {
            var dl:uint = data.length;
            var l:uint = _renderers.length;
            for (var i:uint = 0; i < l; i++) {
                var renderer:IListItemRenderer = getRendererAt(i);
                var index:uint = _scrollPosition + i;
                var listData:ListData = new ListData(index, itemToLabel(data[i]), _selectedIndex == index);
                renderer.enabled = (i >= dl) ? false : true;
                renderer.setListData(listData); //LM: Consider passing renderer position also. (Support animation)
                renderer.setData(data[i]);
                renderer.validateNow();
            }
        }
        
        override protected function scrollList(delta:int):void {
            scrollPosition -= delta;
        }
        
        protected function blockMouseWheel(event:MouseEvent):void {
            event.stopPropagation();
        }
    }
}
