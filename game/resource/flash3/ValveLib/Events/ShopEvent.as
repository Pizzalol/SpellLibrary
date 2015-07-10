package ValveLib.Events
{
   import flash.events.Event;
   
   public class ShopEvent extends Event
   {
      
      public function ShopEvent(param1:String, param2:Boolean=true, param3:Boolean=false) {
         super(param1,param2,param3);
      }
      
      public static const SHOP_ANIMATED_OPEN:String = "shopAnimatedOpen";
      
      public static const SELECT_ITEM:String = "selectItem";
      
      public static const PURCHASE_ITEM:String = "purchaseItem";
      
      public static const SET_QUICK_BUY_ITEM:String = "setQuickBuyItem";
      
      public static const PLAYER_SHOP_CHANGED:String = "playerShopChanged";
      
      public static const PLAYER_GOLD_CHANGED:String = "playerGoldChanged";
      
      public static const UPDATE_SHOP_ITEM:String = "updateShopItem";
      
      public static const UPGRADE_ITEM:String = "upgradeItem";
      
      public static const SHOW_TOOLTIP:String = "showTooltip";
      
      public static const HIDE_TOOLTIP:String = "hideTooltip";
      
      public function get gold() : Number {
         return this._gold;
      }
      
      public function set gold(param1:Number) : void {
         this._gold = param1;
      }
      
      private var _gold:Number;
      
      public var itemName:String;
      
      public var tooltipObject:Object;
      
      override public function clone() : Event {
         return new ShopEvent(type,bubbles,cancelable);
      }
      
      override public function toString() : String {
         return formatToString("ButtonEvent","type","bubbles","cancelable");
      }
   }
}
