/**
 * TextArea is an editable text field component that supports multi-line text and an optional ScrollBar. It is derived from the CLIK TextInput component and thus includes all of the functionality and properties of TextInput. TextArea also shares the same states as its parent component.
 
    <b>Inspectable Properties</b>
    The inspectable properties of the TextArea component are similar to TextInput with a couple of additions and the omission of the password property. The additions are related to the CLIK ScrollBar component:
    <ul>
        <li><i>text</i>: Sets the text of the textField.</li>
        <li><i>visible</i>: Hides the component if set to false.</li>
        <li><i>disabled</i>: Disables the component if set to true.</li>
        <li><i>editable</i>: Makes the TextInput non-editable if set to false.</li>
        <li><i>maxChars</i>: A number greater than zero limits the number of characters that can be entered in the textField.</li>
        <li><i>scrollBar</i>: Instance name of the CLIK ScrollBar component to use, or a linkage ID to the ScrollBar symbol – an instance will be created by the TextArea in this case.</li>
        <li><i>scrollPolicy</i>: When set to “auto” the scrollBar will only show if there is enough text to scroll. The ScrollBar will always display if set to “on”, and never display if set to “off”. This property only affects the component if a ScrollBar is assigned to it (see the scrollBar property).</li>
        <li><i>defaultText</i>: Text to display when the textField is empty. This text is formatted by the defaultTextFormat object, which is by default set to light gray and italics.</li>
        <li><i>actAsButton</i>: If true, then the TextArea will behave similar to a Button when not focused and support rollOver and rollOut states. Once focused via mouse press or tab, the TextArea reverts to its normal mode until focus is lost.</li>
        <li><i>enableInitCallback</i>: If set to true, _global.CLIK_loadCallback() will be fired when a component is loaded and _global.CLIK_unloadCallback will be called when the component is unloaded. These methods receive the instance name, target path, and a reference the component as parameters.  _global.CLIK_loadCallback and _global.CLIK_unloadCallback should be overriden from the game engine using GFx FunctionObjects.</li>
    </ul>

    <b>States</b>
    Like its parent, TextInput, the TextArea component supports three states based on its focused and disabled properties.
    <ul>
        <li>default or enabled state.</li>
        <li>focused state, typically a represented by a highlighted border around the textField.</li>
        <li>disabled state.</li>
    </ul>
*/

/**************************************************************************

Filename    :   TextArea.as

Copyright   :   Copyright 2012 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

package scaleform.clik.controls 
{
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.system.ApplicationDomain;
    
    import scaleform.gfx.Extensions; // Allows for a basic ifScalefrom() check in draw().
    
    import scaleform.clik.constants.ConstrainMode;
    import scaleform.clik.constants.InputValue;
    import scaleform.clik.constants.InvalidationType;
    import scaleform.clik.constants.NavigationCode;
    import scaleform.clik.controls.TextInput;
    import scaleform.clik.events.ComponentEvent;
    import scaleform.clik.events.InputEvent;
    import scaleform.clik.interfaces.IScrollBar;
    import scaleform.clik.ui.InputDetails;
    import scaleform.clik.utils.ConstrainedElement;
    import scaleform.clik.utils.Constraints;
    import scaleform.clik.utils.Padding;
    
    public class TextArea extends TextInput
    {
        
    // Constants:
    
    // Public Properties:
        
    // Protected Properties:
        protected var _scrollPolicy:String = "auto";
        // The current scroll position of the TextArea.
        protected var _position:int = 1;
        // Internal property used to to track the maximum scroll position for the TextArea.
        protected var _maxScroll:Number = 1;
        // Internal property to track whether the textField.scrollV should be updated.
        protected var _resetScrollPosition:Boolean = false;        
        // A String that refers to a ScrollIndicator instance name or a Symbol's export name.
        protected var _scrollBarValue:Object;
        // true if the ScrollIndicator was auto-generated; false it was already on the stage.
        protected var _autoScrollBar:Boolean = false;
        // Offsets passed to auto-generated ScrollIndicator.
        protected var _thumbOffset:Object = { top:0, bottom:0 }
        // Minimum thumb size passed to auto-generated ScrollIndicator.
        protected var _minThumbSize:uint = 1;
    
    // UI Elements:
        /** A reference to the IScrollBar associated with this TextArea. */
        protected var _scrollBar:IScrollBar;
        /** A container within the TextArea that any auto-generated content will be attached to. */
        public var container:Sprite;

    // Initialization:
        public function TextArea() {
            super();
        }
        
        override protected function preInitialize():void {
            if (!constraintsDisabled) {
                constraints = new Constraints(this, ConstrainMode.COUNTER_SCALE);
            }
        }
        
        override protected function initialize():void {
            super.initialize();
            
            // Take care of creating the container here so that it's available for set scrollBar which may be called by inspectables.
            if (container == null) {
                container = new Sprite();
                addChild(container);
            }
        }
        
    // Public Getter / Setters:
        /** Enable/disable this component. Focus, keyboard, and mouse events will be suppressed if disabled. */
        [Inspectable(defaultValue="true")]
        override public function get enabled():Boolean { return super.enabled; }
        override public function set enabled(value:Boolean):void {
            super.enabled = value;
            updateScrollBar();
        }
        
        /** The current scroll position of the TextArea. */
        public function get position():int { return _position; }
        public function set position(value:int):void {
            _position = value;
            textField.scrollV = _position;
        }
        
        /** A reference to the ScrollBar associated with this TextArea. */
        [Inspectable(type="String")]
        public function get scrollBar():Object { return _scrollBar; }
        public function set scrollBar(value:Object):void {
            _scrollBarValue = value;
            invalidate(InvalidationType.SCROLL_BAR);
        }
        
        /** A minimum size for the ScrollIndicator's thumb in pixels. Passed through to the auto-generated ScrollIndicator. This property no effect if the component does not automatically generate a ScrollIndicator instance. */
        [Inspectable(defaultValue="1")]
        public function get minThumbSize():uint { return _minThumbSize; }
        public function set minThumbSize(value:uint):void {
            _minThumbSize = value;
            if (!_autoScrollBar) { return; }
            var sb:ScrollIndicator = _scrollBar as ScrollIndicator;
            sb.minThumbSize = value;
        }
        
        /** ScrollIndicator thumb offsets for top and bottom. Passed through to to auto-generated ScrollIndicator. This property no effect if the component does not automatically generate a ScrollIndicator instance. */
        [Inspectable(name="thumbOffset", defaultValue="top:0,bottom:0")]
        public function get thumbOffset():Object { return _thumbOffset; }
        public function set thumbOffset(value:Object):void {
            _thumbOffset = value;
            if (!_autoScrollBar) { return; }
            var sb:ScrollIndicator = _scrollBar as ScrollIndicator;
            sb.offsetTop = _thumbOffset.top;
            sb.offsetBottom = _thumbOffset.bottom;
        }
        
        /** The available width of the component, taking into account any auto-generated ScrollIndicators. */
        public function get availableWidth():Number {
            return Math.round(_width) - ((_autoScrollBar && (_scrollBar as MovieClip).visible) ? Math.round(_scrollBar.width) : 0);
        }
        
        /** The available height of the component. */
        public function get availableHeight():Number {
            return Math.round(_height);
        }
        
    // Public Methods:
        /** @exclude */
        override public function toString():String {
            return "[CLIK TextArea " + name + "]";
        }
        
        /** @exclude */
        override public function handleInput(event:InputEvent):void {
            super.handleInput(event);
            if (event.handled) { return; }
            else if (_editable) { return; }
            else {
                var navEquivalent:String = event.details.navEquivalent;
                switch(navEquivalent) {
                    case NavigationCode.UP:
                        if (position == 1) { return; }
                        position = Math.max(1, position - 1);
                        event.handled = true;
                        break;
                        
                    case NavigationCode.DOWN:
                        if (position == _maxScroll) { return; }
                        position = Math.min(_maxScroll, position + 1);
                        event.handled = true;
                        break;
                        
                    case NavigationCode.END:
                        position = _maxScroll;
                        event.handled = true;
                        break;
                    
                    case NavigationCode.HOME:
                        position = 1;
                        event.handled = true;
                        break;
                    
                    case NavigationCode.PAGE_UP:
                        var pageSize_up:Number = textField.bottomScrollV - textField.scrollV;
                        position = Math.max(1, position - pageSize_up);
                        event.handled = true;
                        break;
                        
                    case NavigationCode.PAGE_DOWN:
                        var pageSize_down:Number = textField.bottomScrollV - textField.scrollV;
                        position = Math.min(_maxScroll, position + pageSize_down);
                        event.handled = true;
                        break;
                }
            }
        }
            
    // Private Methods:
        /** 
         * Called to perform component configuration. configUI() is delayed one frame to allow sub-components to fully initialize, 
         * as some children may not have been initialized when this component’s constructor is called. Generally, any one-time 
         * configurations for this component or its children should occur here.
         */
        override protected function configUI():void {
            super.configUI();
            if (textField != null) {
                textField.addEventListener(Event.SCROLL, onScroller, false, 0, true);
            }
        }
        
        /**
         * Draw the component after it has been invalidated.  Use this method to reflow component 
         * size and position, redraw data, etc. When appropriate, ensure that a call to 
         * {@code super.draw()} is made when extending a component and overriding this method.
         */
        override protected function draw():void {
            // If the ScrollBar is invalid, recreate it.
            if (isInvalid(InvalidationType.SCROLL_BAR)) {
                createScrollBar();
            }
            
            // If the State is invalid, change the state and update the textField.
            if (isInvalid(InvalidationType.STATE)) {
                if (_newFrame) {
                    gotoAndPlay(_newFrame);
                    _newFrame = null;
                }
                updateAfterStateChange();
                updateTextField();
                dispatchEventAndSound(new ComponentEvent(ComponentEvent.STATE_CHANGE));
                invalidate(InvalidationType.SIZE);
            }
            // If the State isn't invalid but the Data (text) has changed, just updated the textField.
            else if (isInvalid(InvalidationType.DATA)) {
                updateText();
            }
            
            // If the Size of the component has changed...
            if (isInvalid(InvalidationType.SIZE)) {
                removeChild(container); // Remove the container so it is not scaled by setActualSize.
                setActualSize(_width, _height); // Update the size of the component.
                
                // Counterscale the container based on the component's new size.
                container.scaleX = 1 / scaleX; 
                container.scaleY = 1 / scaleY;
                
                // Update the constraints on the TextField.
                if (!constraintsDisabled) {
                    constraints.update(availableWidth, _height);
                    
                    // This is a hack for Flash Player. maxScrollV won't be updated until the next frame
                    // and even when it is, it won't call setScrollProperties() until the text has changed.
                    // To fix this, we request the textWidth, which forces an update of maxScrollV. In Scaleform, 
                    // we update maxScrollV immediately when the TextField's size is changed.
                    if (!Extensions.enabled) { // If this is Flash Player.
                        var forceMaxScrollUpdate:uint = textField.textWidth;
                        // Might need to textField.appendText() here to force a setScrollProperties update
                        // in some cases, but this seems to work for now.
                    }
                }
                
                addChild(container); // Replace the container.
                if (_autoScrollBar) { drawScrollBar(); } // Update any auto-generated ScrollIndicator to reflect the new size.
            }
        }
        
        /** Create the ScrollIndicator using _scrollBarValue, which may be a Class or a Instance Name. */
        protected function createScrollBar():void {
            // Destroy the old scroll bar.
            if (_scrollBar != null) {
                // Remove any outstanding eventListeners.
                _scrollBar.removeEventListener(Event.SCROLL, handleScroll, false);
                _scrollBar.removeEventListener(Event.CHANGE, handleScroll, false);
                _scrollBar.focusTarget = null;
                
                // Remove the ScrollBar from the Display List
                if (container.contains(_scrollBar as DisplayObject)) { 
                    container.removeChild(_scrollBar as DisplayObject); 
                }
                
                _scrollBar = null; // Clean up any references.
            }

            if (!_scrollBarValue || _scrollBarValue == "") { return; } // If _scrollBarValue is bad, no ScrollBar will be used.
            _autoScrollBar = false; // Reset the _autoScrollBar property. 
            
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
                        if (sbInst && _thumbOffset) {
                            sbInst.offsetTop = _thumbOffset.top;
                            sbInst.offsetBottom = _thumbOffset.bottom;
                        }
                        sb.addEventListener(MouseEvent.MOUSE_WHEEL, blockMouseWheel, false, 0, true); // Prevent duplicate scroll events
                        (sb as Object).minThumbSize = _minThumbSize;
                        //if (sb.scale9Grid == null) { sb.scale9Grid = new Rectangle(0,0,1,1); } // Prevent scaling
                        container.addChild(sb as DisplayObject);
                    }
                }
            } else if (_scrollBarValue is Class) {
                sb = new (_scrollBarValue as Class)() as IScrollBar;
                sb.addEventListener(MouseEvent.MOUSE_WHEEL, blockMouseWheel, false, 0, true);
                if (sb != null) {
                    _autoScrollBar = true;
                    (sb as Object).offsetTop = _thumbOffset.top;
                    (sb as Object).offsetBottom = _thumbOffset.bottom;
                    (sb as Object).minThumbSize = _minThumbSize;
                    container.addChild(sb as DisplayObject);
                }
            } else {
                sb = _scrollBarValue as IScrollBar;
            }
            
            _scrollBar = sb;
            invalidateSize(); // Redraw to reset scrollbar bounds, even if there is no scrollBar.
            if (_scrollBar != null) { // Configure the ScrollBar
                _scrollBar.addEventListener(Event.SCROLL, handleScroll, false, 0, true);
                _scrollBar.addEventListener(Event.CHANGE, handleScroll, false, 0, true);
                _scrollBar.focusTarget = this;
                (_scrollBar as Object).scrollTarget = textField;
                _scrollBar.tabEnabled = false;
            }
        }
        
        /** Updates the position and size auto-generated ScrollIndicator based on the size of the TextArea component. */
        protected function drawScrollBar():void {
            if (!_autoScrollBar) { return; }
            _scrollBar.x = _width - _scrollBar.width;
            _scrollBar.height = availableHeight;
            _scrollBar.validateNow(); // Should happen soon?
        }
        
        /** Updates the scroll position and thumb size of the ScrollBar. */
        protected function updateScrollBar():void {
            _maxScroll = textField.maxScrollV;
            var sb:ScrollIndicator = _scrollBar as ScrollIndicator;
            if (sb == null) { return; }
            
            var element:ConstrainedElement = constraints.getElement("textField");
            if (_scrollPolicy == "on" || (_scrollPolicy == "auto" && textField.maxScrollV > 1)) {
                if (_autoScrollBar && !sb.visible) { // Add some space on the right for the scrollBar
                    if (element != null) {
                        constraints.update(_width, _height);
                        invalidate();
                    }
                    _maxScroll = textField.maxScrollV; // Set this again, in case adding a scrollBar made the maxScroll larger.
                }
                sb.visible = true;
            }
            
            // If no ScrollIndicator is needed, hide it.
            if (_scrollPolicy == "off" || (_scrollPolicy == "auto" && textField.maxScrollV == 1)) {
                if (_autoScrollBar && sb.visible) { // Remove any added space.
                    sb.visible = false; // Hide the ScrollBar before calling availableWidth to remove it from the calculation.
                    if (element != null) {
                        constraints.update(availableWidth, _height);
                        invalidate();
                    }
                }
            }
            
            if (sb.enabled != enabled) { sb.enabled = enabled; }
        }
        
        override protected function updateText():void {
            super.updateText();
            updateScrollBar();
        }
        
        override protected function updateTextField():void {
            _resetScrollPosition = true;
            super.updateTextField();
        }
        
        protected function handleScroll(event:Event):void {
            position = _scrollBar.position;
        }
        
        protected function blockMouseWheel(event:MouseEvent):void {
            event.stopPropagation();
        }
        
        override protected function handleTextChange(event:Event):void {
            if (_maxScroll != textField.maxScrollV) {
                 updateScrollBar();
            }
            super.handleTextChange(event);
        }
        
        protected function onScroller(event:Event):void {
            if (_resetScrollPosition) { textField.scrollV = _position; }
            else { _position = textField.scrollV; }
            _resetScrollPosition = false;        
        }
    }
}