LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := hellolua_shared

LOCAL_MODULE_FILENAME := libhellolua

LOCAL_SRC_FILES := hellolua/main.cpp \
			../../Classes/AppDelegate.cpp\
			../../Classes/cocos2d_ext_tolua.cpp\
			../../Classes/crypto/base64/libb64.c\
			../../Classes/crypto/CCCrypto.cpp\
			../../Classes/crypto/rsa/bigint.c\
			../../Classes/crypto/rsa/rsa.c\
			../../Classes/crypto/sha1/sha1.cpp\
			../../Classes/extend_actions/CCExtendActionInterval.cpp\
			../../Classes/extend_nodes/CaeEffect.cpp\
			../../Classes/extend_nodes/CCExtendLabelTTF.cpp\
			../../Classes/extend_nodes/CCExtendNode.cpp\
			../../Classes/extend_nodes/CCExtendSprite.cpp\
			../../Classes/extend_nodes/CCImageLoader.cpp\
			../../Classes/extend_nodes/CCTextInput.cpp\
			../../Classes/extend_nodes/CCTouchLayer.cpp\
			../../Classes/extend_nodes/Lightning.cpp\
			../../Classes/extend_nodes/Scissor.cpp\
			../../Classes/extend_shader/CCHSVShaderHandler.cpp\
			../../Classes/network/CCHttpRequest.cpp\
			../../Classes/network/CCHttpRequest_impl.cpp\
			../../Classes/platform/android/CCNative.cpp\
			../../Classes/platform/android/CCWebView.cpp\
			../../Classes/platform/android/VideoCamera.cpp\
			../../Classes/ImageUpdate.cpp\
			../../Classes/platform/ComNative.cpp\
			../../Classes/iniReader.cpp\
			../../Classes/AssetsManager.cpp\
			../../Classes/UpdateScene.cpp\
			../../Classes/MyPlugins.cpp


LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../Classes

LOCAL_WHOLE_STATIC_LIBRARIES := cocos2dx_static
LOCAL_WHOLE_STATIC_LIBRARIES += cocosdenshion_static
LOCAL_WHOLE_STATIC_LIBRARIES += cocos_lua_static
LOCAL_WHOLE_STATIC_LIBRARIES += cocos_extension_static
LOCAL_WHOLE_STATIC_LIBRARIES += PluginProtocolStatic

include $(BUILD_SHARED_LIBRARY)

$(call import-module,cocos2dx)
$(call import-module,CocosDenshion/android)
$(call import-module,scripting/lua/proj.android)
$(call import-module,extensions)
$(call import-module,plugin/publish/protocols/android)
