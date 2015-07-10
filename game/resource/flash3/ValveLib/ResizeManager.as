package ValveLib
{
   import flash.display.MovieClip;
   import flash.geom.Point;
   
   public class ResizeManager extends Object
   {
      
      public function ResizeManager() {
         this.ScalingFactors = new Array();
         this.ReferencePositions = new Array();
         this.Listeners = new Array();
         super();
         var _loc1_:* = 0;
         while(_loc1_ <= SCALE_USING_HORIZONTAL)
         {
            this.ScalingFactors.push(1);
            _loc1_++;
         }
         var _loc2_:* = 0;
         while(_loc2_ <= REFERENCE_CENTER_Y)
         {
            this.ReferencePositions.push(0);
            _loc2_++;
         }
      }
      
      public static var ALIGN_NONE:Number = 0;
      
      public static var ALIGN_LEFT:Number = 0;
      
      public static var ALIGN_RIGHT:Number = 1;
      
      public static var ALIGN_TOP:Number = 0;
      
      public static var ALIGN_BOTTOM:Number = 1;
      
      public static var ALIGN_CENTER:Number = 0.5;
      
      public static var POSITION_LEFT:Number = 0;
      
      public static var POSITION_SAFE_LEFT:Number = 0.075;
      
      public static var POSITION_RIGHT:Number = 1;
      
      public static var POSITION_SAFE_RIGHT:Number = 0.925;
      
      public static var POSITION_TOP:Number = 0;
      
      public static var POSITION_SAFE_TOP:Number = 0.075;
      
      public static var POSITION_BOTTOM:Number = 1;
      
      public static var POSITION_SAFE_BOTTOM:Number = 0.925;
      
      public static var POSITION_CENTER:Number = 0.5;
      
      public static var REFERENCE_LEFT:Number = 0;
      
      public static var REFERENCE_TOP:Number = 1;
      
      public static var REFERENCE_SAFE_LEFT:Number = 2;
      
      public static var REFERENCE_SAFE_TOP:Number = 3;
      
      public static var REFERENCE_RIGHT:Number = 4;
      
      public static var REFERENCE_BOTTOM:Number = 5;
      
      public static var REFERENCE_SAFE_RIGHT:Number = 6;
      
      public static var REFERENCE_SAFE_BOTTOM:Number = 7;
      
      public static var REFERENCE_CENTER_X:Number = 8;
      
      public static var REFERENCE_CENTER_Y:Number = 9;
      
      public static var SCALE_NONE:Number = 0;
      
      public static var SCALE_BIGGEST:Number = 1;
      
      public static var SCALE_SMALLEST:Number = 2;
      
      public static var SCALE_USING_VERTICAL:Number = 3;
      
      public static var SCALE_USING_HORIZONTAL:Number = 4;
      
      public static var PC_BORDER_SIZE:Number = 10;
      
      public var ScalingFactors:Array;
      
      public var ReferencePositions:Array;
      
      public var ScreenWidth:Number = -1;
      
      public var ScreenHeight:Number = -1;
      
      public var ScreenX:Number = -1;
      
      public var ScreenY:Number = -1;
      
      public var AuthoredWidth:Number;
      
      public var AuthoredHeight:Number;
      
      public var Hidden:Boolean;
      
      public var Listeners:Array;
      
      public function UpdateReferencePositions() : * {
         this.ReferencePositions[REFERENCE_LEFT] = this.ScreenX;
         this.ReferencePositions[REFERENCE_RIGHT] = this.ScreenX + this.ScreenWidth;
         this.ReferencePositions[REFERENCE_TOP] = this.ScreenY;
         this.ReferencePositions[REFERENCE_BOTTOM] = this.ScreenY + this.ScreenHeight;
         this.ReferencePositions[REFERENCE_CENTER_X] = Math.floor((this.ReferencePositions[REFERENCE_LEFT] + this.ReferencePositions[REFERENCE_RIGHT]) / 2);
         this.ReferencePositions[REFERENCE_CENTER_Y] = Math.floor((this.ReferencePositions[REFERENCE_TOP] + this.ReferencePositions[REFERENCE_BOTTOM]) / 2);
         if(Globals.instance.IsPC())
         {
            this.ReferencePositions[REFERENCE_SAFE_LEFT] = this.ReferencePositions[REFERENCE_LEFT] + PC_BORDER_SIZE;
            this.ReferencePositions[REFERENCE_SAFE_TOP] = this.ReferencePositions[REFERENCE_TOP] + PC_BORDER_SIZE;
            this.ReferencePositions[REFERENCE_SAFE_RIGHT] = this.ReferencePositions[REFERENCE_RIGHT] - PC_BORDER_SIZE;
            this.ReferencePositions[REFERENCE_SAFE_BOTTOM] = this.ReferencePositions[REFERENCE_BOTTOM] - PC_BORDER_SIZE;
         }
         else
         {
            this.ReferencePositions[REFERENCE_SAFE_LEFT] = this.ScreenX + Math.ceil(POSITION_SAFE_LEFT * this.ScreenWidth);
            this.ReferencePositions[REFERENCE_SAFE_TOP] = this.ScreenY + Math.ceil(POSITION_SAFE_TOP * this.ScreenHeight);
            this.ReferencePositions[REFERENCE_SAFE_RIGHT] = this.ScreenX + Math.floor(POSITION_SAFE_RIGHT * this.ScreenWidth);
            this.ReferencePositions[REFERENCE_SAFE_BOTTOM] = this.ScreenY + Math.floor(POSITION_SAFE_BOTTOM * this.ScreenHeight);
         }
      }
      
      public function SetScaling(param1:MovieClip, param2:Number) : * {
         if(param1["originalXScale"] == null)
         {
            param1["originalXScale"] = param1.scaleX;
            param1["originalYScale"] = param1.scaleY;
         }
         var param2:Number = this.ScalingFactors[param2];
         param1.scaleX = param1.originalXScale * param2;
         param1.scaleY = param1.originalYScale * param2;
         trace("  SetScaling " + param2 + " originalXscale = " + param1["originalXScale"] + " originalYScale = " + param1["originalYScale"] + " obj.scaleX = " + param1.scaleX + " obj.scaleY = " + param1.scaleY);
      }
      
      public function GetPctPosition(param1:Number, param2:Number, param3:Number, param4:Number) : Number {
         return Math.floor(param4 * param1 - param3 * param2);
      }
      
      public function ResetPosition(param1:MovieClip, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number) : * {
         this.SetScaling(param1,param2);
         var _loc7_:Number = this.GetPctPosition(param4,param6,param1.width,this.ScreenWidth);
         var _loc8_:Number = this.GetPctPosition(param3,param5,param1.height,this.ScreenHeight);
         param1.x = this.ScreenX + _loc7_;
         param1.y = this.ScreenY + _loc8_;
      }
      
      public function GetPixelPosition(param1:Number, param2:Number, param3:Number, param4:Number) : * {
         return Math.floor(this.ReferencePositions[param1] + param2 - param4 * param3);
      }
      
      public function ResetPositionByPixel(param1:MovieClip, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number, param7:Number, param8:Number) : * {
         this.SetScaling(param1,param2);
         param1.x = this.GetPixelPosition(param3,param4 * this.ScalingFactors[param2],param5,param1.width);
         param1.y = this.GetPixelPosition(param6,param7 * this.ScalingFactors[param2],param8,param1.height);
      }
      
      public function ResetPositionByPercentage(param1:MovieClip, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number, param7:Number, param8:Number) : * {
         this.SetScaling(param1,param2);
         param1.x = this.GetPixelPosition(param3,param4 * this.ScreenWidth,param5,param1.width);
         param1.y = this.GetPixelPosition(param6,param7 * this.ScreenHeight,param8,param1.height);
      }
      
      public function PositionDashboardPage(param1:MovieClip) : * {
         trace("new PositionDashboardPage");
         this.SetScaling(param1,SCALE_USING_VERTICAL);
         var _loc2_:Number = this.ScreenWidth * 0.5;
         if(this.Is16by9())
         {
            param1.x = _loc2_ - 625 * this.ScalingFactors[SCALE_USING_VERTICAL];
         }
         else
         {
            if(this.Is16by10())
            {
               param1.x = _loc2_ - 540 * this.ScalingFactors[SCALE_USING_VERTICAL];
            }
            else
            {
               param1.x = _loc2_ - 484 * this.ScalingFactors[SCALE_USING_VERTICAL];
            }
         }
         param1.y = 96 * this.ScalingFactors[SCALE_USING_VERTICAL];
      }
      
      public function IsWidescreen() : Boolean {
         return this.ScreenWidth / this.ScreenHeight > 1.5;
      }
      
      public function Is16by9() : Boolean {
         return this.ScreenWidth / this.ScreenHeight > 1.7;
      }
      
      public function Is16by10() : Boolean {
         return this.ScreenWidth / this.ScreenHeight < 1.7 && this.ScreenWidth / this.ScreenHeight > 1.5;
      }
      
      public function OnStageResize() : * {
         var _loc6_:Object = null;
         var _loc1_:Number = Globals.instance.Level0.stage.stageWidth;
         var _loc2_:Number = Globals.instance.Level0.stage.stageHeight;
         Globals.instance.Level0.transform.perspectiveProjection.projectionCenter = new Point(_loc1_ * 0.5,_loc2_ * 0.5);
         this.ScreenX = 0;
         this.ScreenY = 0;
         trace("ResizeManager onResize w = " + _loc1_ + " h = " + _loc2_ + " AuthoredWidth = " + this.AuthoredWidth + " AuthoredHeight = " + this.AuthoredHeight);
         if(this.ScreenWidth == _loc1_ && this.ScreenHeight == _loc2_)
         {
            return;
         }
         this.ScreenWidth = _loc1_;
         this.ScreenHeight = _loc2_;
         var _loc3_:Number = this.ScreenWidth / this.AuthoredWidth;
         var _loc4_:Number = this.ScreenHeight / this.AuthoredHeight;
         if(_loc1_ == 1280 && _loc2_ == 1024)
         {
            _loc4_ = 960 / this.AuthoredHeight;
         }
         if(_loc3_ >= _loc4_)
         {
            this.ScalingFactors[SCALE_BIGGEST] = _loc3_;
            this.ScalingFactors[SCALE_SMALLEST] = _loc4_;
         }
         else
         {
            this.ScalingFactors[SCALE_BIGGEST] = _loc4_;
            this.ScalingFactors[SCALE_SMALLEST] = _loc3_;
         }
         this.ScalingFactors[SCALE_USING_VERTICAL] = _loc4_;
         this.ScalingFactors[SCALE_USING_HORIZONTAL] = _loc3_;
         trace("  ScalingFactors[SCALE_USING_VERTICAL] = " + this.ScalingFactors[SCALE_USING_VERTICAL] + " scalex = " + _loc3_ + " scaley = " + _loc4_);
         this.UpdateReferencePositions();
         var _loc5_:Number = this.Listeners.length;
         var _loc7_:* = 0;
         while(_loc7_ < _loc5_)
         {
            _loc6_ = this.Listeners[_loc7_];
            if(_loc6_["onResize"] != undefined)
            {
               this.Listeners[_loc7_].onResize(this);
            }
            _loc7_ = _loc7_ + 1;
         }
      }
      
      public function GetListenerIndex(param1:Object, param2:Number) : Number {
         var _loc3_:Number = 0;
         if(param2 == -1)
         {
            param2 = this.Listeners.length-1;
         }
         while(_loc3_ <= param2)
         {
            if(this.Listeners[_loc3_] == param1)
            {
               return _loc3_;
            }
            _loc3_++;
         }
         return -1;
      }
      
      public function AddListener(param1:Object) : * {
         if(this.GetListenerIndex(param1,-1) == -1)
         {
            this.Listeners.push(param1);
            param1.onResize(this);
         }
      }
      
      public function RemoveListener(param1:Object) : * {
         var _loc2_:Number = this.Listeners.length-1;
         var _loc3_:Number = this.GetListenerIndex(param1,_loc2_);
         if(_loc3_ == -1)
         {
            return;
         }
         if(_loc3_ == _loc2_)
         {
            this.Listeners.length = _loc2_;
         }
         else
         {
            if(_loc3_ == 0)
            {
               this.Listeners.shift();
            }
            else
            {
               this.Listeners = this.Listeners.slice(0,_loc3_).concat(this.Listeners.slice(_loc3_ + 1,_loc2_ + 1));
            }
         }
      }
      
      private function Remove() : * {
         this.Listeners.length = 0;
         Globals.instance.resizeManager = null;
      }
   }
}
