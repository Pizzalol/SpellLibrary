/**************************************************************************

Filename    :   GameCenterInterface.as

Copyright   :   Copyright 2012 Autodesk, Inc. All Rights reserved.

Use of this software is subject to the terms of the Autodesk license
agreement provided at the time of installation or download, or which
otherwise accompanies this software in either electronic or hard copy form.

**************************************************************************/

package scaleform.clik.utils 
{
    import flash.external.ExternalInterface;
    
    /** 
     * The GameCenterInterface allows users to access Game Center from iOS applications. Be sure to call GameCenterInterface.init() in your AS2 code.
     */
    public class GameCenterInterface 
    {
        // To be overriden by native code FunctionObjects.
        public static var _loginUser:Function;
        public static var _openLeaderboardPane:Function;
        public static var _setLeaderboardScore:Function;
        public static var _openAchievementPane:Function;
        public static var _setAchievementCompletion:Function;
        public static var _resetAchievements:Function;
        public static var _receiveOnlineResult:Function;

        public static function init():void {
            ExternalInterface.call("GameCenterInterface.init", GameCenterInterface);
        }
        
        public static function loginUser():void {
            _loginUser();
        }
        
        public static function openLeaderboardPane():void {
            _openLeaderboardPane();
        }
        
        public static function setLeaderboardScore(id:String, value:Number):void {
            _setLeaderboardScore(id, value);
        }
        
        public static function openAchievementPane():void {
            _openAchievementPane();
        }
        
        public static function setAchievementCompletion(id:String, value:Number):void {
            _setAchievementCompletion(id, value);
        }
        
        public static function resetAchievements():Boolean {
            return _resetAchievements();
        }
        
        public static function receiveOnlineResult():Boolean {
            return _receiveOnlineResult();
        }
    }

}