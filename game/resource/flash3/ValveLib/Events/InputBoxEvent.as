package ValveLib.Events
{
   import flash.events.Event;
   
   public class InputBoxEvent extends Event
   {
      
      public function InputBoxEvent(param1:String, param2:Boolean=true, param3:Boolean=false) {
         super(param1,param2,param3);
      }
      
      public static const TEXT_SUBMITTED:String = "textSubmitted";
      
      public static const TAB_PRESSED:String = "tabPressed";
      
      override public function clone() : Event {
         return new InputBoxEvent(type,bubbles,cancelable);
      }
      
      override public function toString() : String {
         return formatToString("ButtonEvent","type","bubbles","cancelable");
      }
   }
}
