/**
 * Manage focus between the components.  Intercept focus from the player, and hand it off to the "focused" component through the display-list hierarchy using a bubbling approach. Focus can be interupted or handled on every level.
 */

/**************************************************************************

Filename    :   FocusHandler.as

Copyright   :   Copyright 2011 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/
package scaleform.clik.managers {
    
    import flash.display.DisplayObject;
    import flash.display.DisplayObjectContainer;
    import flash.display.InteractiveObject;
    import flash.display.MovieClip;
    import flash.display.Stage;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.FocusEvent;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.utils.Dictionary;
    import scaleform.clik.utils.WeakReference;
    
    import scaleform.gfx.FocusManager;
    import scaleform.gfx.Extensions;
    import scaleform.gfx.FocusEventEx;
    import scaleform.gfx.SystemEx;
    
    import scaleform.clik.constants.FocusMode;
    import scaleform.clik.core.CLIK;
    import scaleform.clik.core.UIComponent;
    import scaleform.clik.events.InputEvent;
    import scaleform.clik.events.FocusHandlerEvent;
    import scaleform.clik.constants.InputValue;
    import scaleform.clik.constants.NavigationCode;
    import scaleform.clik.ui.InputDetails;
    
    [Event(name="input", type="gfx.events.InputEvent")]
    public class FocusHandler {
        
        protected static var initialized:Boolean = false;
        
        public static var instance:FocusHandler;
        public static function getInstance():FocusHandler {
            if (instance == null) { instance = new FocusHandler(); }
            return instance;
        }
        
        public static function init(stage:Stage, component:UIComponent):void {
            if (initialized) { return; }
            var focusHandler:FocusHandler = FocusHandler.getInstance();
            focusHandler.stage = stage;
            
            FocusManager.alwaysEnableArrowKeys = true;
            FocusManager.disableFocusKeys = true;
            initialized = true;
        }
        
    // Constants:
        
    // Public Properties:
        
    // Protected Properties:
        
        protected var _stage:Stage;
        /** Dctionary of weak references to what holds focus within the CLIK FocusHandler framework. */
        protected var currentFocusLookup:Dictionary;
        /** Dctionary of weak references to what the FocusHandler believes "stage.focus" currently references. */
        protected var actualFocusLookup:Dictionary;// NFM: This commonly will point to an InteractiveObject while stage.focus == null.
        /** Internal boolean for tracking whether to prevent the stage from changing its focus. */
        protected var preventStageFocusChanges:Boolean = false;
        
        // Tracks the state of the left mouse button. This is required in Flash Player to work around a bug where if a 
        // Mouse is dragged on top of a TextField that TextField continously dispatches MOUSE_FOCUS_CHANGE events despite
        // focus never moving. We track mouseDown so we know whether a MOUSE_FOCUS_CHANGE from a TextField in Flash Player
        // is a "drag" (ignore) or a "click" (process).
        protected var mouseDown:Boolean = false;
        
    // Initialization:
        public function FocusHandler() {
            currentFocusLookup = new Dictionary();
            actualFocusLookup = new Dictionary();
        }
        
    // Public Getter / Setters:
        public function set stage(value:Stage):void {
            if (_stage == null) { _stage = value; }
            _stage.stageFocusRect = false;
            
            // Only track mouseDown if we're inside Flash Player (see mouseDown definition for more information).
            if (Extensions.enabled) {
                _stage.addEventListener(MouseEvent.MOUSE_DOWN, trackMouseDown, false, 0, true );
                _stage.addEventListener(MouseEvent.MOUSE_UP, trackMouseDown, false, 0, true );
            }
            
            _stage.addEventListener(FocusEvent.FOCUS_IN, updateActualFocus, false, 0, true);
            _stage.addEventListener(FocusEvent.FOCUS_OUT, updateActualFocus, false, 0, true);
            _stage.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, handleMouseFocusChange, false, 0, true);
            _stage.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, handleMouseFocusChange, false, 0, true);
            
            var inputDelegate:InputDelegate = InputDelegate.getInstance();
            inputDelegate.initialize(_stage);
            inputDelegate.addEventListener(InputEvent.INPUT, handleInput, false, 0, true);
        }
        
    // Public Methods:
        public function getFocus(focusGroupIdx:uint):InteractiveObject { return getCurrentFocusDisplayObject( focusGroupIdx ); }
        public function setFocus(focus:InteractiveObject, focusGroupIdx:uint = 0, mouseChange:Boolean = false):void {
            // trace("\n *** FocusHandler :: setFocus( " + focus + ", " + focusGroupIdx + " )");
            // if (focus == currentFocusLookup[index]) { return; } // NFM: This prevents some _stage.focus -> FocusHandler communication.
            var focusParam:InteractiveObject = focus;
            var focusComponent:UIComponent;
            
            // Determine Component focus
            if (focus != null) { // New focus can be null if clicking on something that is not focus enabled.
                // Recursive lookup to find final focusTarget
                while (true) {
                    focusComponent = focus as UIComponent;
                    if (focusComponent == null) { break; }
                    if (focusComponent.focusTarget != null) {
                        focus = focusComponent.focusTarget;
                    } else {
                        break;
                    }
                }
            }
            
            if (focusComponent != null) {
                if ( focusComponent.focusable == false) { 
                    focus = null; 
                }
            }
            
            // NFM: If _stage.focus is moved using the mouse, it cannot end up on a !tabEnabled InteractiveObject.
            //      If we return instead of (newFocus = null), focus will remain on previous InteractiveObject.
            //      Check if newFocus is a Sprite because TextFields are .tabEnabled == false but can receive stage
            //      focus via mouse click.
            var spr:Sprite = focus as Sprite;
            if (spr && mouseChange && spr.tabEnabled == false) {
                focus = null; 
            }
            
            if (CLIK.disableNullFocusMoves && (focus == null || focus == _stage)) { 
                return; 
            }
            
            // Make focus change
            var actualFocus:DisplayObject = getActualFocusDisplayObject( focusGroupIdx );
            var currentFocus:DisplayObject = getCurrentFocusDisplayObject( focusGroupIdx );  //LM: DisplayObjects? Maybe UIComponents....
            
            // If component focus has changed
            if (currentFocus != focus) {
                // Turn off old focus
                focusComponent = currentFocus as UIComponent;
                if (focusComponent != null) { 
                    focusComponent.focused = focusComponent.focused & ~(1 << focusGroupIdx);
                }
                if (currentFocus != null) {
                    if(currentFocus is UIComponent)
                        (currentFocus as UIComponent).dispatchEventAndSound( new FocusHandlerEvent(FocusHandlerEvent.FOCUS_OUT, true, false, focusGroupIdx) );
                    else
                        currentFocus.dispatchEvent( new FocusHandlerEvent(FocusHandlerEvent.FOCUS_OUT, true, false, focusGroupIdx) );
                }
                
                // Turn on new focus.
                currentFocus = focus;
                setCurrentFocusDisplayObject( focusGroupIdx, focus );
                focusComponent = currentFocus as UIComponent;
                if (focusComponent != null) {
                    focusComponent.focused = focusComponent.focused | (1 << focusGroupIdx);
                }
                if (currentFocus != null) 
                {
                    if(currentFocus is UIComponent)
                        (currentFocus as UIComponent).dispatchEventAndSound( new FocusHandlerEvent(FocusHandlerEvent.FOCUS_IN, true, false, focusGroupIdx) );
                    else
                        currentFocus.dispatchEvent( new FocusHandlerEvent(FocusHandlerEvent.FOCUS_IN, true, false, focusGroupIdx) );
                }
            }
            
            /*
             * Stage focus has changed. This is important to do separately, in case a sub-component was clicked, and it might get stage focus.
             * Note that in composite components, since the parent component will likely not have mouse events, the stage focus remains
             * on the element that has been clicked. 
             * 
             * NFM: Only update stage.focus to match if actualFocus is not a textField who's focusTarget is a UIComponent (TextInput, for example).
             */
            var isActualFocusTextField:Boolean = actualFocus is TextField;
            var isCurrentFocusUIComponent:Boolean = currentFocus is UIComponent;
            if (actualFocus != currentFocus && (!isActualFocusTextField || (isActualFocusTextField && !isCurrentFocusUIComponent))) {
                // NFM: Since _stage.focus is going to control non-UIComponents, this is required so that MovieClips, textFields
                //      and Sprites are all properly updated via stage focus.
                // 
                //      Focus may now point to something other than the original component. In the case of a textField, focus
                //      and focusComponent may both be null, but the _stage.focus should still be set to the TextField if applicable.
                if (focusParam is TextField && focusParam != focus && focus == null) {
                    focus = focusParam;
                }
                
                preventStageFocusChanges = true;
                
                if (Extensions.isScaleform) { 
                    var controllerMask:Number = FocusManager.getControllerMaskByFocusGroup(focusGroupIdx); //.getControllerMaskByFocusGroup(index);
                    var numControllers:uint = Extensions.numControllers;
                    for (var i:uint = 0; i < numControllers; i++) {
                        var controllerValue:Boolean = ((controllerMask >> i) & 0x1) != 0;
                        if ( controllerValue ) {
                            setSystemFocus(focus as InteractiveObject, i);
                        }
                    }
                }
                else {
                    setSystemFocus(focus as InteractiveObject);
                }
                
                _stage.addEventListener(Event.ENTER_FRAME, clearFocusPrevention, false, 0, true);
            }
        }
        
        // PPS: We need to use a weak reference to store the focused elements since they may not be 
        //      unloaded correctly. The WeakReference utility class provides this functionality.
        // \BEGIN
        protected function getCurrentFocusDisplayObject(focusGroupIdx:uint):InteractiveObject {
            //return (currentFocusLookup.getValue( focusGroupIdx ) as InteractiveObject);
            var ref:WeakReference = currentFocusLookup[focusGroupIdx] as WeakReference;
            if (ref) return ref.value as InteractiveObject;
            else return null;
        }
        protected function setCurrentFocusDisplayObject(focusGroupIdx:uint, dobj:InteractiveObject):void {
            //currentFocusLookup.setValue(focusGroupIdx, dobj);
            currentFocusLookup[focusGroupIdx] = new WeakReference(dobj);
        }
        protected function getActualFocusDisplayObject(focusGroupIdx:uint):InteractiveObject {
            //return (actualFocusLookup.getValue( focusGroupIdx ) as InteractiveObject);
            var ref:WeakReference = actualFocusLookup[focusGroupIdx] as WeakReference;
            if (ref) return ref.value as InteractiveObject;
            else return null;
        }
        protected function setActualFocusDisplayObject(focusGroupIdx:uint, dobj:InteractiveObject):void {
            //actualFocusLookup.setValue(focusGroupIdx, dobj);
            actualFocusLookup[focusGroupIdx] = new WeakReference(dobj);
        }
        // \END
        
        // Abstracts _stage.focus = for Scaleform / Flash Player.
        protected function setSystemFocus(newFocus:InteractiveObject, controllerIdx:uint = 0):void {
            if (Extensions.isScaleform) {
                FocusManager.setFocus(newFocus, controllerIdx);
            }
            else {
                _stage.focus = newFocus;
            }
        }
        // Abstracts _stage.focus = for Scaleform / Flash Player.
        protected function getSystemFocus(controllerIdx:uint = 0):InteractiveObject {
            if (Extensions.isScaleform) {
                return FocusManager.getFocus(controllerIdx);
            }
            else {
                return _stage.focus;
            }
        }
        
        protected function clearFocusPrevention(e:Event):void {
            preventStageFocusChanges = false;
            _stage.removeEventListener(Event.ENTER_FRAME, clearFocusPrevention, false);
        }
        
        //LM: Consider making handleInput a manual function
        public function input(details:InputDetails):void {
            var event:InputEvent = new InputEvent(InputEvent.INPUT, details);
            handleInput(event);
        }
            
        public function trackMouseDown( e:MouseEvent ):void {
            mouseDown = e.buttonDown;
        }
        
    // Protected Methods:
        protected function handleInput(event:InputEvent):void {
            var controllerIdx:Number = event.details.controllerIndex;
            var focusGroupIdx:Number = FocusManager.getControllerFocusGroup(controllerIdx);
            
            /*
             * Implementation notes:
             *      We will dispatch the Input Event from the focused component. Since it is a bubbling event
             *      it can be caught using the capture phase (on the way up from Stage), as well as back down from
             *      the component to the stage, which allows us to implement the same approaches used in the AS2
             *      version, but with native code. It will be up to the components/developer to set handled=true
             *      to stop the event. 
             */
            
             // Allow components to try and handle input
            var component:InteractiveObject = getCurrentFocusDisplayObject( focusGroupIdx );
            if (component == null) { component = _stage; } // If nothing is selected, dispatch input from the stage?
            var newEvent:InputEvent = event.clone() as InputEvent; // We have to do this to be able to check handled property when a component calls event.handled. If we use preventDefault on the initial event, it will not work.
            
            var ok:Boolean;
            
            if (component is UIComponent)
                ok = (component as UIComponent).dispatchEventAndSound(newEvent);
            else
                ok = component.dispatchEvent(newEvent);
            
            if (!ok || newEvent.handled) { return; }
            
            // Default focus logic
            if (event.details.value == InputValue.KEY_UP) { return; } // Only key-down events have a default behaviour
            var nav:String = event.details.navEquivalent;
            if (nav == null) { return; } // Only navigation equivalents have a default behaviour.
            
            // Get current stage-focused element
            var focusedElement:InteractiveObject = getCurrentFocusDisplayObject( focusGroupIdx );
            // Get what we THINK is the stage-focused element
            var actualFocus:InteractiveObject = getActualFocusDisplayObject( focusGroupIdx );
            var stageFocusedElement:InteractiveObject = getSystemFocus( focusGroupIdx );
            
            // TextField edge case
            if (actualFocus is TextField && actualFocus == focusedElement && handleTextFieldInput(nav, controllerIdx)) { return; }
            if (actualFocus is TextField && handleTextFieldInput(nav, controllerIdx)) { return; }
            
            var dirX:Boolean = (nav == NavigationCode.LEFT || nav == NavigationCode.RIGHT);
            var dirY:Boolean = (nav == NavigationCode.UP || NavigationCode.DOWN);
            
            /*
            trace(" \n\n\n *********** FocusHandler :: handleInput() ***************** ");
            trace("_stage.focus: \t\t" + getSystemFocus(controllerIdx));
            trace( "currentFocusLookup[" + focusGroupIdx + "]: \t" + getCurrentFocusDisplayObject(focusGroupIdx) );
            trace( "actualFocusLookup[" + focusGroupIdx + "]: \t" + getActualFocusDisplayObject(focusGroupIdx) );
            */
            
            // NFM: If our focusedElement is null, check stage.focus and actualFocus to see if we have any reference
            //      to where focus should be. This could be removed if we don't want CLIK's null focus to start from 
            //      where ever the stage is currently focused... ultimately a small behavior choice.
            if (focusedElement == null) { 
                if (stageFocusedElement && stageFocusedElement is UIComponent) {
                    focusedElement = stageFocusedElement as UIComponent;
                }
            }
            
            if (focusedElement == null) { 
                if (actualFocus && actualFocus is UIComponent) {
                    focusedElement = actualFocus as UIComponent;
                }
            }
            
            // If the focusedElement is still null, focus is "lost" and input should not change focus.
            if (focusedElement == null) { return; }
            
            var focusContext:DisplayObjectContainer = focusedElement.parent;
            var focusMode:String = FocusMode.DEFAULT;
            if (dirX || dirY) {
                var focusProp:String = dirX ? FocusMode.HORIZONTAL : FocusMode.VERTICAL;
                while (focusContext != null) {
                    if (focusProp in focusContext) {
                        focusMode = focusContext[focusProp];
                        if (focusMode != null && focusMode != FocusMode.DEFAULT) { break; }
                        focusContext = focusContext.parent;
                    } else {
                        break;
                    }
                }
            } else {
                focusContext = null;
            }
            
            // NFM: If our focusedElement contains a TextField, we want to look for the next enabled element from
            //      the textField rather than using the component which may find the TextField. This fix may not
            //      be required if every component is setup perfectly, but it seems like a reasonable check to add
            //      to avoid bugs for custom CLIK components.
            if (actualFocus is TextField && actualFocus.parent == focusedElement) { 
                focusedElement = getSystemFocus( controllerIdx );
            }
            
            // Change focus manually.
            var newFocus:InteractiveObject = FocusManager.findFocus(nav, /*focusContext,*/ null, focusMode == FocusMode.LOOP, focusedElement, false, controllerIdx);
            
            // LM:  Multiple calls to stage.focus may result in this call. 
            //      Consider using the focused setter where possible (see commented code below that wasn't working yet)
            if (newFocus != null) {
                // NFM: KEY_FOCUS_CHANGE's necessity is still under review.
                // focusedElement.dispatchEventAndSound( new FocusEvent( FocusEvent.KEY_FOCUS_CHANGE, true, false, newFocus ) );
                setFocus(newFocus, focusGroupIdx);
            }
            
            /*
                if (newFocus is UIComponent) { (newFocus as UIComponent).focused |= index; }
                else { _stage.focus = newFocus; } //LM: Missing index.
            }*/
        }
        
        // FocusEvent.MOUSE_FOCUS_CHANGE, FocusEvent.KEY_FOCUS_CHANGE
        protected function handleMouseFocusChange(event:FocusEvent):void {
            handleFocusChange(event.target as InteractiveObject, event.relatedObject as InteractiveObject, event);
        }
        
        protected function handleFocusChange(oldFocus:InteractiveObject, newFocus:InteractiveObject, event:FocusEvent):void {
            // trace("\n *** handleFocusChange (" + event.type + "): " + oldFocus + " -> " + newFocus);
            
            // Hack to work around bug in Flash where MOUSE_FOCUS_CHANGE is fired when a mouse is dragged ontop of a TextField.
            // mouseDown will only ever be true within Flash Player. If this is a drag (mouseDown == true), ignore the event. 
            if (mouseDown && newFocus is TextField) { 
                event.preventDefault(); 
                return; 
            }
            
            // NFM, 10/31/2011: Non-selectable dynamic textFields can still receive focus. This can be undesirable
            //                  in some cases. Setting CLIK.disableDynamicTextFieldFocus will prevent this for all
            //                  dynamic TextFields (selectable AND non-selectable).
            if (CLIK.disableDynamicTextFieldFocus && newFocus is TextField) {
                var focusTF:TextField = newFocus as TextField;
                if (focusTF.type == "dynamic") {
                    event.stopImmediatePropagation();
                    event.stopPropagation();
                    event.preventDefault();
                    return;
                }
            }
            
            // NFM, 6/29/2011:  Rather than allow the default behavior (stage.focus is moved to the target for keyboard
            //                  and mouse focus changes [particularly mouse]), prevent the default behavior and let
            //                  FocusHandler handle moving focus around and then setting stage.focus when it's complete.
            //                  
            //                  This should only be used for UIComponents (which call stage.focus = this; themselves in 
            //                  set focused()). MovieClips and TextFields can still use the default behavior.
            if (newFocus is UIComponent) { 
                event.preventDefault();
            }
            
            // Do not allow the textField -> null default behaviour in the framework. Can be toggled off using CLIK.as.
            if (oldFocus is TextField && newFocus == null && CLIK.disableTextFieldToNullFocusMoves) { 
                event.preventDefault();
                return; 
            }
            
            var sfEvent:FocusEventEx = event as FocusEventEx;
            var controllerIdx:uint = sfEvent == null ? 0 : sfEvent.controllerIdx;
            var focusGroupIdx:uint = FocusManager.getControllerFocusGroup(controllerIdx);
            
            /*
            // AS2 Special Case:    If the MovieClip that included focus was unloaded and reloaded, then the FocusHandler 
            //                      thinks the new instance is the unloaded one and considers the new instance as  
            //                      the currently focused element - which is incorrect. Check if actualFocus or 
            //                      actualFocus._parent.focused (for TextField) is false - if so, reapply focus.
            // NFM: Not clear on whether this is necessary for AS2.
            var actualFocus:MovieClip = actualFocusLookup[focusIdx];
            if (actualFocus == newFocus) {
                var np:MovieClip = (newFocus instanceof TextField) ? newFocus._parent : newFocus;
                var npf:Number = np.focused;
                if (npf & (1 << focusIdx) == 0) {
                    np.focused = npf | (1 << focusIdx);
                }
            }
            */
            
            // Storing stage focus
            setActualFocusDisplayObject( focusGroupIdx, newFocus );
            setFocus(newFocus, focusGroupIdx, (event.type == FocusEvent.MOUSE_FOCUS_CHANGE));
        }
        
        protected function updateActualFocus(event:FocusEvent):void {
            var oldFocus:InteractiveObject;
            var newFocus:InteractiveObject;
            if (event.type == FocusEvent.FOCUS_IN) {                    // FOCUS_IN
                oldFocus = event.relatedObject as InteractiveObject;    // old -> event.relatedObject
                newFocus = event.target as InteractiveObject;           // new -> event.target.
            } else {                                                    // FOCUS_OUT 
                oldFocus = event.target as InteractiveObject;           // old -> event.target.
                newFocus = event.relatedObject as InteractiveObject;    // new -> event.relatedObject.
            }
            
            // trace("\n *** updateActualFocus: (" + event.type + "): " + oldFocus + " -> " + newFocus);
            
            if (event.type == FocusEvent.FOCUS_OUT) { // NFM: Should this only be for FOCUS_OUT? (Probably, but could use review.)
                if (preventStageFocusChanges) {
                    event.stopImmediatePropagation(); 
                    event.stopPropagation(); 
                }
            }
            
            var sfEvent:FocusEventEx = event as FocusEventEx;
            var controllerIdx:uint = sfEvent == null ? 0 : sfEvent.controllerIdx;
            var focusGroupIdx:uint = FocusManager.getControllerFocusGroup(controllerIdx); 
            setActualFocusDisplayObject(focusGroupIdx, newFocus);
            
            // In the case of a TextInput (or a similar component), we need to ensure that whenever focus is supposed to move
            // to the TextInput (regardless of how [mouse, keyboard, stage.focus, FocusHandler.setFocus, tab, arrow keys, etc..],
            // actualFocus == textField and currentFocus == TextInput. To do so, TextInput must change FocusHandler.focus 
            // and stage.focus when FocusIn events are fired by the textField or itself.
            //
            // To avoid unnecessary updates to stage.focus and FocusHandler, if stage.focus is being moved from 
            // the old currentFocus to a textField and the textField is a child of currentFocus, do not call setFocus() since
            // this is (hopefully!) just the TextInput ensuring that all focus references are pointing to the correct
            // targets.
            var currentFocus:InteractiveObject = getCurrentFocusDisplayObject( focusGroupIdx );
            if (newFocus != null && newFocus is TextField && newFocus.parent != null && 
                currentFocus == newFocus.parent && currentFocus == oldFocus) { 
                return;
            }
            
            // NFM: This logic allows users to use _stage.focus = rather than FocusHandler.setFocus().
            var isActualFocusTextField:Boolean = newFocus is TextField;
            var isCurrentFocusUIComponent:Boolean = currentFocus is UIComponent;
            // If _stage.focus doesn't match our current framework focus
            if (newFocus != currentFocus) {
                // If framework focus is a UIComponent and _stage.focus is pointed to a textField, leave both be.
                // If _stage.focus was just set to null, make sure we update framework focus (eg. stage.focus = null).
                if (!(isActualFocusTextField && isCurrentFocusUIComponent) || newFocus == null) {
                    if (!preventStageFocusChanges || isActualFocusTextField) { 
                        setFocus(newFocus, focusGroupIdx); // Update the framework focus manually.
                    }
                }
            }
        }
        
        // @TODO: Selection.getCaretIndex(controllerIdx:Number) in AS2 needs AS3 support.
        protected function handleTextFieldInput(nav:String, controllerIdx:uint):Boolean {
            var actualFocus:TextField = getActualFocusDisplayObject( controllerIdx ) as TextField;
            if (actualFocus == null) { return false; }
            
            var position:int = actualFocus.caretIndex; //Selection.getCaretIndex(controllerIdx); //LM: Might have to look this up differently.
            var focusIdx:Number = 0; //Selection.getControllerFocusGroup(controllerIdx); //LM: Not implemented in GFx yet.
            
            switch(nav) {
                case NavigationCode.UP:
                    if (!actualFocus.multiline) { 
                        return false; 
                    }
                    // Fall through to next case.
                case NavigationCode.LEFT:
                    return (position > 0);
                    
                    
                case NavigationCode.DOWN:
                    if (!actualFocus.multiline) { 
                        return false;
                    }
                    // Fall through to next case.
                case NavigationCode.RIGHT:
                    return (position < actualFocus.length);
            }
            
            return false;
        }
        
    }
    
}