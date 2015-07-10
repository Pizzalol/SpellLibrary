package ValveLib.Controls
{
   import scaleform.clik.controls.TextInput;
   import scaleform.clik.controls.ScrollingList;
   import scaleform.clik.events.InputEvent;
   import scaleform.clik.interfaces.IDataProvider;
   import scaleform.clik.events.ButtonEvent;
   import scaleform.gfx.MouseEventEx;
   import scaleform.clik.ui.InputDetails;
   import scaleform.clik.constants.InputValue;
   import flash.ui.Keyboard;
   import flash.events.Event;
   import ValveLib.Events.InputBoxEvent;
   import scaleform.clik.managers.FocusHandler;
   import frota;

   public class InputBox extends TextInput
   {

      public function InputBox() {
         super();
      }

      private var _autoCompleteListValue:Object;

      protected var _autoCompleteList:ScrollingList;

      override public function handleInput(param1:InputEvent) : void {
         var _loc6_:IDataProvider = null;
         var _loc7_:ButtonEvent = null;
         var _loc8_:ButtonEvent = null;
         var _loc2_:MouseEventEx = param1 as MouseEventEx;
         var _loc3_:uint = _loc2_ == null?0:_loc2_.mouseIdx;
         var _loc4_:uint = _loc2_ == null?0:_loc2_.buttonIdx;
         if(param1.handled)
         {
            return;
         }
         var _loc5_:InputDetails = param1.details;
         if(_loc5_.value == InputValue.KEY_UP)
         {
            return;
         }
         if(!(this._autoCompleteList == null) && (this._autoCompleteList.visible))
         {
            if(_loc5_.code == Keyboard.UP)
            {
               this._autoCompleteList.selectedIndex = Math.max(0,this._autoCompleteList.selectedIndex-1);
               return;
            }
            if(_loc5_.code == Keyboard.DOWN)
            {
               _loc6_ = Object(this._autoCompleteList)._dataProvider as IDataProvider;
               if(_loc6_ != null)
               {
                  this._autoCompleteList.selectedIndex = Math.min(_loc6_.length-1,this._autoCompleteList.selectedIndex + 1);
               }
               return;
            }
            if(_loc5_.code == Keyboard.ENTER)
            {
               _loc6_ = Object(this._autoCompleteList)._dataProvider as IDataProvider;
               if(_loc6_ != null)
               {
                  text = _loc6_.requestItemAt(this._autoCompleteList.selectedIndex)["label"];
                  dispatchEvent(new Event(Event.CHANGE));
                  return;
               }
            }
         }
         if(_loc5_.code == Keyboard.ENTER)
         {
            trace(" enter pressed - dispatching InputBoxEvent");
            dispatchEvent(new InputBoxEvent(InputBoxEvent.TEXT_SUBMITTED));
            _loc7_ = new ButtonEvent(ButtonEvent.CLICK,true,false,_loc3_,_loc4_,false);
            dispatchEvent(_loc7_);
         }
         else
         {
            if(_loc5_.code == Keyboard.TAB)
            {
               trace(" tab pressed - dispatching InputBoxEvent");
               dispatchEvent(new InputBoxEvent(InputBoxEvent.TAB_PRESSED));
               _loc8_ = new ButtonEvent(ButtonEvent.CLICK,true,false,_loc3_,_loc4_,false);
               dispatchEvent(_loc8_);
            }
         }
         trace("handleInput code = " + _loc5_.code + " this = " + this.name + " stage.focus = " + stage.focus + " getFocus = " + FocusHandler.getInstance().getFocus(0));
         super.handleInput(param1);
      }

      override protected function configUI() : void {
         super.configUI();
         this.findAutoCompleteList();
      }

      public function get autoCompleteList() : Object {
         return this._autoCompleteListValue;
      }

      public function set autoCompleteList(param1:Object) : void {
         this._autoCompleteListValue = param1;
      }

      protected function findAutoCompleteList() : * {
         var _loc1_:ScrollingList = null;
         if(this._autoCompleteListValue is String)
         {
            if(parent != null)
            {
               this._autoCompleteList = parent.getChildByName(this._autoCompleteListValue.toString()) as ScrollingList;
            }
         }
      }
   }
}
