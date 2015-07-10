package ValveLib
{
   import flash.display.MovieClip;
   import scaleform.clik.managers.InputDelegate;
   import flash.display.StageScaleMode;
   import flash.display.StageAlign;
   import flash.events.Event;
   import scaleform.clik.core.UIComponent;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Loader;
   import flash.display.Bitmap;
   import flash.net.URLRequest;
   import flash.display.Scene;
   
   public dynamic class Globals extends Object
   {
      
      public function Globals() {
         this.cachedImageData = {};
         super();
      }
      
      public static var instance:Globals = null;
      
      public static function Create(param1:MovieClip) : * {
         if(instance == null)
         {
            instance = new Globals();
            instance.Init(param1);
         }
         return instance;
      }
      
      public var UISlot:Number = 0;
      
      public var noInvisibleAdvance:Boolean = true;
      
      public var Level0:MovieClip = null;
      
      public var ElementDepths;
      
      public var GameInterface:Object = null;
      
      public var PlatformCode:Number;
      
      public var resizeManager:ResizeManager = null;
      
      public var cachedImageData:Object;
      
      public function Init(param1:MovieClip) : * {
         InputDelegate.getInstance().externalInputHandler = this.customInputHandler;
         this.Level0 = param1;
         param1.stage.scaleMode = StageScaleMode.NO_SCALE;
         param1.stage.align = StageAlign.TOP_LEFT;
         if(this.resizeManager == null)
         {
            this.resizeManager = new ResizeManager();
            this.resizeManager.AuthoredWidth = param1.stage.stageWidth;
            this.resizeManager.AuthoredHeight = param1.stage.stageHeight;
            trace("Globals.Init() w = " + param1.stage.stageWidth + " h = " + param1.stage.stageHeight);
            this.resizeManager.OnStageResize();
            param1.stage.addEventListener(Event.RESIZE,this.onStageResize);
         }
         if(UIComponent.sdkVersion != "4.2.23")
         {
            trace("Warning: UI file compiled with incorrect SDK version");
         }
      }
      
      public function onStageResize(param1:Event) : * {
         trace("onStageResize");
         if(this.resizeManager)
         {
            this.resizeManager.OnStageResize();
         }
      }
      
      public function debugPrintChildren(param1:*, param2:Boolean=true, param3:Number=0) : * {
         var _loc4_:* = NaN;
         var _loc5_:DisplayObject = null;
         if(param1 == null)
         {
            return;
         }
         _loc4_ = 0;
         while(_loc4_ < param1.numChildren)
         {
            _loc5_ = param1.getChildAt(_loc4_);
            trace(this.debugTabs(param3),_loc5_.name,_loc5_);
            if((param2) && _loc5_ is DisplayObjectContainer)
            {
               this.debugPrintChildren(_loc5_,true,param3 + 1);
            }
            _loc4_++;
         }
      }
      
      public function debugPrintParent(param1:*) : * {
         if(param1 == null)
         {
            return;
         }
         var _loc2_:* = 0;
         while(param1 != null)
         {
            trace(this.debugTabs(_loc2_),param1.name,param1 + " (width,height " + param1.width + ", " + param1.height + " - (scale " + param1.scaleX + ", " + param1.scaleY + ")");
            param1 = param1.parent;
            _loc2_++;
         }
      }
      
      public function debugTabs(param1:Number) : String {
         var _loc3_:* = NaN;
         var _loc2_:* = "";
         _loc3_ = 0;
         while(_loc3_ < param1)
         {
            _loc2_ = _loc2_ + "   ";
            _loc3_++;
         }
         return _loc2_;
      }
      
      public function RequestElement(param1:String, param2:Object) : * {
         var _loc3_:ElementLoader = null;
         trace("RequestElement " + param1 + " gameAPI = " + param2);
         if((this.ElementDepths) && (this.ElementDepths[param1]))
         {
            trace("RequestElement " + param1 + " depth = " + this.ElementDepths[param1]);
            _loc3_ = this["Loader_" + param1] as ElementLoader;
            if(_loc3_ == null)
            {
               _loc3_ = new ElementLoader();
               this["Loader_" + param1] = _loc3_;
               trace("saved loader as: Loader_" + param1);
            }
            _loc3_.Init(this.Level0,param2,this.ElementDepths[param1],param1);
         }
      }
      
      public function RemoveElement(param1:MovieClip) : * {
         var _loc2_:String = null;
         var _loc3_:ElementLoader = null;
         if(param1 == null)
         {
            trace("RemoveElement: mc is null");
            return;
         }
         trace("RemoveElement " + param1 + " ID = " + param1["elementName"]);
         if(param1["gameAPI"].OnUnload(param1))
         {
            _loc2_ = "Loader_" + param1["elementName"];
            trace(" Looking up element loader: " + _loc2_);
            _loc3_ = this[_loc2_] as ElementLoader;
            if(_loc3_ != null)
            {
               _loc3_.Unload();
               this[_loc2_] = null;
               _loc3_ = null;
            }
         }
      }
      
      public function SetConvars(param1:Object) : * {
         var _loc2_:String = null;
         var _loc3_:* = undefined;
         for (_loc2_ in param1)
         {
            _loc3_ = param1[_loc2_];
            if(_loc3_ != undefined)
            {
               switch(typeof _loc3_)
               {
                  case "string":
                  case "number":
                  case "boolean":
                     this.GameInterface.SetConvar(_loc2_,_loc3_);
                     continue;
                  default:
                     continue;
               }
               
            }
            else
            {
               continue;
            }
         }
      }
      
      public function TraceObject(param1:Object, param2:String) : * {
         var _loc4_:* = NaN;
         var _loc5_:* = NaN;
         var _loc6_:String = null;
         if(!param2)
         {
            param2 = "";
         }
         var _loc3_:* = param2 + "  ";
         if(typeof param1 == "object")
         {
            if(param1 is Array)
            {
               trace(param2 + "[");
               _loc4_ = 0;
               _loc5_ = param1.length;
               while(_loc4_ < _loc5_)
               {
                  this.TraceObject(param1[_loc4_],_loc3_);
                  _loc4_ = _loc4_ + 1;
               }
               trace(param2 + "]");
            }
            else
            {
               trace(param2 + "{");
               for (_loc6_ in param1)
               {
                  trace(_loc3_ + _loc6_ + "=");
                  this.TraceObject(param1[_loc6_],_loc3_);
               }
               trace(param2 + "}");
            }
         }
         else
         {
            trace(param2 + "  " + param1.toString());
         }
      }
      
      public function IsPC() : Boolean {
         return this.PlatformCode == 0;
      }
      
      public function IsXbox() : Boolean {
         return this.PlatformCode == 1;
      }
      
      public function IsPS3() : Boolean {
         return this.PlatformCode == 2;
      }
      
      public function LoadMiniHeroImage(param1:String, param2:MovieClip) : * {
         if(param1 == null || param1.length == 0)
         {
            return;
         }
         trace("load mini hero",param1,param2,param2.name);
         this.LoadImage("images/miniheroes/" + param1 + ".png",param2,false);
      }
      
      public function LoadHeroImage(param1:String, param2:MovieClip) : * {
         var _loc3_:* = 0;
         _loc3_ = param2.numChildren-1;
         while(_loc3_ >= 0)
         {
            param2.removeChildAt(_loc3_);
            _loc3_--;
         }
         if(param1 == null || param1.length == 0)
         {
            return;
         }
         this.LoadImage("images/heroes/" + param1 + ".png",param2,false);
      }
      
      public function LoadItemImage(param1:String, param2:MovieClip) : * {
         var _loc3_:* = 0;
         _loc3_ = param2.numChildren-1;
         while(_loc3_ >= 0)
         {
            param2.removeChildAt(_loc3_);
            _loc3_--;
         }
         if(param1 == null || param1.length == 0)
         {
            return;
         }
         this.LoadImage("images/items/" + param1 + ".png",param2,false);
      }
      
      public function LoadHeroModelImage(param1:String, param2:MovieClip) : * {
         var _loc3_:* = 0;
         _loc3_ = param2.numChildren-1;
         while(_loc3_ >= 0)
         {
            param2.removeChildAt(_loc3_);
            _loc3_--;
         }
         if(param1 == null || param1.length == 0)
         {
            return;
         }
         this.LoadImage("images/heroes_full/" + param1 + ".png",param2,false);
      }
      
      public var NumAvatars = 11;
      
      public function LoadAvatarImage(param1:Number, param2:MovieClip) : * {
         var _loc3_:* = 0;
         _loc3_ = param2.numChildren-1;
         while(_loc3_ >= 0)
         {
            param2.removeChildAt(_loc3_);
            _loc3_--;
         }
         var _loc4_:* = "images/dashboard/avatars/avatar_puck.png";
         switch(param1)
         {
            case 0:
               _loc4_ = "images/dashboard/avatars/avatar_creep.png";
               break;
            case 1:
               _loc4_ = "images/dashboard/avatars/avatar_crystal_maiden.png";
               break;
            case 2:
               _loc4_ = "images/dashboard/avatars/avatar_kunkka.png";
               break;
            case 3:
               _loc4_ = "images/dashboard/avatars/avatar_faceless_void.png";
               break;
            case 4:
               _loc4_ = "images/dashboard/avatars/avatar_furion.png";
               break;
            case 5:
               _loc4_ = "images/dashboard/avatars/avatar_juggernaut.png";
               break;
            case 6:
               _loc4_ = "images/dashboard/avatars/avatar_bloodseeker.png";
               break;
            case 7:
               _loc4_ = "images/dashboard/avatars/avatar_lich.png";
               break;
            case 8:
               _loc4_ = "images/dashboard/avatars/avatar_axe.png";
               break;
            case 9:
               _loc4_ = "images/dashboard/avatars/avatar_pudge.png";
               break;
            case 10:
               _loc4_ = "images/dashboard/avatars/avatar_puck.png";
               break;
         }
         
         this.LoadImage(_loc4_,param2,false);
      }
      
      public function LoadAbilityImage(param1:String, param2:MovieClip) : * {
         var _loc3_:* = 0;
         _loc3_ = param2.numChildren-1;
         while(_loc3_ >= 0)
         {
            param2.removeChildAt(_loc3_);
            _loc3_--;
         }
         if(param1 == null || param1.length == 0)
         {
            return;
         }
         this.LoadImage("images/spellicons/" + param1 + ".png",param2,false);
      }
      
      public function LoadTeamLogo(param1:String, param2:MovieClip) : * {
         var _loc3_:* = 0;
         if(param1 == null || param1.length == 0)
         {
            param1 = "team_radiant";
         }
         _loc3_ = param2.numChildren-1;
         while(_loc3_ >= 0)
         {
            param2.removeChildAt(_loc3_);
            _loc3_--;
         }
         this.LoadImage("images/teams/" + param1 + ".png",param2,false);
      }
      
      public function LoadTournamentPlayerImage(param1:String, param2:MovieClip) : * {
         var _loc3_:* = 0;
         _loc3_ = param2.numChildren-1;
         while(_loc3_ >= 0)
         {
            param2.removeChildAt(_loc3_);
            _loc3_--;
         }
         if(param1 == null || param1.length == 0)
         {
            return;
         }
         this.LoadImage("images/players/" + param1 + ".png",param2,false);
      }
      
      public function LoadImage(param1:String, param2:MovieClip, param3:Boolean) : * {
         this.LoadImageWithCallback(param1,param2,param3,null);
      }
      
      public function RemoveImageFromCache(param1:String) : * {
         if(this.cachedImageData[param1] != null)
         {
            this.cachedImageData[param1] = null;
         }
      }
      
      public function LoadImageWithCallback(param1:String, param2:MovieClip, param3:Boolean, param4:Function) : * {
         var _loc5_:* = 0;
         var _loc6_:Loader = null;
         var _loc7_:Bitmap = null;
         if((param3) && param2["originalWidth"] == null)
         {
            param2["originalWidth"] = param2.width / param2.scaleX;
            param2["originalHeight"] = param2.height / param2.scaleY;
         }
         _loc5_ = param2.numChildren-1;
         while(_loc5_ >= 0)
         {
            param2.removeChildAt(_loc5_);
            _loc5_--;
         }
         if(param1 == null || param1.length == 0)
         {
            return;
         }
         if(this.cachedImageData[param1] == null)
         {
            _loc6_ = new Loader();
            _loc6_["imageName"] = param1;
            _loc6_["resize"] = param3;
            _loc6_["callbackfunc"] = param4;
            _loc6_.load(new URLRequest(param1));
            _loc6_.visible = false;
            param2.addChild(_loc6_);
            _loc6_.contentLoaderInfo.addEventListener(Event.COMPLETE,this.imageLoadComplete);
         }
         else
         {
            _loc7_ = new Bitmap(this.cachedImageData[param1],"auto",true);
            _loc7_.smoothing = true;
            param2.addChild(_loc7_);
            if(param3)
            {
               _loc7_.width = param2["originalWidth"];
               _loc7_.height = param2["originalHeight"];
            }
            if(param4 != null)
            {
               param4(_loc7_);
            }
         }
      }
      
      public function PrecacheImage(param1:String) : * {
         if(param1 == null || param1.length == 0)
         {
            return;
         }
         if(this.cachedImageData[param1] != null)
         {
            return;
         }
         var _loc2_:Loader = new Loader();
         _loc2_["imageName"] = param1;
         _loc2_.load(new URLRequest(param1));
         _loc2_.contentLoaderInfo.addEventListener(Event.COMPLETE,this.precacheImageComplete);
      }
      
      public function precacheImageComplete(param1:Event) : * {
         param1.target.removeEventListener(Event.COMPLETE,this.precacheImageComplete);
         var _loc2_:Bitmap = param1.target.content as Bitmap;
         this.cachedImageData[param1.target.loader["imageName"]] = _loc2_.bitmapData;
      }
      
      public function imageLoadComplete(param1:Event) : * {
         var _loc3_:Function = null;
         param1.target.removeEventListener(Event.COMPLETE,this.imageLoadComplete);
         var _loc2_:Bitmap = param1.target.content as Bitmap;
         this.cachedImageData[param1.target.loader["imageName"]] = _loc2_.bitmapData;
         _loc2_.smoothing = true;
         if(param1.target.loader["resize"])
         {
            if(!(param1.target.loader.parent == null) && !(param1.target.content == null))
            {
               param1.target.content.width = param1.target.loader.parent["originalWidth"];
               param1.target.content.height = param1.target.loader.parent["originalHeight"];
            }
         }
         param1.target.loader.visible = true;
         if(param1.target.loader["callbackfunc"])
         {
            _loc3_ = param1.target.loader["callbackfunc"];
            _loc3_(param1.target.content);
         }
      }
      
      public function customInputHandler(param1:String, param2:Number, param3:*=null) : * {
      }
      
      public function getFrameNumberFromLabel(param1:MovieClip, param2:String) : int {
         var _loc3_:Scene = param1.currentScene;
         var _loc4_:* = 0;
         while(_loc4_ < _loc3_.labels.length)
         {
            if(_loc3_.labels[_loc4_].name == param2)
            {
               return _loc3_.labels[_loc4_].frame;
            }
            _loc4_++;
         }
         return -1;
      }
   }
}
