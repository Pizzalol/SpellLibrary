/**
 * An abstract class used to display a list of data, and set a selectedIndex (or indices). This class only manages data, and instantiating itemRenderers, but the sub-class must request the renderers and arrange them. It is sub-classed by the ScrollingList and TileList components.
 */

/**************************************************************************

Filename    :   CoreList.as

Copyright   :   Copyright 2012 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

package scaleform.clik.controls 
{
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Rectangle;
    import flash.system.ApplicationDomain;
    
    import scaleform.clik.constants.InvalidationType;
    import scaleform.clik.core.UIComponent;
    import scaleform.clik.data.DataProvider;
    import scaleform.clik.events.InputEvent;
    import scaleform.clik.events.ListEvent;
    import scaleform.clik.events.ButtonEvent;
    import scaleform.clik.interfaces.IDataProvider;
    import scaleform.clik.interfaces.IListItemRenderer;
    
    import scaleform.gfx.MouseEventEx;
    
    public class CoreList extends UIComponent 
    {
    // Constants:
        
    // Public Properties:
        
    // Protected Properties:
        /** The current selectedIndex being displayed. */
        protected var _selectedIndex:int = -1; 
        /** The latest internal selectedIndex. Will be pushed to _selectedIndex next time updateSelectedIndex() is called. */
        protected var _newSelectedIndex:int = -1; 
        /** The dataProvider for the List. */
        protected var _dataProvider:IDataProvider;
        /**  The property name of the Objects within the DataPRovider that holds the label for the ListItemRenderers.  */
        protected var _labelField:String = "label";
        /**  The function to use to evaluate the label for the ListItemRenderer. */
        protected var _labelFunction:Function;
        
        /**  A reference to the class for the item renderers, used whenenever a new renderer is created.  */
        protected var _itemRenderer:Class;
        /**  The name of the Class for the ListItemRenderer. */
        protected var _itemRendererName:String = "DefaultListItemRenderer";
        /**  List of the current renderers. */
        protected var _renderers:Vector.<IListItemRenderer>;
        /**  true if the List is using external renderers; false if it generating them at runtime. */
        protected var _usingExternalRenderers:Boolean = false;
        /**  The number of usable renderers.  */
        protected var _totalRenderers:uint = 0;
        
        /**  The current state of the component being displayed. */
        protected var _state:String = "default";
        /**  The latest internal state of the component. Pushed to _state and displayed in draw(). */
        protected var _newFrame:String;
        
    // UI Elements:
        // The container MovieClip which the auto-generated ScrollBar will be added to.
        public var container:Sprite;
        
    // Initialization:
        public function CoreList() {
            super();
        }
        
        /** @private */
        override protected function initialize():void {
            dataProvider = new DataProvider(); // Default Data.
            super.initialize();
        }
        
    // Public Getter / Setters:
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
         * The linkage ID for the renderer used to display each item in the list. The list components only support
         * a single itemRenderer for all items.
         */
        [Inspectable(name = "itemRenderer", defaultValue = "DefaultListItemRenderer")]
        public function get itemRendererName():String { return _itemRendererName; }
        public function set itemRendererName(value:String):void {
            if ((_inspector && value == "") || value == "") { return; }
            
            var domain:ApplicationDomain = ApplicationDomain.currentDomain;
            if (loaderInfo != null && loaderInfo.applicationDomain != null) domain = loaderInfo.applicationDomain;
            var classRef:Class = domain.getDefinition(value) as Class;

            if (classRef != null) {
                itemRenderer = classRef;
            } else {
                trace("Error: " + this + ", The class " + value + " cannot be found in your library. Please ensure it is there.");
            }
        }
        
        /** Set the itemRenderer class. */
        public function get itemRenderer():Class { return _itemRenderer; }
        public function set itemRenderer(value:Class):void {
            _itemRenderer = value;
            invalidateRenderers();
        }
        
        /**
         * The name of data renderers to be used in this list instance. The names are a string followed by
         * consecutive numbers incrementing from 0 or 1. For instance "renderer1, renderer2, renderer3, etc". 
         * The renderers must be in the parent timeline of the list instance in order to be used. If a specific 
         * numbered clip is missing, then only the renderers up to that point will be used.
         */
        [Inspectable(defaultValue="")]
        public function set itemRendererInstanceName(value:String):void {

            if (value == null || value == "" || parent == null) { return; }
            var i:uint = 0;
            var newRenderers:Vector.<IListItemRenderer> = new Vector.<IListItemRenderer>();
            while (++i) {
                var clip:IListItemRenderer = parent.getChildByName(value + i) as IListItemRenderer;
                if (clip == null) { // No more in list. This allows renderers to start with 1 or 0
                    if (i == 0) { continue; }
                    break; 
                }
                newRenderers.push(clip);
            }
            
            if (newRenderers.length == 0) { 
                if (componentInspectorSetting) { return; }
                newRenderers = null; // Reverts to internal renderers.
            }
            itemRendererList = newRenderers;
        }
        
        /**
         * Set a list of external MovieClips to use as renderers, instead of auto-generating the renderers at run-time. 
         * The rendererInstance property uses this method to set the renderer list.
         */
        public function set itemRendererList(value:Vector.<IListItemRenderer>):void {
            var l:uint, i:uint;
            if (_usingExternalRenderers) {
                l = _renderers.length;
                for (i=0; i<l; i++) {
                    cleanUpRenderer(getRendererAt(i));
                }
            }
            
            _usingExternalRenderers = (value != null);
            _renderers = value;
            
            if (_usingExternalRenderers) {
                l = _renderers.length;
                for (i=0; i<l; i++) {
                    setupRenderer(getRendererAt(i));
                }
                _totalRenderers = _renderers.length;
            }
            invalidateRenderers();
        }
        
        /**
         * The index of the item that is selected in a single-selection list.
         */
        public function get selectedIndex():int { return _selectedIndex; }
        public function set selectedIndex(value:int):void {
            if (_selectedIndex == value) { return; }
            _selectedIndex = value;
            invalidateSelectedIndex();
            dispatchEventAndSound(new ListEvent(ListEvent.INDEX_CHANGE, true, false, _selectedIndex, -1, -1, getRendererAt(_selectedIndex), dataProvider[_selectedIndex]));
        }
        
        [Inspectable(defaultValue="true")]
        override public function get enabled():Boolean { return super.enabled; }
        override public function set enabled(value:Boolean):void {
            super.enabled = value;
            
            setState(super.enabled ? "default" : "disabled");
            
            // Pass enabled on to renderers
            if (_renderers != null) {
                var l:uint = _renderers.length;
                for (var i:uint=0; i<l; i++) {
                    var renderer:IListItemRenderer = getRendererAt(i);
                    renderer.enabled = enabled;
                }
            }
        }
        
        /**
         * The data model displayed in the component. The dataProvider must implement the 
         * {@code IDataProvider} interface. When a new DataProvider is set, the {@code selectedIndex}
         * property will be reset to 0.
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
            if (_dataProvider == null) { return; }
            
            _dataProvider.addEventListener(Event.CHANGE, handleDataChange, false, 0, true);
            invalidateData();
        }
        
        /**
         * The name of the field in the {@code dataProvider} model to be displayed as the label for itemRenderers.  
         * A {@code labelFunction} will be used over a {@code labelField} if it is defined.
         * @see #itemToLabel
         */
        public function get labelField():String { return _labelField; }
        public function set labelField(value:String):void {
            _labelField = value;
            invalidateData();
        }
        
        /**
         * The function used to determine the label for itemRenderers. A {@code labelFunction} will override a 
         * {@code labelField} if it is defined.
         * @see #itemToLabel
         */
        public function get labelFunction():Function { return _labelFunction; }
        public function set labelFunction(value:Function):void {
            _labelFunction = value;
            invalidateData();
        }
        
        // Abstract methods
        /**
         * The amount of the component's width that can be used for renderers.
         * This can be overridden to accommodate padding or ScrollBars.
         */
        public function get availableWidth():Number { return _width; }
        /**
         * The amount of the component's height that can be used for renderers. 
         * This can be overridden to accommodate padding or ScrollBars
         */
        public function get availableHeight():Number { return _height; }
        
    // Public Methods:
        // Abstract method
        public function scrollToIndex(index:uint):void {}
        
        public function scrollToSelected():void {
            scrollToIndex(_selectedIndex);
        }
        
        public function itemToLabel(item:Object):String {
            if (item == null) { return ""; }
            if (_labelFunction != null) {
                return _labelFunction(item);
            } else if (_labelField != null && _labelField in item && item[_labelField] != null) {
                return item[_labelField];
            }
            return item.toString();
        }
        
        /** 
         * Retrieve a reference to an IListItemRenderer of the List.
         * @param index The index of the renderer.
         * @param offset An offset from the original scrollPosition (normally, the scrollPosition itself).
         */
        public function getRendererAt(index:uint, offset:int=0):IListItemRenderer {
            if (_renderers == null) { return null; }
            var newIndex:uint = index - offset;
            if (newIndex >= _renderers.length) { return null; }
            return _renderers[newIndex] as IListItemRenderer;
        }
        
        /** Mark the item renderers as invalid and schedule a draw() on next Stage.INVALIDATE event. */
        public function invalidateRenderers():void {
            invalidate(InvalidationType.RENDERERS);
        }
        
        /** Mark the selectedIndex as invalid and schedule a draw() on next Stage.INVALIDATE event. */
        public function invalidateSelectedIndex():void {
            invalidate(InvalidationType.SELECTED_INDEX);
        }
        
        /** @private */
        override public function toString():String {
            return "[CLIK CoreList "+ name +"]";
        }
        
    // Protected Methods:
        override protected function configUI():void {
            super.configUI();
            
            if (container == null) { 
                container = new Sprite();
                addChild(container);
                //LM: We can't apply a grid this way like we could in AS2. Revisit if we have scaling issues.
                //container.scale9Grid = new Rectangle(0,0,0,0);
            }
            
            tabEnabled = (_focusable && enabled);
            tabChildren = false;
            
            addEventListener(MouseEvent.MOUSE_WHEEL, handleMouseWheel, false, 0, true);
            addEventListener(InputEvent.INPUT, handleInput, false, 0, true);
        }
        
        override protected function draw():void {
            if (isInvalid(InvalidationType.SELECTED_INDEX)) {
                updateSelectedIndex();
            }
            
            if (isInvalid(InvalidationType.STATE)) {
                if (_newFrame) {
                    gotoAndPlay(_newFrame);
                    _newFrame = null;
                }
            }
            
            var i:uint, l:uint, renderer:IListItemRenderer, displayObject:DisplayObject;
            // Remove old internal renderers
            if (!_usingExternalRenderers && isInvalid(InvalidationType.RENDERERS)) {
                if (_renderers != null) {
                    l = _renderers.length;
                    for (i=0; i<l; i++) {
                        renderer = getRendererAt(i);
                        cleanUpRenderer(renderer);
                        displayObject = renderer as DisplayObject;
                        if (container.contains(displayObject)) { container.removeChild(displayObject); }
                    }
                }
                _renderers = new Vector.<IListItemRenderer>();
                invalidateData();
            }
            
            // Counter-scale to ensure base component is the right size.
            if (!_usingExternalRenderers && isInvalid(InvalidationType.SIZE)) {
                removeChild(container);
                setActualSize(_width, _height);
                container.scaleX = 1 / scaleX;
                container.scaleY = 1 / scaleY;
                _totalRenderers = calculateRendererTotal(availableWidth, availableHeight);
                
                addChild(container);
                invalidateData();
            }
            
            // Create/Destroy renderers
            if (!_usingExternalRenderers && isInvalid(InvalidationType.RENDERERS, InvalidationType.SIZE)) {
                drawRenderers(_totalRenderers); // Update renderer count
                
                //TODO: For variable height, we would skip this until we had populated the data and measured it.
                drawLayout();
            }
            
            if (isInvalid(InvalidationType.DATA)) {
                refreshData(); // Renderers get invalidated here.
                //TODO: For variable-height, we would reflow at this point.
            }
        }
        
        /** @private */
        override protected function changeFocus():void {
            if (_focused || _displayFocus) {
                setState("focused", "default");
            } else {
                setState("default");
            }
        }
        
        protected function refreshData():void { }
        protected function updateSelectedIndex():void { }
        
        protected function calculateRendererTotal(width:Number, height:Number):uint {
            return height / 20 >> 0;
        }
        
        protected function drawLayout():void { }
        
        protected function drawRenderers(total:Number):void {
            if (_itemRenderer == null) {
                trace("Renderer class not defined."); return;
            }
            
            var i:int, l:int, renderer:IListItemRenderer, displayObject:DisplayObject;
            for (i = _renderers.length; i < _totalRenderers; i++) {
                renderer = createRenderer(i);
                if (renderer == null) { break; }
                _renderers.push(renderer);
                container.addChild(renderer as DisplayObject);
            }
            l = _renderers.length;
            for (i=l-1; i>=_totalRenderers; i--) {
                renderer = getRendererAt(i);
                if (renderer != null) {
                    cleanUpRenderer(renderer);
                    displayObject = renderer as DisplayObject;
                    if (container.contains(displayObject)) { container.removeChild(displayObject); }
                }
                _renderers.splice(i, 1);
            }
        }
        
        protected function createRenderer(index:uint):IListItemRenderer {
            var renderer:IListItemRenderer = new _itemRenderer() as IListItemRenderer;
            if (renderer == null) {
                trace("Renderer class could not be created."); return null;
            }
            // NFM: Future optimization - createRenderer(index, setup=true), don't setupRenderer() if !setup. Use createRenderer(0, false) when finding rendererHeight.
            setupRenderer(renderer);
            return renderer;
        }
        
        protected function setupRenderer(renderer:IListItemRenderer):void {
            renderer.owner = this;
            renderer.focusTarget = this;
            renderer.tabEnabled = false; // Children can still be tabEnabled, or the renderer could re-enable this. //LM: There is an issue with this. Setting disabled could automatically re-enable. Consider alternatives. 
            renderer.doubleClickEnabled = true;
            
            renderer.addEventListener(ButtonEvent.PRESS, dispatchItemEvent, false, 0, true);
            renderer.addEventListener(ButtonEvent.CLICK, handleItemClick, false, 0, true);
            renderer.addEventListener(MouseEvent.DOUBLE_CLICK, dispatchItemEvent, false, 0, true);
            renderer.addEventListener(MouseEvent.ROLL_OVER, dispatchItemEvent, false, 0, true);
            renderer.addEventListener(MouseEvent.ROLL_OUT, dispatchItemEvent, false, 0, true);
            
            if (_usingExternalRenderers) { 
                renderer.addEventListener(MouseEvent.MOUSE_WHEEL, handleMouseWheel, false, 0, true);
            }
        }
        
        protected function cleanUpRenderer(renderer:IListItemRenderer):void {
            renderer.owner = null;
            renderer.focusTarget = null;
            // renderer.tabEnabled = true;
            renderer.doubleClickEnabled = false; //LM: Could have unwanted behaviour when using external renderers.
            renderer.removeEventListener(ButtonEvent.PRESS, dispatchItemEvent);
            renderer.removeEventListener(ButtonEvent.CLICK, handleItemClick);
            renderer.removeEventListener(MouseEvent.DOUBLE_CLICK, dispatchItemEvent);
            renderer.removeEventListener(MouseEvent.ROLL_OVER, dispatchItemEvent);
            renderer.removeEventListener(MouseEvent.ROLL_OUT, dispatchItemEvent);
            renderer.removeEventListener(MouseEvent.MOUSE_WHEEL, handleMouseWheel);
        }
        
        protected function dispatchItemEvent(event:Event):Boolean {
            var type:String;
            switch (event.type) {
                case ButtonEvent.PRESS:
                    type = ListEvent.ITEM_PRESS; 
                    break;
                case ButtonEvent.CLICK:
                    type = ListEvent.ITEM_CLICK; 
                    break;
                case MouseEvent.ROLL_OVER:
                    type = ListEvent.ITEM_ROLL_OVER;
                    break;
                case MouseEvent.ROLL_OUT:
                    type = ListEvent.ITEM_ROLL_OUT; 
                    break;
                case MouseEvent.DOUBLE_CLICK:
                    type = ListEvent.ITEM_DOUBLE_CLICK; 
                    break;
                default:
                    return true;
            }
            
            var renderer:IListItemRenderer = event.currentTarget as IListItemRenderer;
            
            // Propogate the controller / mouse index.
            var controllerIdx:uint = 0;
            if (event is ButtonEvent) { controllerIdx = (event as ButtonEvent).controllerIdx; }
            else if (event is MouseEventEx) { controllerIdx = (event as MouseEventEx).mouseIdx; }
            
            var buttonIdx:uint = 0;
            if (event is ButtonEvent) { buttonIdx = (event as ButtonEvent).buttonIdx; }
            else if (event is MouseEventEx) { buttonIdx = (event as MouseEventEx).buttonIdx; }
            
            // Propogate whether the keyboard / gamepad generated this event.
            var isKeyboard:Boolean = false;
            if (event is ButtonEvent) { isKeyboard = (event as ButtonEvent).isKeyboard; }
            
            var newEvent:ListEvent = new ListEvent(type, false, true, renderer.index, 0, renderer.index, renderer, dataProvider[renderer.index], controllerIdx, buttonIdx, isKeyboard);
            return dispatchEventAndSound(newEvent);
        }
        
        protected function handleDataChange(event:Event):void {
            invalidate(InvalidationType.DATA);
        }
        
        protected function handleItemClick(event:ButtonEvent):void {
            var index:Number = (event.currentTarget as IListItemRenderer).index;
            if (isNaN(index)) { return; } // If the data has not been populated, but the listItemRenderer is clicked, it will have no index.
            if (dispatchItemEvent(event)) {
                selectedIndex = index;
            }
        }
        
        protected function handleMouseWheel(event:MouseEvent):void {
            scrollList(event.delta > 0 ? 1 : -1);
        }
        
        protected function scrollList(delta:int):void {}
        
        protected function setState(...states:Array):void {
            if (states.length == 1) {
                var onlyState:String = states[0].toString();
                if (_state != onlyState && _labelHash[onlyState]) { 
                    _state = _newFrame = onlyState;
                    invalidateState();
                }
                return;
            }
            var l:uint = states.length;
            for (var i:uint=0; i<l; i++) {
                var thisState:String = states[i].toString();
                if (_labelHash[thisState]) {
                    _state = _newFrame = thisState;
                    invalidateState();
                    break;
                }
            }
        }
        
    }
    
}
