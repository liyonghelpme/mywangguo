/****************************************************************************
Copyright (c) 2012-2013 cocos2d-x.org

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
package org.cocos2dx.plugin;

import java.util.HashSet;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.Set;

import net.youmi.android.banner.AdSize;
import net.youmi.android.banner.AdView;
import net.youmi.android.offers.OffersManager;
import net.youmi.android.offers.PointsManager;

//import com.google.ads.*;
//import com.google.ads.AdRequest.ErrorCode;
import com.liyong.wangguo.HelloLua;

import android.app.Activity;
import android.content.Context;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.WindowManager;
import android.widget.FrameLayout;
import android.widget.LinearLayout;
import android.widget.LinearLayout.LayoutParams;


public class AdsAdmob implements InterfaceAds {

	private static final String LOG_TAG = "AdsAdmob";
	private static Activity mContext = null;
	private static boolean bDebug = false;
	private static AdsAdmob mAdapter = null;

	private AdView adView = null;
	private String mPublishID = "";
	private Set<String> mTestDevices = null;
	private WindowManager mWm = null;
	private String muid = "";
	private FrameLayout ll;
	private static final int ADMOB_SIZE_BANNER = 0;
	private static final int ADMOB_SIZE_IABMRect = 1;
	private static final int ADMOB_SIZE_IABBanner = 2;
	private static final int ADMOB_SIZE_IABLeaderboard = 3;

	protected static void LogE(String msg, Exception e) {
		Log.e(LOG_TAG, msg, e);
		e.printStackTrace();
	}

	protected static void LogD(String msg) {
		if (bDebug) {
			Log.d(LOG_TAG, msg);
		}
	}

	public AdsAdmob(Context context) {
		mContext = (Activity) context;
		mAdapter = this;
		LogD("Init AdsAdmob");
	}

	@Override
	public void setDebugMode(boolean debug) {
		bDebug = debug;
	}

	@Override
	public String getSDKVersion() {
		return "6.3.1";
	}

	@Override
	public void configDeveloperInfo(Hashtable<String, String> devInfo) {
		Log.e("AdsMob", "config Ads "+devInfo);
		String cmd = devInfo.get("cmd");
		if(cmd != null) {
			if(cmd == "spendGold") {
				final String gold = devInfo.get("gold");
				PluginWrapper.runOnMainThread(new Runnable(){
					@Override
					public void run() {
						// TODO Auto-generated method stub
						PointsManager.getInstance(mContext).spendPoints(Integer.valueOf(gold));
					}
					
				});
			} else if(cmd == "initGold") {
				
			}
		} else {
				String temp = devInfo.get("AdmobID");
				if(temp != null) {
					mPublishID = temp; 
					LogD("init AppInfo : " + mPublishID);
				}
			
			
				muid = devInfo.get("uid");
				if(muid != null) {
					PluginWrapper.runOnMainThread(new Runnable() {
						@Override
						public void run() {
							OffersManager.getInstance(mContext).setCustomUserId(muid);
						}
					});
				}
			LogD("youmi uid is "+muid);
		}
	}

	@Override
	public void showAds(int adsType, int sizeEnum, int pos) {
		Log.e("AdsMob", "showAds");
		showBannerAd(sizeEnum, pos);
	}

	//显示有米的积分墙广告
	@Override
	public void spendPoints(int points) {
		// do nothing, Admob don't have this function
		if(points == 2) {
			
			PluginWrapper.runOnMainThread(new Runnable(){

				@Override
				public void run() {
					// TODO Auto-generated method stub
					OffersManager.getInstance(mContext).showOffersWall();
					try{
						final int myPoints = PointsManager.getInstance(mContext).queryPoints();
						PluginWrapper.runOnGLThread(new Runnable(){
							@Override
							public void run() {
								// TODO Auto-generated method stub
								Log.v("Youmi", "set myPoints "+myPoints);
								HelloLua.setPoints(myPoints);
							}
						});
					}catch(Exception e) {
						Log.e("Youmi", "showoffer get points ", e);
					}
				}
				
			});
		} else if(points == 3) {
			
		}
	}

	@Override
	public void hideAds(int adsType) {
		Log.e("AdsMob", "hide Ads");
		hideBannerAd();
	}

	private void showBannerAd(int sizeEnum, int pos) {
		//final int curPos = pos;
		//final int curSize = sizeEnum;
		final int curPos = pos;
		final int curSize = AdsAdmob.ADMOB_SIZE_BANNER;
		PluginWrapper.runOnMainThread(new Runnable() {

			@Override
			public void run() {
				// TODO Auto-generated method stub
				if(null != adView){
					//adView.setVisibility(View.VISIBLE);
					ll.setVisibility(View.VISIBLE);
					return;
				}
				adView = new AdView(mContext, AdSize.FIT_SCREEN);
				FrameLayout fl = (FrameLayout) mContext.findViewById(android.R.id.content);
				FrameLayout.LayoutParams layoutParams = new FrameLayout.LayoutParams(
				        FrameLayout.LayoutParams.WRAP_CONTENT,
				        FrameLayout.LayoutParams.WRAP_CONTENT);  
				layoutParams.gravity = Gravity.TOP | Gravity.CENTER_HORIZONTAL;
				ll = new FrameLayout(mContext);
				FrameLayout.LayoutParams lp = new FrameLayout.LayoutParams(
						FrameLayout.LayoutParams.FILL_PARENT,
						FrameLayout.LayoutParams.FILL_PARENT);
				fl.addView(ll, lp);;
				ll.addView(adView, layoutParams);
				//fl.addView(adView, layoutParams);
			}
			
		});
	}

	private void hideBannerAd() {
		PluginWrapper.runOnMainThread(new Runnable() {
			@Override
			public void run() {
				if (null != adView) {
					Log.v("Youmi", "hideAds");
					ll.setVisibility(View.INVISIBLE);
				}
			}
		});
	}

	public void addTestDevice(String deviceID) {
		LogD("addTestDevice invoked : " + deviceID);
		if (null == mTestDevices) {
			mTestDevices = new HashSet<String>();
		}
		mTestDevices.add(deviceID);
	}
	/*
	private class AdmobAdsListener implements AdListener {
		
		@Override
		public void onDismissScreen(Ad arg0) {
			LogD("onDismissScreen invoked");
			return;
			//AdsWrapper.onAdsResult(mAdapter, AdsWrapper.RESULT_CODE_FullScreenViewDismissed, "Full screen ads view dismissed!");
		}

		@Override
		public void onFailedToReceiveAd(Ad arg0, ErrorCode arg1) {
			return;
			
			int errorNo = AdsWrapper.RESULT_CODE_UnknownError;
			String errorMsg = "Unknow error";
			switch (arg1) {
			case NETWORK_ERROR:
				errorNo =  AdsWrapper.RESULT_CODE_NetworkError;
				errorMsg = "Network error";
				break;
			case INVALID_REQUEST:
				errorNo = AdsWrapper.RESULT_CODE_NetworkError;
				errorMsg = "The ad request is invalid";
				break;
			case NO_FILL:
				errorMsg = "The ad request is successful, but no ad was returned due to lack of ad inventory.";
				break;
			default:
				break;
			}
			LogD("failed to receive ad : " + errorNo + " , " + errorMsg);
			AdsWrapper.onAdsResult(mAdapter, errorNo, errorMsg);
			
		}

		@Override
		public void onLeaveApplication(Ad arg0) {
			LogD("onLeaveApplication invoked");
		}

		@Override
		public void onPresentScreen(Ad arg0) {
			LogD("onPresentScreen invoked");
			//AdsWrapper.onAdsResult(mAdapter, AdsWrapper.RESULT_CODE_FullScreenViewShown, "Full screen ads view shown!");
		}

		@Override
		public void onReceiveAd(Ad arg0) {
			LogD("onReceiveAd invoked");
			//AdsWrapper.onAdsResult(mAdapter, AdsWrapper.RESULT_CODE_AdsReceived, "Ads request received success!");
		}
	}
	*/
	@Override
	public String getPluginVersion() {
		return "0.2.0";
	}
}
