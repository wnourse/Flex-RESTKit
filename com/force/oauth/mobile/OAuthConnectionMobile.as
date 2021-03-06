package com.force.oauth.mobile
{
	import com.force.oauth.OAuthConnection;
	import com.force.utility.JSON;
	
	import flash.display.Stage;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.LocationChangeEvent;
	import flash.geom.Rectangle;
	import flash.media.StageWebView;
	import flash.net.SharedObject;
	import flash.net.URLVariables;
	
	import mx.rpc.IResponder;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	import mx.utils.ObjectUtil;
	
	
	
	public class OAuthConnectionMobile extends OAuthConnection
	{
		private var oauthView:StageWebView;
		
		public function OAuthConnectionMobile(_publicKey:String, _privateKey:String, _redirectURI:String) {
			super(_publicKey, _privateKey, _redirectURI);
			
		}
		
		public override function login(Stage:flash.display.Stage = null, responder:IResponder = null, refresh:Boolean = false):void {
			this.callback = responder;
			
			if(!refresh && tokenResult != null) {
				trace('Refreshing with: \n '+ObjectUtil.toString(tokenResult));
				if( (Date.parse(new Date()) - tokenResult.issued_at) - 600000) { //token is 10 minutes old, get a new one
					this.refresh();
				} else {
					responder.result(tokenResult);
				}
				
				removeBrowser();
				return;
			}
			
			if(refresh) { 
				this.refresh();
				return;
			}
			
			
			if(Stage == null) { return; }
			
			var rect:Rectangle = new Rectangle(Stage.width/2 - 240,Stage.height/2 - 240,480,480);
			if(this.oauthView == null) {
				this.oauthView = new StageWebView();
				this.oauthView.addEventListener(Event.LOCATION_CHANGE,getToken);
				this.oauthView.addEventListener(ErrorEvent.ERROR,getToken);
				StageWebView(this.oauthView).stage = Stage;
				StageWebView(this.oauthView).viewPort = rect;
			}
			StageWebView(this.oauthView).loadURL(oauthURI+"/services/oauth2/authorize?display=touch&response_type=code&client_id="+publicKey+"&redirect_uri="+redirectURI);
		}
		
		public override function removeBrowser():void {
			if(oauthView != null && oauthView.stage != null) {
				oauthView.stage = null;
			}
		}
		
		protected override function getToken(event:Event):void {
			trace(StageWebView(oauthView).location);
			if(StageWebView(oauthView).location.indexOf("code=") < 0) {
				return;
			}
			
			var requestToken:String = unescape(StageWebView(oauthView).location.substring(StageWebView(oauthView).location.indexOf("code=")+5, StageWebView(oauthView).location.length));
			removeBrowser();			
			
			getAccessToken(requestToken);
			
		}
		
		
	}
}