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
package org.cocos2dx.hellolua;
import java.math.BigDecimal;
import java.util.Date;
import java.util.Timer;
import java.util.TimerTask;

import org.cocos2dx.lib.Cocos2dxActivity;
import org.cocos2dx.lib.Cocos2dxGLSurfaceView;
import org.cocos2dx.lib.Cocos2dxMy;
import org.cocos2dx.plugin.PluginWrapper;
import org.json.JSONException;

import com.umeng.analytics.MobclickAgent;
import com.umeng.update.UmengUpdateAgent;


import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.util.Log;
import android.view.KeyEvent;
import android.view.View;
import android.view.ViewGroup.LayoutParams;
import android.widget.LinearLayout;

public class HelloLua extends Cocos2dxActivity{
	LinearLayout layout;
	public static Activity act;

	protected void onCreate(Bundle savedInstanceState){
		super.onCreate(savedInstanceState);
		PluginWrapper.init(this);
		PluginWrapper.setGLSurfaceView(Cocos2dxGLSurfaceView.getInstance());
		
		UmengUpdateAgent.update(this);
		act = this;
		Cocos2dxMy.act = this;
	}
	public void onResume(){
		super.onResume();
		MobclickAgent.onResume(this);
	}
	public void onPause(){
		super.onPause();
		MobclickAgent.onPause(this);
	}
	public void onDestroy() {
		super.onDestroy();
	}
	
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		
	}
	
	
	public Cocos2dxGLSurfaceView onCreateGLSurfaceView() {
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
    		android.os.Process.killProcess(android.os.Process.myPid());
    	}
        return super.onKeyDown(keyCode, event);
    }
}
