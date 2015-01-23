/**************************************************************************

Filename    :   InputDelegate.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

﻿package scaleform.clik.managers {
    
    import flash.display.Stage;
    import flash.events.EventDispatcher;
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;
    import scaleform.clik.core.CLIK;
    
    import scaleform.clik.events.InputEvent;
    import scaleform.clik.ui.InputDetails;
    import scaleform.clik.constants.InputValue;
    import scaleform.clik.constants.NavigationCode;
    
    import scaleform.gfx.KeyboardEventEx;
    
    [Event(name="input", type="scaleform.clik.events.InputEvent")]
    
    public class InputDelegate extends EventDispatcher {
        
    // Singleton access
        private static var instance:InputDelegate;
        public static function getInstance():InputDelegate {
            if (instance == null) { instance = new InputDelegate(); }
            return instance;
        }
        
    // Constants:
        public static const MAX_KEY_CODES:uint = 1000;
        public static const KEY_PRESSED:uint = 1;
        public static const KEY_SUPRESSED:uint = 2;
        
    // Public Properties:
        public var stage:Stage;
        public var externalInputHandler:Function;
        
    // Protected Properties:
        protected var keyHash:Array; // KeyHash stores all key code states and supression rules. We use a flat array, which uses a max-keys multiplier to look up controller-specific key rules and states. Each key state is a bit containing the appropriate flags.
        
    // Initialization:
        public function InputDelegate() {
            keyHash = [];
        }
        
        public function initialize(stage:Stage):void {
            this.stage = stage;
            stage.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown, false, 0, true);
            stage.addEventListener(KeyboardEvent.KEY_UP, handleKeyUp, false, 0, true);
        }
        
    // Public getter / setters:
        
    // Public Methods:
        public function setKeyRepeat(code:Number, repeat:Boolean, controllerIndex:uint=0):void {
            var index:uint = controllerIndex * MAX_KEY_CODES + code;
            // Note that bitwise operation against null is the same as against 0, so we don't have to initialize the property.
            if (repeat) {
                keyHash[index] &= ~KEY_SUPRESSED;
            } else {
                keyHash[index] |= KEY_SUPRESSED;
            }
        }
        
        public function inputToNav(type:String, code:Number, shiftKey:Boolean = false, value:*=null):String {
            // Keys, likely the PC Keyboard.
            
            if (externalInputHandler != null) {
                return externalInputHandler(type, code, value);
            }
            
            if (type == "key") {
                switch (code) {
                    case Keyboard.UP:
                        return NavigationCode.UP;
                    case Keyboard.DOWN:
                        return NavigationCode.DOWN;
                    case Keyboard.LEFT: 
                        return NavigationCode.LEFT;
                    case Keyboard.RIGHT:
                        return NavigationCode.RIGHT;        
                    case Keyboard.ENTER:
                    case Keyboard.SPACE:
                        return NavigationCode.ENTER;
                    case Keyboard.BACKSPACE:
                        return NavigationCode.BACK;
                    case Keyboard.TAB:
                        if (shiftKey) { return NavigationCode.SHIFT_TAB; }
                        else { return NavigationCode.TAB; }
                    case Keyboard.HOME:
                        return NavigationCode.HOME;
                    case Keyboard.END:
                        return NavigationCode.END;
                    case Keyboard.PAGE_DOWN:
                        return NavigationCode.PAGE_DOWN;
                    case Keyboard.PAGE_UP:
                        return NavigationCode.PAGE_UP;
                    case Keyboard.ESCAPE:
                        return NavigationCode.ESCAPE;
                }  
                
                if (CLIK.testGamePad)
                {
                    switch (code) {
                        // Custom handlers for gamepad support
                        case 96:    // NumPad_0
                            return NavigationCode.GAMEPAD_A;
                        case 97:    // NumPad_1
                            return NavigationCode.GAMEPAD_B;
                        case 98:    // NumPad_2
                            return NavigationCode.GAMEPAD_X;
                        case 99:    // NumPad_3
                            return NavigationCode.GAMEPAD_Y;
                        case 100:    // NumPad_4
                            return NavigationCode.GAMEPAD_L1;
                        case 101:    // NumPad_5
                            return NavigationCode.GAMEPAD_L2;
                        case 102:    // NumPad_6
                            return NavigationCode.GAMEPAD_L3;
                        case 103:    // NumPad_7
                            return NavigationCode.GAMEPAD_R1;
                        case 104:    // NumPad_8
                            return NavigationCode.GAMEPAD_R2;
                        case 105:    // NumPad_9
                            return NavigationCode.GAMEPAD_R3;
                        case 106:    // NumPad_Multiply
                            return NavigationCode.GAMEPAD_START;
                        case 107:    // NumPad_Add
                            return NavigationCode.GAMEPAD_BACK;
                    }
                }
            }
                
            
            return null;
        }
        
        //LM: Review: Can we do function callBacks?
        public function readInput(type:String, code:int, callBack:Function):Object {
            // Look up game engine stuff
            return null;
        }
        
    // Protected Methods:
        protected function handleKeyDown(event:KeyboardEvent):void {
            var sfEvent:KeyboardEventEx = event as KeyboardEventEx;
            var controllerIdx:uint = (sfEvent == null) ? 0 : sfEvent.controllerIdx;
            
            var code:Number = event.keyCode;
            var keyStateIndex:uint = controllerIdx * MAX_KEY_CODES + code;
            var keyState:uint = keyHash[keyStateIndex];
            
            if (keyState & KEY_PRESSED) {
                if ((keyState & KEY_SUPRESSED) == 0) {
                    handleKeyPress(InputValue.KEY_HOLD, code, controllerIdx, event.ctrlKey, event.altKey, event.shiftKey);
                }
            } else {
                handleKeyPress(InputValue.KEY_DOWN, code, controllerIdx, event.ctrlKey, event.altKey, event.shiftKey);
                keyHash[keyStateIndex] |= KEY_PRESSED;
            }
        }
        
        protected function handleKeyUp(event:KeyboardEvent):void {
            var sfEvent:KeyboardEventEx = event as KeyboardEventEx;
            var controllerIdx:uint = (sfEvent == null) ? 0 : sfEvent.controllerIdx;
            
            var code:Number = event.keyCode;
            var keyStateIndex:uint = controllerIdx * MAX_KEY_CODES + code;
            keyHash[keyStateIndex] &= ~KEY_PRESSED;
            handleKeyPress(InputValue.KEY_UP, code, controllerIdx, event.ctrlKey, event.altKey, event.shiftKey);
        }
        
        protected function handleKeyPress(type:String, code:Number, controllerIdx:Number, ctrl:Boolean, alt:Boolean, shift:Boolean):void {
            var details:InputDetails = new InputDetails("key", code, type, inputToNav("key", code, shift), controllerIdx, ctrl, alt, shift);
            dispatchEvent(new InputEvent(InputEvent.INPUT, details));
        }
        
    }
}