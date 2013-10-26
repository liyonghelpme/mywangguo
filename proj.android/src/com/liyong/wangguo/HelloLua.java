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

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxGLSurfaceView;
import org.cocos2dx.plugin.PluginWrapper;
import org.json.JSONException;

import com.google.ads.AdRequest;
import com.google.ads.AdSize;
import com.google.ads.AdView;

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

public class HelloLua extends Cocos2dxActivity{
	LinearLayout layout;
	AdView view;
	AdRequest request;
	
	private static native void setDeviceId(String deviceId);
	
	protected void onCreate(Bundle savedInstanceState){
		super.onCreate(savedInstanceState);
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
		setDeviceId(id);
	}
	
	public void onDestroy() {
		super.onDestroy();
	}
	
	@Override
	public Cocos2dxGLSurfaceView onCreateView() {
		return new LuaGLSurfaceView(this);
	}
	
	static {
        System.loadLibrary("hellolua");
   }
}

class LuaGLSurfaceView extends Cocos2dxGLSurfaceView{
	
	public LuaGLSurfaceView(Context context){
		super(context);
	}
	
	public boolean onKeyDown(int keyCode, KeyEvent event) {
    	// exit program when key back is entered
    	if (keyCode == KeyEvent.KEYCODE_BACK) {
    		AlertDialog.Builder b = new AlertDialog.Builder(this.getContext(), AlertDialog.THEME_HOLO_LIGHT);
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
