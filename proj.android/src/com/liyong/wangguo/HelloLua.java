/****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
package com.liyong.wangguo;
import java.io.UnsupportedEncodingException;
import java.math.BigDecimal;
import java.util.Date;
import java.util.Timer;
import java.util.TimerTask;
import java.util.UUID;

import net.youmi.android.AdManager;
import net.youmi.android.offers.OffersManager;
import net.youmi.android.offers.PointsChangeNotify;
import net.youmi.android.offers.PointsManager;
import net.youmi.android.spot.SpotManager;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxGLSurfaceView;
import org.cocos2dx.plugin.PluginWrapper;
import org.json.JSONException;


import com.umeng.analytics.MobclickAgent;
import com.umeng.socialize.controller.RequestType;
import com.umeng.socialize.controller.UMServiceFactory;
import com.umeng.socialize.controller.UMSocialService;
import com.umeng.socialize.controller.UMSsoHandler;
import com.umeng.socialize.media.UMImage;
import com.umeng.update.UmengUpdateAgent;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.telephony.TelephonyManager;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.ViewGroup.LayoutParams;
import android.widget.LinearLayout;
import android.provider.Settings.Secure;

public class HelloLua extends Cocos2dxActivity implements PointsChangeNotify{
	LinearLayout layout;
	String appID = "wx883ea78bc363fc31";
	String contentUrl = "http://www.appchina.com/app/com.liyong.wangguo/";
	
	public static final UMSocialService mController = UMServiceFactory.getUMSocialService("com.umeng.share",
            RequestType.SOCIAL);
	
	private HelloLua act;
	private static native void setDeviceId(String deviceId);
	public static native void setPoints(int v);
	
	protected void onCreate(Bundle savedInstanceState){
		super.onCreate(savedInstanceState);
		UmengUpdateAgent.update(this);
		
		act = this;
		PluginWrapper.init(this); // for plugins
		PluginWrapper.setGLSurfaceView(Cocos2dxGLSurfaceView.getInstance());
		final String prefFile = "deviceId.xml";
		SharedPreferences p = this.getSharedPreferences(prefFile, 0);
		String id = p.getString("id", null);
		if (id == null) {
			TelephonyManager tm = (TelephonyManager)this.getSystemService(TELEPHONY_SERVICE);
			String did = tm.getDeviceId();
			String aid = Secure.getString(getContext().getContentResolver(), Secure.ANDROID_ID);
			String uuid = null;
			try {
				uuid = UUID.nameUUIDFromBytes(aid.getBytes("utf8")).toString();
			} catch (UnsupportedEncodingException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			if(did != null) {
				id = did;
			} else if(!"9774d56d682e549c".equals(aid)) {
				id = aid;
			} else {
				id = uuid;
			}
			p.edit().putString("id", id).commit();
		}
		Log.e("deviceId", id);
		setDeviceId(id);
		
		
		//MobclickAgent.setDebugMode(true);
		Log.v("Youmi", "initial You mi");
		AdManager.getInstance(this).init("8039a682e6f38d19", "daa2af09d8664093", false);
		
		/*
		try{
			Log.v("Youmi", "before get points");
			OffersManager.getInstance(this).onAppLaunch();
			PointsManager.getInstance(this).registerNotify(this);
			final int myPoints = PointsManager.getInstance(act).queryPoints();
			Log.v("Youmi", "initial Points "+myPoints);
			PluginWrapper.runOnGLThread(new Runnable(){
				//c++ 通知客户端 加上这些points 用于抵消其它花费 金币
				@Override
				public void run() {
					// TODO Auto-generated method stub
					setPoints(myPoints);
				}
				
			});
	
		} catch(Exception e){
			Log.e("Youmi", "initial points error", e);
		}
		*/
		mController.setShareContent("快来和我一起玩王国危机吧！一起称霸整个大陆！");
		mController.setShareMedia(new UMImage(this, R.drawable.icon));
		mController.getConfig().supportWXPlatform(this, appID, contentUrl);
		mController.getConfig().supportWXCirclePlatform(this, appID, contentUrl) ;
		SpotManager.getInstance(this).loadSpotAds();
		
	}
	
	public void onDestroy() {
		OffersManager.getInstance(this).onAppExit();
		super.onDestroy();
		PointsManager.getInstance(this).unRegisterNotify(this);
	}
	
	@Override
	public Cocos2dxGLSurfaceView onCreateView() {
		return new LuaGLSurfaceView(this);
	}
	@Override
	public void onResume() {
		super.onResume();
		MobclickAgent.onResume(this);
		/*
		try {
			final int myPoints = PointsManager.getInstance(act).queryPoints();
			PluginWrapper.runOnGLThread(new Runnable() {
				@Override
				public void run() {
					// TODO Auto-generated method stub
					Log.v("Youmi", "initial myPoints "+myPoints);
					setPoints(myPoints);
				}
			});
		}catch(Exception e){
			Log.e("Youmi", "resume points error ", e);
		}
		*/
	}
	@Override
	public void onPause() {
		super.onPause();
		MobclickAgent.onPause(this);
	}
	static {
        System.loadLibrary("hellolua");
   }
	@Override
	public void onPointBalanceChange(final int arg0) {
		// TODO Auto-generated method stub
		Log.v("YouMi", "onPointBalanceChange "+arg0);
		PluginWrapper.runOnGLThread(new Runnable(){
			//c++ 通知客户端 加上这些points 用于抵消其它花费 金币
			@Override
			public void run() {
				// TODO Auto-generated method stub
				setPoints(arg0);
			}
			
		});
	}
	@Override 
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		 UMSsoHandler ssoHandler = mController.getConfig().getSsoHandler(requestCode) ;
		 if(ssoHandler != null){
		       ssoHandler.authorizeCallBack(requestCode, resultCode, data);
		 }
	}
}

class LuaGLSurfaceView extends Cocos2dxGLSurfaceView{
	
	public LuaGLSurfaceView(Context context){
		super(context);
	}
	
	public boolean onKeyDown(int keyCode, KeyEvent event) {
    	// exit program when key back is entered
    	if (keyCode == KeyEvent.KEYCODE_BACK) {
            AlertDialog.Builder b;
            try {
    		    b = new AlertDialog.Builder(this.getContext(), AlertDialog.THEME_HOLO_LIGHT);
            } catch (Exception e) {
                Log.e("Alert", "Older Sdk");
    		    b = new AlertDialog.Builder(this.getContext());
            }

    		b.setTitle("关闭游戏")
    		.setMessage("要关闭游戏么?")
    		.setPositiveButton("确定", new DialogInterface.OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int which) {
					// TODO Auto-generated method stub
					android.os.Process.killProcess(android.os.Process.myPid());
				}
			})
			.setNegativeButton("取消", new DialogInterface.OnClickListener() {
				
				@Override
				public void onClick(DialogInterface dialog, int which) {
					// TODO Auto-generated method stub
					dialog.cancel();
				}
			});
    		AlertDialog ad = b.create();
    		ad.show();
    	}
        return super.onKeyDown(keyCode, event);
    }
}
