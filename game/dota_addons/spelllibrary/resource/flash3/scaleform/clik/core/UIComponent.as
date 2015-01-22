/**
 *  The UIComponent is the basis for all components in the Scaleform framework. It contains functionality found in all components such as initialization, focus management, invalidation, sizing, and events.
 */

/**************************************************************************

Filename    :   UIComponent.as

Copyright   :   Copyright 2012 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

package scaleform.clik.core
{
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.FocusEvent;
    import flash.events.MouseEvent;
    import flash.external.ExternalInterface;
    import flash.system.Capabilities;

    import scaleform.gfx.FocusManager;
    import scaleform.gfx.Extensions;

    import scaleform.clik.core.CLIK;
    import scaleform.clik.constants.InvalidationType;
    import scaleform.clik.events.ComponentEvent;
    import scaleform.clik.events.InputEvent;
    import scaleform.clik.layout.Layout;
    import scaleform.clik.layout.LayoutData;
    import scaleform.clik.managers.FocusHandler;
    import scaleform.clik.utils.Constraints;

    [Event(name="SHOW", type="scaleform.clik.events.ComponentEvent")]
    [Event(name="HIDE", type="scaleform.clik.events.ComponentEvent")]

    public class UIComponent extends MovieClip
    {
    // Constants:
        public static var sdkVersion:String = "4.2.23";

    // Public Properties:
        public var initialized:Boolean = false;

    // Private Properties:
        /** @private */
        protected var _invalidHash:Object;
        /** @private */
        protected var _invalid:Boolean = false;
        /** @private */
        protected var _width:Number = 0; // internal width
        /** @private */
        protected var _height:Number = 0; // internal height
        /** @private */
        protected var _originalWidth:Number = 0;
        /** @private */
        protected var _originalHeight:Number = 0;
        /** @private */
        protected var _focusTarget:UIComponent;
        /** @private */
        protected var _focusable:Boolean = true;
        /** @private */
        protected var _focused:Number = 0;
        /** @private */
        protected var _displayFocus:Boolean = false;
        /** @private */
        protected var _mouseWheelEnabled:Boolean = true;
        /** @private */
        protected var _inspector:Boolean = false;
        /** @private */
        protected var _labelHash:Object;
        /** @private */
        protected var _layoutData:LayoutData;
        /** @private */
        protected var _enableInitCallback:Boolean = false;

    // UI Elements:
        public var constraints:Constraints;

    // Initialization:
        public function UIComponent() {
            preInitialize();
            super();

            _invalidHash = {};
            initialize();
            addEventListener(Event.ADDED_TO_STAGE, addedToStage, false, 0, true);
        }

        protected function preInitialize():void {} // Abstract.

        protected function initialize():void {
            _labelHash = UIComponent.generateLabelHash(this);

            // Original width determines the width at 100% with original contents.
            _originalWidth = super.width / super.scaleX;
            _originalHeight = super.height / super.scaleY;

            if (_width == 0) { _width = super.width; }
            if (_height == 0) { _height = super.height; }

            invalidate();
        }

        public static function generateLabelHash(target:MovieClip):Object {
            var hash:Object = {};
            if (!target) { return hash; }
            var labels:Array = target.currentLabels;
            var l:uint = labels.length;
            for (var i:uint=0; i<l; i++) { hash[labels[i].name] = true; }
            return hash;
        }

        protected function addedToStage(event:Event):void {
            removeEventListener(Event.ADDED_TO_STAGE, addedToStage, false);
            if ( !CLIK.initialized ) {
                CLIK.initialize(stage, this);
            }

            if (_enableInitCallback && Extensions.CLIK_addedToStageCallback != null) {
                CLIK.queueInitCallback(this);
            }
        }

    // Public Getter / Setters:
        public function get componentInspectorSetting():Boolean { return _inspector; }
        public function set componentInspectorSetting(value:Boolean):void {
            _inspector = value;
            if (value) {
                beforeInspectorParams();
            } else {
                afterInspectorParams();
            }
        }

        override public function get width():Number { return _width; }
        override public function set width(value:Number):void {
            setSize(value, _height);
        }

        override public function get height():Number { return _height; }
        override public function set height(value:Number):void { setSize(_width, value); }

        override public function get scaleX():Number { return _width/_originalWidth; }
        override public function set scaleX(value:Number):void {
            super.scaleX = value;
            if (rotation == 0) { width = super.width; }
        }

        override public function get scaleY():Number { return _height/_originalHeight; }
        override public function set scaleY(value:Number):void {
            super.scaleY = value;
            if (rotation == 0) { height = super.height; }
        }

        /**
         * Enables or disables the component. Disabled components should not receive mouse, keyboard, or any
         * other kind of focus or interaction.
         */
        [Inspectable(defaultValue="true")]
        override public function get enabled():Boolean { return super.enabled; }
        override public function set enabled(value:Boolean):void {
            if (value == super.enabled) { return; }

            super.enabled = value;
            tabEnabled = (!enabled) ? false : _focusable;
            mouseEnabled = value;
        }

        /**
         * Show or hide the component. Allows the {@code _visible} property to be overridden, and
         * dispatch a "show" or "hide" event.
         */
        [Inspectable(defaultValue="true")]
        override public function get visible():Boolean { return super.visible; }
        override public function set visible(value:Boolean):void {

            super.visible = value;
            dispatchEventAndSound(new ComponentEvent(value ? ComponentEvent.SHOW : ComponentEvent.HIDE));
        }

        public function get hasFocus():Boolean { return _focused > 0; }

        /**
         * Enable/disable focus management for the component. Setting the focusable property to
         * {@code focusable=false} will remove support for tab key, direction key and mouse
         * button based focus changes.
         */
        public function get focusable():Boolean { return _focusable; }
        public function set focusable(value:Boolean):void {
			var changed:Boolean = (_focusable != value);
            _focusable = value;

            // If the component is no longer focusable but currently enabled, disable tabbing.
            // If the component is no longer focusable but it is already disabled, do nothing.
            if (!_focusable && enabled) { tabEnabled = tabChildren = false; }
            else if (_focusable && enabled) { tabEnabled = true; }

			// PPS: We may not need to call changeFocus(), and it may in fact cause visual artifacts..
			if (changed) changeFocus();
        }

        /**
         * Get and set the focus of the component.  This property is explicitly called by the FocusHandler
         * when the stage or application focus is given to this component, but can also be set manually on
         * the component to set or clear focus.  Currently, an application can have only a single focus.
         * When the focus on a component changes, a "focusIn" or "focusOut" event is fired.
         */
        public function get focused():Number { return _focused; } // int?
        public function set focused(value:Number):void {
            if (value == _focused || !_focusable) { return; }
            _focused = value;

            // Only run through multiple controller support if we're in Scaleform.
            if (Extensions.isScaleform) {
                var numFocusGroups:uint = FocusManager.numFocusGroups;
                var numControllers:uint = Extensions.numControllers;
                for (var i:Number = 0; i < numFocusGroups; i++) {
                    // Is the component focused by this focusGroup?
                    var isFocused:Boolean = ((_focused >> i) & 0x1) != 0;
                    if (isFocused) {
                        var controllerMask1:Number = FocusManager.getControllerMaskByFocusGroup( i );
                        for (var j:Number = 0; j < numControllers; j++) {
                            // Is the component focused by this controller?
                            var controllerValue1:Boolean = ((controllerMask1 >> j) & 0x1) != 0;
                            if (controllerValue1 && FocusManager.getFocus(j) != this) {
                                FocusManager.setFocus(this, j);
                            }
                        }
                    }
                }
            }
            else {
                if (stage != null && _focused > 0) {
                    stage.focus = this;
                }
            }

            changeFocus();
        }

        /**
         * Set the component to display itself as focused, even if it is not.  This property is used by container
         * components to make them appear focused.
         */
        public function get displayFocus():Boolean { return _displayFocus; }
        public function set displayFocus(value:Boolean):void {
            if (value == _displayFocus) { return; }
            _displayFocus = value;
            changeFocus();
        }

        public function get focusTarget():UIComponent { return _focusTarget; }
        public function set focusTarget(value:UIComponent):void {
            _focusTarget = value;
        }

        public function get layoutData():LayoutData { return _layoutData; }
        public function set layoutData(value:LayoutData):void {
            _layoutData = value;
        }

        [Inspectable(defaultValue="false")]
        public function get enableInitCallback():Boolean { return _enableInitCallback; }
        public function set enableInitCallback(value:Boolean):void {
            if (value == _enableInitCallback) { return; }
            _enableInitCallback = value;

            // If we're already on the stage, fire the enableInitCallback immediately.
            // This can occur if the component is on the timeline of the original .Swf, since inspectables are set
            // after the component is added to the stage. Note that this behaviour is reversed for components
            // added to the stage via code or loaded via a Loader (inspectables will be set before being added to
            // the stage), thus the stage != null check.
            if (_enableInitCallback && stage != null && Extensions.CLIK_addedToStageCallback != null) {
                // Edge case for engines where CLIK may not be initialized when inspectables are fired.
                if (!CLIK.initialized) { CLIK.initialize(stage, this); }
                CLIK.queueInitCallback( this );
            }
        }

        final public function get actualWidth():Number { return super.width; }
        final public function get actualHeight():Number { return super.height; }
        final public function get actualScaleX():Number { return super.scaleX; }
        final public function get actualScaleY():Number { return super.scaleY; }

    // Public Methods:
        /**
         * Sets the width and height of the component at the same time using internal sizing mechanisms.
         * @param width The new width of the component.
         * @param height The new height of the component.
         */
        public function setSize(width:Number, height:Number):void {
            _width = width;
            _height = height;
            invalidateSize();
        }

        // Ablility to set actual metric size, since we override it.
        public function setActualSize(newWidth:Number, newHeight:Number):void {
            // If the clip is rotated, setting super.width and super.height can reset/unexpectedly affect one another. Seems to be
            // a bug in Flash Player.
            if (super.width != newWidth || _width != newWidth) {
                super.width = _width = newWidth;
            }

            if (super.height != newHeight || _height != newHeight) {
                super.height = _height = newHeight;
            }
        }

        final public function setActualScale(scaleX:Number, scaleY:Number):void {
            super.scaleX = scaleX;
            super.scaleY = scaleY;
            _width = _originalWidth * scaleX;
            _height = _originalHeight * scaleY;
            invalidateSize();
        }

        /**
         * Handle input from the game, via controllers or keyboard. The default handleInput will handle standalone
         * and composite components.
         * @param event An InputEvent containing details about the interaction.
         * @see InputEvent
         * @see FocusHandler
         * @see InputDetails

         */
        public function handleInput(event:InputEvent):void {}

        //LM: Untested.
        public function dispatchEventToGame(event:Event):void {
            ExternalInterface.call("__handleEvent", name, event);
        }

        /** @exclude */
        override public function toString():String {
            return "[CLIK UIComponent " + name + "]";
        }

    // Private Methods:
        /**
         * Configure the interface when the component is initialized. Use this method to set up
         * sub-components, listeners, etc.
         */
        protected function configUI():void { } // Abstract

        /**
         * Draw the component after it has been invalidated.  Use this method to reflow component
         * size and position, redraw data, etc. When appropriate, ensure that a call to
         * super.draw() is made when extending a component and overriding this method.
         */
        protected function draw():void { } // Abstract

        /**
         * Called after focus has been given or taken from the component.
         * Use this method to change the appearance or behavior of the component when the focus changes.
         */
        protected function changeFocus():void {} // Abstract
        protected function beforeInspectorParams():void {}
        protected function afterInspectorParams():void {}

        protected function initSize():void {
            var w:Number = (_width == 0) ? actualWidth : _width;
            var h:Number = (_height == 0) ? actualHeight : _height;
            super.scaleX = super.scaleY = 1;
            setSize(w,h);
        }

    // Invalidation
        /**
         * An internal property of the component has changed, requiring a redraw.  The invalidation
         * mechanism lets components trigger multiple redraw commands at the same time, resulting in
         * only a single redraw. the {@code invalidate()} method is public so that it can be called externally.
         */
        public function invalidate(...invalidTypes:Array):void {
            if (invalidTypes.length == 0) {
                _invalidHash[InvalidationType.ALL] = true;
            } else {
                var l:uint = invalidTypes.length;
                for (var i:uint=0; i<l; i++) {
                    _invalidHash[invalidTypes[i]] = true;
                }
            }

            if (!_invalid) {
                _invalid = true;
                if (stage == null) {
                    addEventListener(Event.ADDED_TO_STAGE, handleStageChange, false, 0, true);
                } else {
                    addEventListener(Event.ENTER_FRAME, handleEnterFrameValidation, false, 0, true);
                    addEventListener(Event.RENDER, validateNow, false, 0, true);
                    stage.invalidate();
                }
            } else {
                // NFM: If _invalid was set, ADDED_TO_STAGE or RENDER should have fired and cleared it,
                //      but in the unlikely event we end up here, just invalidate the stage.
                if (stage != null) { stage.invalidate(); }
            }
        }

        /**
         * When the component has been invalidated, this method is called which validates the component,
         * and redraws the component immediately by calling {@code draw()}. The {@code validateNow()}
         * method is public so that it can be called externally.
         */
        public function validateNow(event:Event = null):void {
            if (!initialized) {
                initialized = true;
                configUI();
            }

            removeEventListener(Event.ENTER_FRAME, handleEnterFrameValidation, false);
            removeEventListener(Event.RENDER, validateNow, false);
            if (!_invalid) { return; }
            draw();
            _invalidHash = { };
            _invalid = false;
        }

        protected function isInvalid(...invalidTypes:Array):Boolean {
            if (!_invalid) { return false; }
            var l:uint = invalidTypes.length;
            if (l == 0) { return _invalid; } // Check if anything is invalid
            if (_invalidHash[InvalidationType.ALL]) { return true; }
            for (var i:uint=0; i<l; i++) {
                if (_invalidHash[invalidTypes[i]]) { return true; }
            }
            return false;
        }

        // Easy invalidation shortcuts
        public function invalidateSize():void { invalidate(InvalidationType.SIZE); }
        public function invalidateData():void { invalidate(InvalidationType.DATA); }
        public function invalidateState():void { invalidate(InvalidationType.STATE); }

        // Edge cases for rendering
        protected function handleStageChange(event:Event):void {
            if (event.type == Event.ADDED_TO_STAGE) {
                removeEventListener(Event.ADDED_TO_STAGE, handleStageChange, false);
                addEventListener(Event.RENDER, validateNow, false, 0, true);

                // NFM: If stage == null here, the component probably overrides set stage / get stage.
                if (stage != null) {
                    stage.invalidate();
                }
            }
        }
        protected function handleEnterFrameValidation(event:Event):void {
            // When a nested component doesn't call validateNow, this will fire. Unfortunately, timeline components get this before RENDER
            validateNow();
        }

        protected function getInvalid():String {
            var inv:Array = [];
            var check:Array = [InvalidationType.ALL, InvalidationType.DATA, InvalidationType.RENDERERS, InvalidationType.SIZE, InvalidationType.STATE];
            for (var i:uint = 0; i < check.length; i++) {
                inv.push("* " + check[i] + ": " + (_invalidHash[check[i]] == true));
            }
            for (var n:String in _invalidHash) {
                if (check.indexOf(n)) { continue; }
                inv.push("* " + n + ": true");
            }
            return "Invalid " + this + ": \n" + inv.join("\n");
        }

        public function dispatchEventAndSound(event:Event):Boolean {

            if (Extensions.gfxProcessSound != null)
            {
                Extensions.gfxProcessSound(this, "default", event.type);
            }

            return super.dispatchEvent(event);

            /*
            var ok:Boolean = super.dispatchEventAndSound(event);
            // playSound(event.type);
            return ok;
            */
        }

    }

}
