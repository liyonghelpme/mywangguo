package org.cocos2dx.plugin;

import java.math.BigDecimal;
import java.util.Hashtable;

import org.json.JSONException;

import com.umeng.analytics.MobclickAgent;

import android.app.Activity;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.util.Log;



public class CommonCmd implements InterfaceAds {
	private static Activity mContext;
	private String CLIENT_ID = null;
	private String RECEIVER_EMAIL = null;
	private boolean debug=true;
	private static Intent intent = null;
	private static CommonCmd mAdapter = null;
	private Hashtable<String, String> productTable;
	
	//HelloLua Activity
	public CommonCmd(Context context) {
		mContext = (Activity) context;
		//mAdapter = this;
		//Log.d("CommonCmd", "init plugin command");
	}

	
	
	@Override
	public void setDebugMode(boolean arg0) {
		debug = arg0;
	}

	@Override
	public String getPluginVersion() {
		return "1.0";
	}



	@Override
	public void configDeveloperInfo(Hashtable<String, String> devInfo) {
		// TODO Auto-generated method stub
		
	}



	@Override
	public void showAds(int type, int sizeEnum, int pos) {
		// TODO Auto-generated method stub
		
	}



	@Override
	public void hideAds(int type) {
		// TODO Auto-generated method stub
		
	}



	@Override
	public void spendPoints(int points) {
		// TODO Auto-generated method stub
		if(points == 7) {
			Log.d("Interface", "log url");
			MobclickAgent.onEvent(mContext, "NOZOMI_DOWNLOAD");
		}
	}



	@Override
	public String getSDKVersion() {
		// TODO Auto-generated method stub
		return null;
	}
}
