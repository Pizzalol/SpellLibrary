package ValveLib
{
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.ProgressEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.net.URLRequest;
   import flash.display.DisplayObjectContainer;
   
   public class ElementLoader extends Object
   {
      
      public function ElementLoader() {
         super();
      }
      
      public var gameAPI:Object;
      
      public var level:Number;
      
      public var loader:Loader;
      
      public var elementName:String;
      
      public var slot:Number;
      
      public var channel:Number;
      
      public var movieClip:MovieClip;
      
      public function Init(param1:MovieClip, param2:Object, param3:Number, param4:String) : * {
         var _loc6_:* = NaN;
         var _loc7_:* = NaN;
         var _loc8_:* = NaN;
         var _loc9_:Loader = null;
         var _loc5_:* = param4 + ".swf";
         if(this.loader == null)
         {
            this.loader = new Loader();
            this.loader.name = param4 + "_loader";
            this.loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS,this.OnLoadProgress);
            this.loader.contentLoaderInfo.addEventListener(Event.COMPLETE,this.onLoadingComplete);
            this.loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR,this.onIOError);
            _loc6_ = -1;
            this.loader.tabIndex = param3;
            _loc7_ = param1.numChildren;
            _loc8_ = 0;
            while(_loc8_ < _loc7_)
            {
               if(param1.getChildAt(_loc8_) is Loader)
               {
                  _loc9_ = param1.getChildAt(_loc8_) as Loader;
                  if(_loc9_.tabIndex > param3)
                  {
                     _loc6_ = _loc8_;
                     break;
                  }
               }
               _loc8_++;
            }
            param1.addChild(this.loader);
            this.loader.visible = false;
            if(_loc6_ != -1)
            {
               param1.setChildIndex(this.loader,_loc6_);
            }
            this.gameAPI = param2;
            this.elementName = param4;
         }
         this.loader.load(new URLRequest(_loc5_));
      }
      
      public function onLoadingComplete(param1:Event) : * {
         trace("onLoadingComplete " + this.elementName + " this = " + this);
         this.loader.visible = true;
         this.movieClip = this.loader.content as MovieClip;
         this.movieClip["gameAPI"] = this.gameAPI;
         this.movieClip["elementName"] = this.elementName;
         this.gameAPI.OnLoadFinished(this.movieClip,Globals.instance.UISlot);
         this.movieClip.onLoaded();
      }
      
      public function OnLoadProgress(param1:ProgressEvent) : * {
         trace("OnLoadProgress " + this.elementName + " " + param1.bytesLoaded + " / " + param1.bytesTotal);
         this.gameAPI.OnLoadProgress(this.loader.content,param1.bytesLoaded,param1.bytesTotal);
      }
      
      public function onIOError(param1:IOErrorEvent) : * {
         trace("onIOError " + this.elementName);
         this.gameAPI.OnLoadError(this.loader.content,0);
      }
      
      public function Unload() : * {
         var _loc1_:DisplayObjectContainer = this.loader.parent;
         Globals.instance.resizeManager.RemoveListener(this.movieClip);
         if(this.loader.contentLoaderInfo != null)
         {
            this.loader.contentLoaderInfo.removeEventListener(ProgressEvent.PROGRESS,this.OnLoadProgress);
            this.loader.contentLoaderInfo.removeEventListener(Event.COMPLETE,this.onLoadingComplete);
            this.loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR,this.onIOError);
         }
         _loc1_.removeChild(this.loader);
         this.movieClip = null;
         this.loader.unload();
         this.loader = null;
      }
   }
}
