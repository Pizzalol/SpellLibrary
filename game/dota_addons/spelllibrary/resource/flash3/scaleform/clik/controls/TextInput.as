/**
 *  TextInput is an editable text field component used to capture textual user input. Similar to the Label, this component is merely a wrapper for a standard textField, and therefore supports the same capabilities of the textField such as password mode, maximum number of characters and HTML text. Only a handful of these properties are exposed by the component itself, while the rest can be modified by directly accessing the TextInput’s textField instance.

    The TextInput component should be used for input, since noneditable text can be displayed using the Label. Similar to the Label, developers may substitute standard textFields for TextInput components based on their requirements. However, when developing sophisticated UIs, especially for PC applications, the TextInput component provides valuable extended capabilities over the standard textField.

    For starters, TextInput supports the focused and disabled state, which are not easily achieved with the standard textField. Due to the separated focus state, TextInput can support custom focus indicators, which are not included with the standard textField. Complex AS2 code is required to change the visual style of a standard textField, while the TextInput visual style can be configured easily on the timeline. The TextInput inspectable properties provide an easy workflow for designers and programmers who are not familiar with Flash Studio. Developers can also easily listen for events fired by the TextInput to create custom behaviors.

    The TextInput also supports the standard selection and cut, copy, and paste functionality provided by the textField, including multi paragraph HTML formatted text. By default, the keyboard commands are select (Shift+Arrows), cut (Shift+Delete), copy (Ctrl+Insert), and paste (Shift+Insert).

    <b>Inspectable Properties</b>
    The inspectable properties of the TextInput component are:
    <ul>
        <li><i>text</i>: Sets the text of the textField.</li>
        <li><i>enabled</i>: Disables the component if set to false.</li>
        <li><i>focusable</i>: By default buttons receive focus for user interactions. Setting this property to false will disable focus acquisition.</li>
        <li><i>editable</i>: Makes the TextInput non-editable if set to false.</li>
        <li><i>maxChars</i>: A number greater than zero limits the number of characters that can be entered in the textField.</li>
        <li><i>password</i>: If true, sets the textField to display '*' characters instead of the real characters. The value of the textField will be the real characters entered by the user – returned by the text property.</li>
        <li><i>defaultText</i>: Text to display when the textField is empty. This text is formatted by the defaultTextFormat object, which is by default set to light gray and italics.</li>
        <li><i>actAsButton</i>: If true, then the TextInput will behave similar to a Button when not focused and support rollOver and rollOut states. Once focused via mouse press or tab, the TextInput reverts to its normal mode until focus is lost.</li>
        <li><i>visible</i>: Hides the component if set to false.</li>
    </ul>

    <b>States</b>
    The CLIK TextInput component supports three states based on its focused and disabled properties. <ul>
    <li>default or enabled state.</li>
    <li>focused state, typically a represented by a highlighted border around the textField.</li>
    <li>disabled state.</li></ul>
 */

/**************************************************************************

Filename    :   TextInput.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

package scaleform.clik.controls {

    import flash.display.InteractiveObject;
    import flash.events.Event;
    import flash.events.FocusEvent;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.text.TextFieldType;

    import scaleform.gfx.FocusManager;
    import scaleform.gfx.MouseEventEx;
    import scaleform.gfx.Extensions;

    import scaleform.clik.constants.InvalidationType;
    import scaleform.clik.constants.InputValue;
    import scaleform.clik.core.UIComponent;
    import scaleform.clik.events.ComponentEvent;
    import scaleform.clik.events.InputEvent;
    import scaleform.clik.managers.FocusHandler;
    import scaleform.clik.ui.InputDetails;
    import scaleform.clik.utils.Constraints;
    import scaleform.clik.constants.ConstrainMode;

    [Event(name="stateChange", type="scaleform.clik.events.ComponentEvent")]

    public class TextInput extends UIComponent {

    // Constants:

    // Public Properties:
        /** The text format used to display the default text. By default it is set to color:0xAAAAAA and italic:true. */
        public var defaultTextFormat:TextFormat;
        /** True if constraints are disabled for the component. Setting the disableConstraintsproperty to {@code disableConstraints=true} will remove constraints from the textfield. This is useful for components with timeline based textfield size tweens, since constraints break them due to a Flash quirk. */
        public var constraintsDisabled:Boolean = false;

    // Protected Properties:
        protected var _text:String = "";
        protected var _displayAsPassword:Boolean = false;
        protected var _maxChars:uint = 0;
        protected var _editable:Boolean = true;
        protected var _actAsButton:Boolean = false;
        protected var _alwaysShowSelection:Boolean = false;
        protected var _isHtml:Boolean = false;
        protected var _state:String = "default";
        protected var _newFrame:String;
        protected var _textFormat:TextFormat;
        protected var _usingDefaultTextFormat:Boolean = true;
        protected var _defaultText:String = "";

    // Private Properties:
        private var hscroll:Number = 0; //LM: Not implemented.

    // UI Elements:
        public var textField:TextField;

    // Initialization:
        public function TextInput() {
            super();
        }

        override protected function preInitialize():void {
            if (!constraintsDisabled) {
                constraints = new Constraints(this, ConstrainMode.COUNTER_SCALE);
            }
        }

        override protected function initialize():void {
            super.tabEnabled = false; // Components with a TextField can not be tabEnabled, otherwise they will get tab focus separate from the TextField.
            mouseEnabled = mouseChildren = enabled;
            super.initialize();

            _textFormat = textField.getTextFormat();

            // Create a custom text format for the empty state (defaultTextFormat), which can be overridden by the user.
            defaultTextFormat = new TextFormat();
            defaultTextFormat.italic = true;
            defaultTextFormat.color = 0xAAAAAA;
        }

    // Public Getter / Setters:
        /**
         * Enables or disables the component. Disabled components should not receive mouse, keyboard, or any
         * other kind of focus or interaction.
         */
        [Inspectable(defaultValue="true")]
        override public function get enabled():Boolean { return super.enabled; }
        override public function set enabled(value:Boolean):void {
            super.enabled = value;
            mouseChildren = value;

            super.tabEnabled = false;
            tabChildren = _focusable;
            setState(defaultState);
        }

        /**
         * Enable/disable focus management for the component. Setting the focusable property to
         * {@code focusable=false} will remove support for tab key, direction key and mouse
         * button based focus changes.
         */
        [Inspectable(defaultValue="true")]
        override public function get focusable():Boolean { return _focusable; }
        override public function set focusable(value:Boolean):void {
            _focusable = value;

            // If the component is no longer focusable but currently enabled, disable tabbing.
            // If the component is no longer focusable but it is already disabled, do nothing.
            if (!_focusable && enabled) { tabChildren = false; }
            changeFocus();

            if (_focusable && editable) {
                addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false, 0, true);
            } else {
                removeEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false);
            }
        }

        /**
         * The text to be displayed by the Label component. This property assumes that localization has been
         * handled externally.
         * @see #htmlText For formatted text, use the {@code htmlText} property.
         */
        [Inspectable(type="String", defaultValue="")]
        public function get text():String { return _text; }
        public function set text(value:String):void {
            _isHtml = false;
            _text = value;
            invalidateData();
        }

        /**
         * The html text to be displayed by the label component.  This property assumes that localization has
         * been handled externally.
         * @see #text For plain text use {@code text} property.
         */
        public function get htmlText():String { return _text; }
        public function set htmlText(value:String):void {
            _isHtml = true;
            _text = value;
            invalidateData();
        }

        /** The default text to be shown when no text has been assigned or entered into this component. */
        [Inspectable(verbose=1, type="String", defaultValue="")]
        public function get defaultText():String { return _defaultText; }
        public function set defaultText(value:String):void {
            _defaultText = value;
            invalidateData();
        }

        /**
         * The "displayAsPassword" mode of the text field. When {@code true}, the component will show asterisks
         * instead of the typed letters.
         */
        [Inspectable(defaultValue="false")]
        public function get displayAsPassword():Boolean { return _displayAsPassword; }
        public function set displayAsPassword(value:Boolean):void {
            _displayAsPassword = value;
            if (textField != null) { textField.displayAsPassword = value; }
        }

        /**
         * The maximum number of characters that the field can contain.
         */
        [Inspectable(defaultValue="0")]
        public function get maxChars():uint { return _maxChars; }
        public function set maxChars(value:uint):void {
            _maxChars = value;
            if (textField != null) { textField.maxChars = value; }
        }

        /**
         * Determines if text can be entered into the TextArea, or if it is display-only. Text in a non-editable
         * TextInput components can not be selected.
         */
        [Inspectable(defaultValue="true")]
        public function get editable():Boolean { return _editable; }
        public function set editable(value:Boolean):void {
            _editable = value;
            if (textField != null) {
                textField.type = (_editable && enabled) ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
            }
            focusable = value;
        }

        /**
         * Override for .tabEnabled property to prevent users from changing the tabEnabled of the TextInput itself
         * and instead passes the change on to the textField. TextInput.tabEnabled must always be false for focus reasons.
         */
        override public function get tabEnabled():Boolean { return textField.tabEnabled; }
        override public function set tabEnabled(value:Boolean):void {
            textField.tabEnabled = value;
        }

        /**
         * Override for .tabIndex property to prevent users from changing the tabIndex of the TextInput itself
         * and instead passes the change on to the textField. TextInput.tabIndex must always be -1 for focus reasons.
         */
        override public function get tabIndex():int { return textField.tabIndex; }
        override public function set tabIndex(value:int):void {
            textField.tabIndex = value;
        }

        /**
         * If true, then the TextInput will behave similar to a Button when not focused and support rollOver and rollOut
         * states. Once focused via mouse press or tab, the TextInput reverts to its normal mode until focus is lost.
         */
        [Inspectable(defaultValue="false")]
        public function get actAsButton():Boolean { return _actAsButton; }
        public function set actAsButton(value:Boolean):void {
            if (_actAsButton == value) { return; }
            _actAsButton = value;
            if (value) {
                addEventListener(MouseEvent.ROLL_OVER, handleRollOver, false, 0, true);
                addEventListener(MouseEvent.ROLL_OUT, handleRollOut, false, 0, true);
            } else {
                removeEventListener(MouseEvent.ROLL_OVER, handleRollOver, false);
                removeEventListener(MouseEvent.ROLL_OUT, handleRollOut, false);
            }
        }

        /**
         * When set to true and the text field is not in focus, the textField highlights the selection in the text
         * field in gray
         */
        public function get alwaysShowSelection():Boolean { return _alwaysShowSelection; }
        public function set alwaysShowSelection(value:Boolean):void {
            _alwaysShowSelection = value;
            if (textField != null) { textField.alwaysShowSelection = value; }
        }

        /**
         * The length of the text in the textField.
         */
        public function get length():uint { return textField.length; }

        public function get defaultState():String {
            return (!enabled ? "disabled" : (focused ? "focused" : "default"));
        }

    // Public Methods:
        /**
         * Append a new string to the existing text. The textField will be set to non-html rendering when this
         * method is invoked.
         */
        public function appendText(value:String):void {
            _text += value;
            _isHtml = false;
            invalidateData();
        }

        /**
         * Append a new html string to the existing text. The textField will be set to html rendering when this
         * method is invoked.
         */
        public function appendHtml(value:String):void {
            _text += value;
            _isHtml = true;
            invalidateData();
        }

        /** @exclude */
        override public function handleInput(event:InputEvent):void {
            if (event.handled) { return; } // Already handled.

            var details:InputDetails = event.details;
            if (details.value == InputValue.KEY_DOWN || details.value == InputValue.KEY_HOLD) { return; } // unhandled
            return; //LM: Below needs testing.

            // LM: I think this is to ensure that the textField has focus to handle key events when only the component is focused. Might be unnecessary.
            // if (stage.focus != null) { return; }
            // event.handled = true;
            // stage.focus = textField; //LM: No controller index
        }

        /** @exclude */
        override public function toString():String {
            return "[CLIK TextInput " + name + "]";
        }

    // Protected Methods:
        override protected function configUI():void {
            super.configUI();

            if (!constraintsDisabled) {
                constraints.addElement("textField", textField, Constraints.ALL);
            }

            addEventListener(InputEvent.INPUT, handleInput, false, 0, true);
            textField.addEventListener(FocusEvent.FOCUS_IN, handleTextFieldFocusIn, false, 0, true);

            if (focusable && editable) {
                addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, false, 0, true);
            }

            setState(defaultState, "default");
        }

        override protected function draw():void {
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
            else if (isInvalid(InvalidationType.DATA)) {
                updateText();
            }

            if (isInvalid(InvalidationType.SIZE)) {
                setActualSize(_width, _height);
                if (!constraintsDisabled) {
                    constraints.update(_width, _height);
                }
            }
        }

        override protected function changeFocus():void {
            setState(defaultState);
        }

        protected function updateTextField():void {
            if (textField == null) { trace(">>> Error :: " + this + ", textField is NULL."); return; }

            updateText();
            textField.maxChars = _maxChars;
            textField.alwaysShowSelection = _alwaysShowSelection;
            textField.selectable = enabled ? _editable : enabled;
            textField.type = (_editable && enabled) ? TextFieldType.INPUT : TextFieldType.DYNAMIC;
            textField.tabEnabled = _editable && enabled && _focusable;
            // Note: In CLIK AS3, the focusTarget is not injected into the TextField. Instead, it uses a special case in FocusHandler to parent focus.
            //textField.hscroll = hscroll; //LM: Is this still necessary? Evaluate.

            textField.addEventListener( Event.CHANGE, handleTextChange, false, 0, true );

            // Extra logic for focus management within TextInput.
            if (textField.hasEventListener(FocusEvent.FOCUS_IN)) {
                textField.removeEventListener(FocusEvent.FOCUS_IN, handleTextFieldFocusIn, false);
            }
            textField.addEventListener(FocusEvent.FOCUS_IN, handleTextFieldFocusIn, false, 0, true);
        }

        protected function handleTextFieldFocusIn(e:FocusEvent):void {
            FocusHandler.getInstance().setFocus( this );
        }

        protected function updateText():void {
            if (_focused && _usingDefaultTextFormat) {
                textField.defaultTextFormat = _textFormat;
                _usingDefaultTextFormat = false;
                if ( _displayAsPassword && !textField.displayAsPassword ) {
                    textField.displayAsPassword = true;
                }
            }
            if (_text != "") {
                if (_isHtml) {
                    textField.htmlText = _text;

                } else {
                    textField.text = _text;
                }
            } else {
                textField.text = "";
                if (!_focused && _defaultText != "") {
                    if ( _displayAsPassword ) {
                        textField.displayAsPassword = false;
                    }
                    textField.text = _defaultText;
                    _usingDefaultTextFormat = true;
                    if (defaultTextFormat != null) {
                        textField.setTextFormat(defaultTextFormat);
                    }
                }
            }
        }

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

        protected function updateAfterStateChange():void {
            if (!initialized) { return; }
            constraints.updateElement("textField", textField);
            if (_focused) {
                if (Extensions.isScaleform) {
                    var numControllers:uint = Extensions.numControllers;
                    for (var i:uint = 0; i < numControllers; i++) {
                        if (FocusManager.getFocus(i) == this) {
                            FocusManager.setFocus(textField, i);
                        }
                    }
                }
                else {
                    stage.focus = textField;
                }
            }
        }

        protected function handleRollOver(event:MouseEvent):void {
            if (focused || !enabled) { return; }
            setState("over");
        }

        protected function handleRollOut(event:MouseEvent):void {
            if (focused || !enabled) { return; }
            setState("out", "default");
        }

        protected function handleMouseDown(event:MouseEvent):void {
            if (focused || !enabled) { return; }
            if (event is MouseEventEx) {
                FocusManager.setFocus(textField, (event as MouseEventEx).mouseIdx );
            } else {
                stage.focus = textField;
            }
        }

        protected function handleTextChange(event:Event):void {
            _text = _isHtml ? textField.htmlText : textField.text;
            dispatchEventAndSound(new Event(Event.CHANGE));
        }
    }
}
