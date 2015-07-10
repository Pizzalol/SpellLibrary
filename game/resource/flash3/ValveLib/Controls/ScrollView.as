package ValveLib.Controls
{
   import scaleform.clik.core.UIComponent;
   import scaleform.clik.interfaces.IScrollBar;
   import flash.display.MovieClip;
   import scaleform.clik.constants.InvalidationType;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import scaleform.clik.controls.ScrollIndicator;
   import scaleform.clik.controls.ScrollBar;
   
   public class ScrollView extends UIComponent
   {
      
      public function ScrollView() {
         super();
      }
      
      private var _scrollBarValue:Object;
      
      private var autoScrollBar:Boolean = false;
      
      protected var _scrollBar:IScrollBar;
      
      private var _scrollPosition:Number = 0;
      
      public var contentMask:MovieClip;
      
      public var content:MovieClip;
      
      public var _debug:Boolean = false;
      
      public var overrideMax:int = -1;
      
      public var scrollStep:int = 15;
      
      public function get scrollPosition() : Number {
         return this._scrollPosition;
      }
      
      public function set scrollPosition(param1:Number) : void {
         var _loc2_:Object = this.content.getBounds(this.content);
         var _loc3_:Number = this.content.height - this.contentMask.height;
         _loc3_ = _loc3_ + _loc2_.top / scaleY;
         if(this.overrideMax != -1)
         {
            _loc3_ = this.overrideMax;
         }
         var param1:Number = Math.max(0,Math.min(_loc3_,Math.round(param1)));
         this._scrollPosition = param1;
         invalidateData();
      }
      
      public function get scrollBar() : Object {
         return this._scrollBar;
      }
      
      public function set scrollBar(param1:Object) : void {
         this._scrollBarValue = param1;
         if(this._debug)
         {
            trace("scrollBar set, setting _scrollBarValue to " + this._scrollBarValue);
         }
         invalidate(InvalidationType.SCROLL_BAR);
      }
      
      protected function createScrollBar() : void {
         var _loc1_:IScrollBar = null;
         if(this._debug)
         {
            trace("createScrollBar _scrollBarValue = " + this._scrollBarValue);
         }
         if(this._scrollBar)
         {
            this._scrollBar.removeEventListener(Event.SCROLL,this.handleScroll);
            this._scrollBar.removeEventListener(Event.CHANGE,this.handleScroll);
            this._scrollBar.focusTarget = null;
            this._scrollBar = null;
         }
         if(!this._scrollBarValue || this._scrollBarValue == "")
         {
            if(this._debug)
            {
               trace("ScrolView warning: no scrollbar name specified");
            }
            return;
         }
         if(this._scrollBarValue is String)
         {
            if(parent != null)
            {
               _loc1_ = parent.getChildByName(this._scrollBarValue.toString()) as IScrollBar;
            }
            if(_loc1_ == null)
            {
               trace("ScrollView warning, couldn\'t find scrollbar called: " + this._scrollBarValue.toString());
            }
            else
            {
               if(this._debug)
               {
                  trace("found a scrollbar by name = " + _loc1_);
               }
            }
         }
         else
         {
            _loc1_ = this._scrollBarValue as IScrollBar;
         }
         this._scrollBar = _loc1_;
         invalidateSize();
         if(this._scrollBar == null)
         {
            return;
         }
         this._scrollBar.addEventListener(Event.SCROLL,this.handleScroll,false,0,true);
         this._scrollBar.addEventListener(Event.CHANGE,this.handleScroll,false,0,true);
         this._scrollBar.focusTarget = this;
         this._scrollBar.tabEnabled = false;
      }
      
      public function availableWidth() : Number {
         return this.autoScrollBar?width - this._scrollBar.width:width;
      }
      
      override protected function configUI() : void {
         super.configUI();
         if(!(this._scrollBarValue == "") && !(this._scrollBarValue == null))
         {
            this.scrollBar = this._scrollBarValue;
         }
         addEventListener(MouseEvent.MOUSE_WHEEL,this.handleMouseWheel,false,0,true);
      }
      
      override protected function draw() : void {
         if(isInvalid(InvalidationType.SCROLL_BAR))
         {
            this.createScrollBar();
         }
         this.drawScrollBar();
         this.updateScrollBar();
         super.draw();
      }
      
      private function drawScrollBar() : void {
         var _loc1_:* = NaN;
         _loc1_ = 0;
         if(!this.autoScrollBar)
         {
            return;
         }
         this._scrollBar.x = width - this._scrollBar.width - _loc1_;
         this._scrollBar.y = _loc1_;
         this._scrollBar.height = height - _loc1_ * 2;
      }
      
      protected function handleScroll(param1:Event) : void {
         this.scrollPosition = this._scrollBar.position;
         this.content.y = -this.scrollPosition;
      }
      
      public function updateScrollBar() : void {
         var _loc3_:ScrollIndicator = null;
         var _loc4_:ScrollBar = null;
         if(this.content == null)
         {
            if(this._debug)
            {
               trace("content is null");
            }
            return;
         }
         if(this.contentMask == null)
         {
            if(this._debug)
            {
               trace("contentMask is null");
            }
            return;
         }
         if(this._scrollBar == null)
         {
            if(this._debug)
            {
               trace("_scrollBar is null");
            }
            return;
         }
         var _loc1_:Object = this.content.getBounds(this.content);
         var _loc2_:Number = this.content.height - this.contentMask.height;
         if(this._debug)
         {
            trace("contentBounds.top = " + _loc1_.top + " scaleY = " + scaleY);
         }
         _loc2_ = _loc2_ + _loc1_.top / scaleY;
         if(this.overrideMax != -1)
         {
            _loc2_ = this.overrideMax;
         }
         if(this._scrollBar != null)
         {
            _loc3_ = this._scrollBar as ScrollIndicator;
            if(_loc3_ != null)
            {
               _loc3_.setScrollProperties(this.contentMask.height,0,_loc2_,this.scrollStep);
            }
            _loc4_ = this._scrollBar as ScrollBar;
            if(_loc4_ != null)
            {
               _loc4_.trackScrollPageSize = Math.max(1,this.contentMask.height - this.scrollStep);
            }
            this.scrollPosition = this._scrollPosition;
            this._scrollBar.position = this._scrollPosition;
            this._scrollBar.validateNow();
         }
         if(this._debug)
         {
            trace("parent = " + parent + " updateScrollBar content height = " + this.content.height + " contentMask height = " + this.contentMask.height + " max = " + _loc2_ + " _scrollPosition = " + this._scrollPosition + " content.y = " + this.content.y);
         }
      }
      
      protected function handleMouseWheel(param1:MouseEvent) : void {
         this.scrollList((param1.delta > 0?1:-1) * this.scrollStep);
      }
      
      protected function scrollList(param1:int) : void {
         this.scrollPosition = this.scrollPosition - param1;
      }
   }
}
