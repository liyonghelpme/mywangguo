#include "cocos2d_ext_tolua.h"
#include "tolua_fix.h"

#include "cocos2d.h"
#include "CCLuaEngine.h"
#include "cocos2d_ext.h"

using namespace cocos2d;
using namespace cocos2d::extension;

/* method: convert a CCNode to CCSprite */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_convertToSprite00
static int tolua_Cocos2d_convertToSprite00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if(
	 !tolua_isusertype(tolua_S,1,"CCNode",0,&tolua_err)||
	 !tolua_isnoobj(tolua_S,2,&tolua_err)
	 )
  goto tolua_lerror;
 else
#endif
 {
	CCNode* node = (CCNode*)tolua_tousertype(tolua_S,1,0);
	CCSprite* tolua_ret = (CCSprite*) node;
    int nID = (tolua_ret) ? tolua_ret->m_uID : -1;
    int* pLuaID = (tolua_ret) ? &tolua_ret->m_nLuaID : NULL;
    toluafix_pushusertype_ccobject(tolua_S, nID, pLuaID, (void*)tolua_ret,"CCSprite");
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'create'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: create of class CCExtendNode */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCExtendNode_create00
static int tolua_Cocos2d_CCExtendNode_create00(lua_State* tolua_S)
{
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"CCExtendNode",0,&tolua_err) ||
     !tolua_isusertype(tolua_S,2,"const CCSize",0,&tolua_err) ||
     !tolua_isboolean(tolua_S,3,1,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
 {
  const CCSize* size = ((const CCSize*)  tolua_tousertype(tolua_S,2,0));
  bool clip = ((bool) tolua_toboolean(tolua_S,3,false));
  {
   CCExtendNode* tolua_ret = (CCExtendNode*)  CCExtendNode::create(*size, clip);
    int nID = (tolua_ret) ? tolua_ret->m_uID : -1;
    int* pLuaID = (tolua_ret) ? &tolua_ret->m_nLuaID : NULL;
    toluafix_pushusertype_ccobject(tolua_S, nID, pLuaID, (void*)tolua_ret,"CCExtendNode");
  }
 }
 return 1;
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'create'.",&tolua_err);
 return 0;
}
#endif //#ifndef TOLUA_DISABLE

/* method: set the hue offset of CCExtendNode*/
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCExtendNode_setHueOffset00
static int tolua_Cocos2d_CCExtendNode_setHueOffset00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCExtendNode",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isboolean(tolua_S,3,1,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCExtendNode* self = (CCExtendNode*)tolua_tousertype(tolua_S,1,0);
  int offset = ((int) tolua_tonumber(tolua_S,2,0));
  bool recur = ((bool) tolua_toboolean(tolua_S,3,true));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setHueOffset'", NULL);
#endif
  {
	  self->setHueOffset(offset, recur);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setHueOffset'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: set the hue offset of CCExtendNode*/
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCExtendNode_setSatOffset00
static int tolua_Cocos2d_CCExtendNode_setSatOffset00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCExtendNode",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isboolean(tolua_S,3,1,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCExtendNode* self = (CCExtendNode*)tolua_tousertype(tolua_S,1,0);
  int offset = ((int) tolua_tonumber(tolua_S,2,0));
  bool recur = ((bool) tolua_toboolean(tolua_S,3,true));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setSatOffset'", NULL);
#endif
  {
	  self->setSatOffset(offset, recur);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setSatOffset'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: set the hue offset of CCExtendNode*/
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCExtendNode_setValOffset00
static int tolua_Cocos2d_CCExtendNode_setValOffset00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCExtendNode",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isboolean(tolua_S,3,1,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCExtendNode* self = (CCExtendNode*)tolua_tousertype(tolua_S,1,0);
  int offset = ((int) tolua_tonumber(tolua_S,2,0));
  bool recur = ((bool) tolua_toboolean(tolua_S,3,true));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setValOffset'", NULL);
#endif
  {
	  self->setValOffset(offset, recur);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setValOffset'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: static function to recur set color */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCExtendSprite_recurSetColor00
static int tolua_Cocos2d_CCExtendSprite_recurSetColor00(lua_State* tolua_S)
{
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"CCExtendSprite",0,&tolua_err) ||
     !tolua_isusertype(tolua_S,2,"CCNode",0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,3,&tolua_err) || !tolua_isusertype(tolua_S,3,"ccColor3B",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
 {
  CCNode* node = ((CCNode*) tolua_tousertype(tolua_S,2,0));
  ccColor3B color3 = *((ccColor3B*)  tolua_tousertype(tolua_S,3,0));
  {
   CCExtendSprite::recurSetColor(node, color3);
  }
 }
 return 0;
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'recurSetColor'.",&tolua_err);
 return 0;
}
#endif //#ifndef TOLUA_DISABLE

/* method: static function to recur set gray */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCExtendSprite_recurSetGray00
static int tolua_Cocos2d_CCExtendSprite_recurSetGray00(lua_State* tolua_S)
{
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"CCExtendSprite",0,&tolua_err) ||
     !tolua_isusertype(tolua_S,2,"CCNode",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
 {
  CCNode* node = ((CCNode*) tolua_tousertype(tolua_S,2,0));;
  {
   CCExtendSprite::recurSetGray(node);
  }
 }
 return 0;
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'recurSetGray'.",&tolua_err);
 return 0;
}
#endif //#ifndef TOLUA_DISABLE

/* method: create of class CCExtendSprite */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCExtendSprite_create00
static int tolua_Cocos2d_CCExtendSprite_create00(lua_State* tolua_S)
{
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"CCExtendSprite",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
 {
  const char* pszFileName = ((const char*)  tolua_tostring(tolua_S,2,0));
  {
   CCExtendSprite* tolua_ret = (CCExtendSprite*)  CCExtendSprite::create(pszFileName);
    int nID = (tolua_ret) ? tolua_ret->m_uID : -1;
    int* pLuaID = (tolua_ret) ? &tolua_ret->m_nLuaID : NULL;
    toluafix_pushusertype_ccobject(tolua_S, nID, pLuaID, (void*)tolua_ret,"CCExtendSprite");
  }
 }
 return 1;
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'create'.",&tolua_err);
 return 0;
}
#endif //#ifndef TOLUA_DISABLE


/* method: createWithSpriteFrameName of class CCExtendSprite */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCExtendSprite_createWithSpriteFrameName00
static int tolua_Cocos2d_CCExtendSprite_createWithSpriteFrameName00(lua_State* tolua_S)
{
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"CCExtendSprite",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
 {
  const char* frameName = ((const char*)  tolua_tostring(tolua_S,2,0));
  {
   CCExtendSprite* tolua_ret = (CCExtendSprite*)  CCExtendSprite::createWithSpriteFrameName(frameName);
    int nID = (tolua_ret) ? tolua_ret->m_uID : -1;
    int* pLuaID = (tolua_ret) ? &tolua_ret->m_nLuaID : NULL;
    toluafix_pushusertype_ccobject(tolua_S, nID, pLuaID, (void*)tolua_ret,"CCExtendSprite");
  }
 }
 return 1;
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'createWithSpriteFrameName'.",&tolua_err);
 return 0;
}
#endif //#ifndef TOLUA_DISABLE

/* method: check if the touch of CCExtendSprite is alpha*/
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCExtendSprite_isAlphaTouched00
static int tolua_Cocos2d_CCExtendSprite_isAlphaTouched00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCExtendSprite",0,&tolua_err) ||
     !tolua_isusertype(tolua_S,2,"CCPoint",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCExtendSprite* self = (CCExtendSprite*)  tolua_tousertype(tolua_S,1,0);
  CCPoint nodePoint = *((CCPoint*)  tolua_tousertype(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'isAlphaTouched'", NULL);
#endif
  {
   bool tolua_ret = (bool)  self->isAlphaTouched(nodePoint);
   tolua_pushboolean(tolua_S, (bool)tolua_ret);
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'isAlphaTouched'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: set the hue offset of CCExtendSprite*/
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCExtendSprite_setHueOffset00
static int tolua_Cocos2d_CCExtendSprite_setHueOffset00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCExtendSprite",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isboolean(tolua_S,3,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCExtendSprite* self = (CCExtendSprite*)  tolua_tousertype(tolua_S,1,0);
  int offset = ((int) tolua_tonumber(tolua_S,2,0));
  bool recur = ((bool) tolua_toboolean(tolua_S,3,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setHueOffset'", NULL);
#endif
  {
	  self->setHueOffset(offset, recur);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setHueOffset'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: set the stroke of CCExtendLabelTTF*/
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCExtendLabelTTF_setStroke00
static int tolua_Cocos2d_CCExtendLabelTTF_setStroke00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCExtendLabelTTF",0,&tolua_err) ||
     !tolua_isboolean(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  CCExtendLabelTTF* self = (CCExtendLabelTTF*)  tolua_tousertype(tolua_S,1,0);
  bool isStroke = ((bool) tolua_toboolean(tolua_S,2,0));
#ifndef TOLUA_RELEASE
  if (!self) tolua_error(tolua_S,"invalid 'self' in function 'setStroke'", NULL);
#endif
  {
	  self->setStroke(isStroke);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setStroke'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: create of class CCExtendLabelTTF */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCExtendLabelTTF_create00
static int tolua_Cocos2d_CCExtendLabelTTF_create00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"CCExtendLabelTTF",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,4,0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,5,&tolua_err) || !tolua_isusertype(tolua_S,5,"const CCSize",0,&tolua_err)) ||
     !tolua_isnumber(tolua_S,6,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,7,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,8,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,9,&tolua_err)
 )
  goto tolua_lerror;
 else
#endif
 {
  const char* str = ((const char*)  tolua_tostring(tolua_S,2,0));
  const char* fontName = ((const char*)  tolua_tostring(tolua_S,3,0));
  float fontSize = ((float)  tolua_tonumber(tolua_S,4,0));
  const CCSize* dimensions = ((const CCSize*)  tolua_tousertype(tolua_S,5,0));
  CCTextAlignment hAlignment = ((CCTextAlignment) (int)  tolua_tonumber(tolua_S,6,0));
  CCVerticalTextAlignment vAlignment = ((CCVerticalTextAlignment) (int)  tolua_tonumber(tolua_S,7,0));
  float stroke = (float)tolua_tonumber(tolua_S,8,0);
  {
   CCExtendLabelTTF* tolua_ret = (CCExtendLabelTTF*)  CCExtendLabelTTF::create(str,fontName,fontSize,*dimensions,hAlignment,vAlignment,stroke);
    int nID = (tolua_ret) ? (int)tolua_ret->m_uID : -1;
    int* pLuaID = (tolua_ret) ? &tolua_ret->m_nLuaID : NULL;
    toluafix_pushusertype_ccobject(tolua_S, nID, pLuaID, (void*)tolua_ret,"CCLabelTTF");
  }
 }
 return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'create'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: create of class CCTextInput */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCTextInput_create00
static int tolua_Cocos2d_CCTextInput_create00(lua_State* tolua_S)
{
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"CCTextInput",0,&tolua_err) ||
     !tolua_isstring(tolua_S,2,0,&tolua_err) ||
     !tolua_isstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,4,0,&tolua_err) ||
     !tolua_isusertype(tolua_S,5,"const CCSize",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,6,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,7,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,8,&tolua_err)
 )
  goto tolua_lerror;
 else
 {
  const char* placeHolder = ((const char*)  tolua_tostring(tolua_S,2,0));
  const char* fontName = ((const char*)  tolua_tostring(tolua_S,3,0));
  float fontSize = (( float)  tolua_tonumber(tolua_S,4,0));
  const CCSize* size = ((const CCSize*)  tolua_tousertype(tolua_S,5,0));
  int align = ((unsigned int)  tolua_tonumber(tolua_S,6,0));
  unsigned int limit = ((unsigned int)  tolua_tonumber(tolua_S,7,0));
  {
	  CCLabelTTF* label = CCLabelTTF::create("", fontName, fontSize);
   CCTextInput* tolua_ret = (CCTextInput*)  CCTextInput::create(placeHolder, label, *size, align, limit);
    int nID = (tolua_ret) ? tolua_ret->m_uID : -1;
    int* pLuaID = (tolua_ret) ? &tolua_ret->m_nLuaID : NULL;
    toluafix_pushusertype_ccobject(tolua_S, nID, pLuaID, (void*)tolua_ret,"CCTextInput");
  }
 }
 return 1;
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'create'.",&tolua_err);
 return 0;
}
#endif //#ifndef TOLUA_DISABLE

/* method: setTouchPriority of class CCTextInput */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCTextInput_setTouchPriority00
static int tolua_Cocos2d_CCTextInput_setTouchPriority00(lua_State* tolua_S)
{
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCTextInput",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
 {
	CCTextInput* self = (CCTextInput*) tolua_tousertype(tolua_S,1,0);
	int pri = ((int) tolua_tonumber(tolua_S,2,0));
  {
	  self->setTouchPriority(pri);
  }
 }
 return 0;
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setTouchPriority'.",&tolua_err);
 return 0;
}
#endif //#ifndef TOLUA_DISABLE

/* method: setColor of class CCTextInput */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCTextInput_setColor00
static int tolua_Cocos2d_CCTextInput_setColor00(lua_State* tolua_S)
{
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCTextInput",0,&tolua_err) ||
     (tolua_isvaluenil(tolua_S,2,&tolua_err) || !tolua_isusertype(tolua_S,2,"ccColor3B",0,&tolua_err)) ||
     !tolua_isnoobj(tolua_S,3,&tolua_err)
 )
  goto tolua_lerror;
 else
 {
	CCTextInput* self = (CCTextInput*) tolua_tousertype(tolua_S,1,0);
	ccColor3B color3 = *((ccColor3B*)  tolua_tousertype(tolua_S,2,0));
  {
	  self->setColor(color3);
  }
 }
 return 0;
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setColor'.",&tolua_err);
 return 0;
}
#endif //#ifndef TOLUA_DISABLE

/* method: getString of class CCTextInput */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCTextInput_getString00
static int tolua_Cocos2d_CCTextInput_getString00(lua_State* tolua_S)
{
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCTextInput",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
 {
	CCTextInput* self = (CCTextInput*) tolua_tousertype(tolua_S,1,0);
  {
	const char* tolua_ret = self->getString();
	tolua_pushstring(tolua_S, (const char*)tolua_ret);
  }
 }
 return 1;
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getString'.",&tolua_err);
 return 0;
}
#endif //#ifndef TOLUA_DISABLE

/* method: clearString of class CCTextInput */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCTextInput_clearString00
static int tolua_Cocos2d_CCTextInput_clearString00(lua_State* tolua_S)
{
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCTextInput",0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,2,&tolua_err)
 )
  goto tolua_lerror;
 else
 {
	CCTextInput* self = (CCTextInput*) tolua_tousertype(tolua_S,1,0);
  {
	  self->setString("");
	  self->closeIME();
  }
 }
 return 0;
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setTouchPriority'.",&tolua_err);
 return 0;
}
#endif //#ifndef TOLUA_DISABLE

/* method: addImage of class CCImageLoader */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCImageLoader_addImage00
static int tolua_Cocos2d_CCImageLoader_addImage00(lua_State* tolua_S)
{
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCImageLoader",0,&tolua_err) ||
	 !tolua_isstring(tolua_S,2,0,&tolua_err) ||
	 !tolua_isstring(tolua_S,3,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,4,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,5,&tolua_err)
 )
  goto tolua_lerror;
 else
 {
	CCImageLoader* self = (CCImageLoader*) tolua_tousertype(tolua_S,1,0);
	const char* imageFile = (const char*) tolua_tostring(tolua_S,2,0);
	const char* plistFile = (const char*) tolua_tostring(tolua_S,3,0);
	CCTexture2DPixelFormat format = ((CCTexture2DPixelFormat) (int)  tolua_tonumber(tolua_S,4,0));
  {
	  self->addImage(imageFile, plistFile, format);
  }
 }
 return 0;
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'addImage'.",&tolua_err);
 return 0;
}
#endif //#ifndef TOLUA_DISABLE

/* method: create of class CCImageLoader */
#ifndef TOLUA_DISABLE_tolua_Cococs2d_CCImageLoader_create00
static int tolua_Cocos2d_CCImageLoader_create00(lua_State* tolua_S)
{
	tolua_Error tolua_err;
	if (
		!tolua_isusertable(tolua_S,1,"CCImageLoader",0,&tolua_err) ||
		!tolua_isnoobj(tolua_S,2,&tolua_err)
	)
	goto tolua_lerror;
	else
	{
		{
			CCImageLoader* tolua_ret = (CCImageLoader*)  CCImageLoader::create();
			int nID = (tolua_ret) ? tolua_ret->m_uID : -1;
			int* pLuaID = (tolua_ret) ? &tolua_ret->m_nLuaID : NULL;
			toluafix_pushusertype_ccobject(tolua_S, nID, pLuaID, (void*)tolua_ret,"CCImageLoader");
		}
	}
	return 1;
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'create'.",&tolua_err);
 return 0;
}
#endif //#ifndef TOLUA_DISABLE

/* method: registerScriptTouchHandler of class CCTouchLayer */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCTouchLayer_registerScriptTouchHandler00
static int tolua_Cocos2d_CCTouchLayer_registerScriptTouchHandler00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
 tolua_Error tolua_err;
 if (
     !tolua_isusertype(tolua_S,1,"CCTouchLayer",0,&tolua_err) ||
	 (tolua_isvaluenil(tolua_S,2,&tolua_err) || !toluafix_isfunction(tolua_S,2,"LUA_FUNCTION",0,&tolua_err)) ||
	 !tolua_isnoobj(tolua_S,3,&tolua_err)
    )
    goto tolua_lerror;
else
#endif
 {
	CCTouchLayer* self = (CCTouchLayer*) tolua_tousertype(tolua_S,1,0);
	LUA_FUNCTION funcID = (toluafix_ref_function(tolua_S,2,0));
  {
	  self->registerScriptTouchHandler(funcID);
  }
 }
 return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'registerScriptTouchHandler'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: create of class CCTouchLayer */
#ifndef TOLUA_DISABLE_tolua_Cococs2d_CCTouchLayer_create00
static int tolua_Cocos2d_CCTouchLayer_create00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertable(tolua_S,1,"CCTouchLayer",0,&tolua_err) ||
		!tolua_isnumber(tolua_S,2,0,&tolua_err) ||
		!tolua_isboolean(tolua_S,3,0,&tolua_err) ||
		!tolua_isnoobj(tolua_S,4,&tolua_err)
	)
	goto tolua_lerror;
	else
#endif
	{
		int priority = ((int)tolua_tonumber(tolua_S,2,0));
		bool hold = ((bool)tolua_toboolean(tolua_S,3,false));
		{
			CCTouchLayer* tolua_ret = (CCTouchLayer*)  CCTouchLayer::create(priority, hold);
			int nID = (tolua_ret) ? tolua_ret->m_uID : -1;
			int* pLuaID = (tolua_ret) ? &tolua_ret->m_nLuaID : NULL;
			toluafix_pushusertype_ccobject(tolua_S, nID, pLuaID, (void*)tolua_ret,"CCTouchLayer");
		}
	}
	return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'create'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: create of class Lightning */
#ifndef TOLUA_DISABLE_tolua_Cococs2d_Lightning_create00
static int tolua_Cocos2d_Lignting_create00(lua_State* tolua_S)
{
	tolua_Error tolua_err;
	if (
		!tolua_isusertable(tolua_S,1,"Lightning",0,&tolua_err) ||
		!tolua_isstring(tolua_S,2,0,&tolua_err) ||
		!tolua_isnumber(tolua_S,3,0,&tolua_err) ||
		!tolua_isnumber(tolua_S,4,0,&tolua_err) ||
		!tolua_isnumber(tolua_S,5,0,&tolua_err) ||
		!tolua_isnumber(tolua_S,6,0,&tolua_err) ||
		!tolua_isnoobj(tolua_S,7,&tolua_err)
	)
	goto tolua_lerror;
	else
	{
		int capacity = ((int) tolua_tonumber(tolua_S,3,0));
		float detail = ((float) tolua_tonumber(tolua_S,4,0));
		float thickness = ((float) tolua_tonumber(tolua_S,5,0));
		float displace = ((float) tolua_tonumber(tolua_S,6,0));
		{
			Lightning* tolua_ret = (Lightning*)  Lightning::create(NULL, capacity, detail, thickness, displace);
			int nID = (tolua_ret) ? tolua_ret->m_uID : -1;
			int* pLuaID = (tolua_ret) ? &tolua_ret->m_nLuaID : NULL;
			toluafix_pushusertype_ccobject(tolua_S, nID, pLuaID, (void*)tolua_ret,"Lightning");
		}
	}
	return 1;
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'create'.",&tolua_err);
 return 0;
}
#endif //#ifndef TOLUA_DISABLE

/* method: midDisplacement of class Lightning */
#ifndef TOLUA_DISABLE_tolua_Cococs2d_Lightning_midDisplacement00
static int tolua_Cocos2d_Lignting_midDisplacement00(lua_State* tolua_S)
{
	tolua_Error tolua_err;
	if (
		!tolua_isusertype(tolua_S,1,"Lightning",0,&tolua_err) ||
		!tolua_isnumber(tolua_S,2,0,&tolua_err) ||
		!tolua_isnumber(tolua_S,3,0,&tolua_err) ||
		!tolua_isnumber(tolua_S,4,0,&tolua_err) ||
		!tolua_isnumber(tolua_S,5,0,&tolua_err) ||
		!tolua_isnumber(tolua_S,6,0,&tolua_err) ||
		!tolua_isnoobj(tolua_S,7,&tolua_err)
	)
	goto tolua_lerror;
	else
	{
		Lightning* self = (Lightning*) tolua_tousertype(tolua_S,1,0);
		float x1 = ((float) tolua_tonumber(tolua_S,2,0));
		float y1 = ((float) tolua_tonumber(tolua_S,3,0));
		float x2 = ((float) tolua_tonumber(tolua_S,4,0));
		float y2 = ((float) tolua_tonumber(tolua_S,5,0));
		float displace = ((float) tolua_tonumber(tolua_S,6,0));
		{
			self->midDisplacement(x1, y1, x2, y2, displace);
		}
	}
	return 0;
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'midDisplacement'.",&tolua_err);
 return 0;
}
#endif //#ifndef TOLUA_DISABLE

/* method: setColor of class Lightning */
#ifndef TOLUA_DISABLE_tolua_Cococs2d_Lightning_setColor00
static int tolua_Cocos2d_Lignting_setColor00(lua_State* tolua_S)
{
	tolua_Error tolua_err;
	if (
		!tolua_isusertype(tolua_S,1,"Lightning",0,&tolua_err) ||
		!tolua_isusertype(tolua_S,2,"ccColor3B",0,&tolua_err) ||
		!tolua_isnoobj(tolua_S,3,&tolua_err)
	)
	goto tolua_lerror;
	else
	{
		Lightning* self = (Lightning*) tolua_tousertype(tolua_S,1,0);
		ccColor3B color3 = *((ccColor3B*)  tolua_tousertype(tolua_S,2,0));
		{
			self->setColor(color3);
		}
	}
	return 0;
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setColor'.",&tolua_err);
 return 0;
}
#endif //#ifndef TOLUA_DISABLE

/* method: setFadeOutRate of class Lightning */
#ifndef TOLUA_DISABLE_tolua_Cococs2d_Lightning_setFadeOutRate00
static int tolua_Cocos2d_Lignting_setFadeOutRate00(lua_State* tolua_S)
{
	tolua_Error tolua_err;
	if (
		!tolua_isusertype(tolua_S,1,"Lightning",0,&tolua_err) ||
		!tolua_isnumber(tolua_S,2,0,&tolua_err) ||
		!tolua_isnoobj(tolua_S,3,&tolua_err)
	)
	goto tolua_lerror;
	else
	{
		Lightning* self = (Lightning*) tolua_tousertype(tolua_S,1,0);
		float rate = ((int) tolua_tonumber(tolua_S,2,0));
		{
			self->setFadeOutRate(rate);
		}
	}
	return 0;
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setColor'.",&tolua_err);
 return 0;
}
#endif //#ifndef TOLUA_DISABLE

/* method: create of class CCAlphaTo */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCAlphaTo_create00
static int tolua_Cocos2d_CCAlphaTo_create00(lua_State* tolua_S)
{
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"CCAlphaTo",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,3,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,4,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,5,&tolua_err)
 )
  goto tolua_lerror;
 else
 {
  float duration = ((float)  tolua_tonumber(tolua_S,2,0));
  unsigned char from = (( unsigned char)  tolua_tonumber(tolua_S,3,0));
  unsigned char to = (( unsigned char)  tolua_tonumber(tolua_S,4,0));
  {
   CCAlphaTo* tolua_ret = (CCAlphaTo*)  CCAlphaTo::create(duration, from, to);
    int nID = (tolua_ret) ? tolua_ret->m_uID : -1;
    int* pLuaID = (tolua_ret) ? &tolua_ret->m_nLuaID : NULL;
    toluafix_pushusertype_ccobject(tolua_S, nID, pLuaID, (void*)tolua_ret,"CCAlphaTo");
  }
 }
 return 1;
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'create'.",&tolua_err);
 return 0;
}
#endif //#ifndef TOLUA_DISABLE

/* method: create of class CCNumberTo */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCNumberTo_create00
static int tolua_Cocos2d_CCNumberTo_create00(lua_State* tolua_S)
{
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"CCNumberTo",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,3,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,4,0,&tolua_err) ||
     !tolua_isstring(tolua_S,5,0,&tolua_err) ||
     !tolua_isstring(tolua_S,6,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,7,&tolua_err)
 )
  goto tolua_lerror;
 else
 {
  float duration = ((float)  tolua_tonumber(tolua_S,2,0));
  int from = ((int)  tolua_tonumber(tolua_S,3,0));
  int to = ((int)  tolua_tonumber(tolua_S,4,0));
  const char* prefix = ((const char*) tolua_tostring(tolua_S,5,0));
  const char* suffix = ((const char*) tolua_tostring(tolua_S,6,0));
  {
   CCNumberTo* tolua_ret = (CCNumberTo*)  CCNumberTo::create(duration, from, to, prefix, suffix);
    int nID = (tolua_ret) ? tolua_ret->m_uID : -1;
    int* pLuaID = (tolua_ret) ? &tolua_ret->m_nLuaID : NULL;
    toluafix_pushusertype_ccobject(tolua_S, nID, pLuaID, (void*)tolua_ret,"CCNumberTo");
  }
 }
 return 1;
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'create'.",&tolua_err);
 return 0;
}
#endif //#ifndef TOLUA_DISABLE

/* method: create of class CCShake */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCShake_create00
static int tolua_Cocos2d_CCShake_create00(lua_State* tolua_S)
{
 tolua_Error tolua_err;
 if (
     !tolua_isusertable(tolua_S,1,"CCShake",0,&tolua_err) ||
     !tolua_isnumber(tolua_S,2,0,&tolua_err) ||
     !tolua_isnumber(tolua_S,3,0,&tolua_err) ||
     !tolua_isnoobj(tolua_S,4,&tolua_err)
 )
  goto tolua_lerror;
 else
 {
  float duration = ((float)  tolua_tonumber(tolua_S,2,0));
  float amplitude = ((float)  tolua_tonumber(tolua_S,3,0));
  {
   CCShake* tolua_ret = (CCShake*)  CCShake::create(duration, amplitude);
    int nID = (tolua_ret) ? tolua_ret->m_uID : -1;
    int* pLuaID = (tolua_ret) ? &tolua_ret->m_nLuaID : NULL;
    toluafix_pushusertype_ccobject(tolua_S, nID, pLuaID, (void*)tolua_ret,"CCShake");
  }
 }
 return 1;
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'create'.",&tolua_err);
 return 0;
}
#endif //#ifndef TOLUA_DISABLE

/* method: createHttpRequest of class CCHttpRequest */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCHttpRequest_create00
static int tolua_Cocos2d_CCHttpRequest_create00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertable(tolua_S, 1, "CCHttpRequest", 0, &tolua_err) ||
		(tolua_isvaluenil(tolua_S,2,&tolua_err) || !toluafix_isfunction(tolua_S,2,"LUA_FUNCTION",0,&tolua_err)) ||
		!tolua_isstring(tolua_S,3,0,&tolua_err) ||
		!tolua_isboolean(tolua_S,4,1,&tolua_err) ||
		!tolua_isnoobj(tolua_S,5,&tolua_err)
	)
	 goto tolua_lerror;
	else
#endif
	{
		int funcID = (toluafix_ref_function(tolua_S,2,0));
		const char* url = ((const char*)  tolua_tostring(tolua_S,3,0));
		bool isGet = ((bool)  tolua_toboolean(tolua_S,4,true));
		{
			CCHttpRequest* tolua_ret = (CCHttpRequest *) CCHttpRequest::createWithUrlLua(funcID, url, isGet);
			int nID = (tolua_ret) ? tolua_ret->m_uID : -1;
			int* pLuaID = (tolua_ret) ? &tolua_ret->m_nLuaID : NULL;
			toluafix_pushusertype_ccobject(tolua_S, nID, pLuaID, (void*)tolua_ret,"CCHttpRequest");
		}
	}
	return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'create'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: addPostValue of class CCHttpRequest */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCHttpRequest_addPostValue00
static int tolua_Cocos2d_CCHttpRequest_addPostValue00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if(
		!tolua_isusertype(tolua_S,1,"CCHttpRequest",0,&tolua_err) ||
		!tolua_isstring(tolua_S,2,0,&tolua_err)||
		!tolua_isstring(tolua_S,3,0,&tolua_err) ||
		!tolua_isnoobj(tolua_S,4,&tolua_err)
	)
		goto tolua_lerror;
	else
#endif
	{
		CCHttpRequest* self = (CCHttpRequest*) tolua_tousertype(tolua_S,1,0);
		const char* key = ((const char *) tolua_tostring(tolua_S,2,0));
		const char* value = ((const char *) tolua_tostring(tolua_S,3,0));
		{
			self->addPostValue(key, value);
		}
	}
	return 0;
#ifndef TOLUA_RELEASE
tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'addPostValue'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: setTimeout of class CCHttpRequest */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCHttpRequest_setTimeout00
static int tolua_Cocos2d_CCHttpRequest_setTimeout00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if(
		!tolua_isusertype(tolua_S,1,"CCHttpRequest",0,&tolua_err) ||
		!tolua_isnumber(tolua_S,2,0,&tolua_err) ||
		!tolua_isnoobj(tolua_S,3,&tolua_err)
	)
		goto tolua_lerror;
	else
#endif
	{
		CCHttpRequest* self = (CCHttpRequest*) tolua_tousertype(tolua_S,1,0);
		float timeout = ((float) tolua_tonumber(tolua_S,2,0));
		{
			self->setTimeout(timeout);
		}
	}
	return 0;
#ifndef TOLUA_RELEASE
tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'setTimeout'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: start of class CCHttpRequest */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCHttpRequest_start00
static int tolua_Cocos2d_CCHttpRequest_start00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if(
		!tolua_isusertype(tolua_S,1,"CCHttpRequest",0,&tolua_err) ||
		!tolua_isboolean(tolua_S,2,0,&tolua_err) ||
		!tolua_isnoobj(tolua_S,3,&tolua_err)
	)
		goto tolua_lerror;
	else
#endif
	{
		CCHttpRequest* self = (CCHttpRequest*) tolua_tousertype(tolua_S,1,0);
		bool isCached = ((bool) tolua_toboolean(tolua_S,2,false));
		{
			self->start(isCached);
		}
	}
	return 0;
#ifndef TOLUA_RELEASE
tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'start'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getResponseStatusCode of class CCHttpRequest */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCHttpRequest_getResponseStatusCode00
static int tolua_Cocos2d_CCHttpRequest_getResponseStatusCode00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if(
		!tolua_isusertype(tolua_S,1,"CCHttpRequest",0,&tolua_err) ||
		!tolua_isnoobj(tolua_S,2,&tolua_err)
	)
		goto tolua_lerror;
	else
#endif
	{
		CCHttpRequest* self = (CCHttpRequest*) tolua_tousertype(tolua_S,1,0);
		{
			int tolua_ret = self->getResponseStatusCode();
			tolua_pushnumber(tolua_S, (lua_Number)tolua_ret);
		}
	}
	return 1;
#ifndef TOLUA_RELEASE
tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getResponseStatusCode'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: getResponseString of class CCHttpRequest */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCHttpRequest_getResponseString00
static int tolua_Cocos2d_CCHttpRequest_getResponseString00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if(
		!tolua_isusertype(tolua_S,1,"CCHttpRequest",0,&tolua_err) ||
		!tolua_isnoobj(tolua_S,2,&tolua_err)
	)
		goto tolua_lerror;
	else
#endif
	{
		CCHttpRequest* self = (CCHttpRequest*) tolua_tousertype(tolua_S,1,0);
		{
			const char* tolua_ret = self->getResponseString();
			tolua_pushstring(tolua_S, (const char*)tolua_ret);
		}
	}
	return 1;
#ifndef TOLUA_RELEASE
tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'getResponseString'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: md5encode of class CCCrypto */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCCrypto_md5encode00
static int tolua_Cocos2d_CCCrypto_md5encode00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertable(tolua_S, 1, "CCCrypto", 0, &tolua_err) ||
		!tolua_isstring(tolua_S,2,0,&tolua_err) ||
		!tolua_isnoobj(tolua_S,3,&tolua_err)
	)
	 goto tolua_lerror;
	else
#endif
	{
		const char* src = ((const char*)  tolua_tostring(tolua_S,2,0));
		{
			const char* tolua_ret = CCCrypto::encodeMd5((void *)src, strlen(src));
			tolua_pushstring(tolua_S, (const char*)tolua_ret);
			delete[] tolua_ret;
		}
	}
	return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'md5encode'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: rsaSign of class CCCrypto */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCCrypto_rsaSign00
static int tolua_Cocos2d_CCCrypto_rsaSign00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertable(tolua_S, 1, "CCCrypto", 0, &tolua_err) ||
		!tolua_isstring(tolua_S,2,0,&tolua_err) ||
		!tolua_isstring(tolua_S,3,0,&tolua_err) ||
		!tolua_isnoobj(tolua_S,4,&tolua_err)
	)
	 goto tolua_lerror;
	else
#endif
	{
		const char* src = ((const char*)  tolua_tostring(tolua_S,2,0));
		const char* key = ((const char*)  tolua_tostring(tolua_S,3,0));
		{
			unsigned char* buffer = new unsigned char[1000];
			int len = CCCrypto::rsa_sign_with_private((unsigned char *)src, strlen(src), buffer, 1000, key);
			int verify = CCCrypto::rsa_verify_with_public((unsigned char*)src, strlen(src), buffer, len, "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCui00NhxlT+ijio8JFqWGVjb/mdreR+GeQ+L/ZrEKj9UoOMdNHGaNw7DdniFE1ehdw9WgQr45cwH8VEUofrDJCbKuzqxN5I/lAtrImIQNQUiVYSowVcvg3fndgnOeFpa51l+De+ZF3+rDtPtFiN15AUnxFdnArpyrv2jnnzp2uZwIDAQAB");
			const char* temp = CCCrypto::encodeBase64(buffer, len);
			delete[] buffer;
			const char* tolua_ret = CCCrypto::encodeUrl(temp);
			delete temp;
			tolua_pushstring(tolua_S, (const char*)tolua_ret);
			delete[] tolua_ret;
		}
	}
	return 1;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'md5encode'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: openURL of class CCNative */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCNative_openURL00
static int tolua_Cocos2d_CCNative_openURL00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertable(tolua_S, 1, "CCNative", 0, &tolua_err) ||
		!tolua_isstring(tolua_S,2,0,&tolua_err) ||
		!tolua_isnoobj(tolua_S,3,&tolua_err)
	)
	 goto tolua_lerror;
	else
#endif
	{
		const char* src = ((const char*)  tolua_tostring(tolua_S,2,0));
		{
			CCNative::openURL(src);
		}
	}
	return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'CCNative'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: postNotification of class CCNative */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCNative_postNotification00
static int tolua_Cocos2d_CCNative_postNotification00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertable(tolua_S, 1, "CCNative", 0, &tolua_err) ||
		!tolua_isnumber(tolua_S,2,0,&tolua_err) ||
		!tolua_isstring(tolua_S,3,0,&tolua_err) ||
		!tolua_isnoobj(tolua_S,4,&tolua_err)
	)
	 goto tolua_lerror;
	else
#endif
	{
		int during = ((int) tolua_tonumber(tolua_S,2,0));
		const char* notification = ((const char*)  tolua_tostring(tolua_S,3,0));
		{
			CCNative::postNotification(during, notification);
		}
	}
	return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'CCNative'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: clearLocalNotification of class CCNative */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCNative_clearLocalNotification00
static int tolua_Cocos2d_CCNative_clearLocalNotification00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertable(tolua_S, 1, "CCNative", 0, &tolua_err) ||
		!tolua_isnoobj(tolua_S,2,&tolua_err)
	)
	 goto tolua_lerror;
	else
#endif
	{
		{
			CCNative::clearLocalNotification();
		}
	}
	return 0;
#ifndef TOLUA_RELEASE
 tolua_lerror:
 tolua_error(tolua_S,"#ferror in function 'CCNative'.",&tolua_err);
 return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: create of class CCWebView */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_CCWebView_create00
static int tolua_Cocos2d_CCWebView_create00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertable(tolua_S, 1, "CCWebView", 0, &tolua_err) ||
		!tolua_isstring(tolua_S,2,0,&tolua_err) ||
		(tolua_isvaluenil(tolua_S,3,&tolua_err) || !toluafix_isfunction(tolua_S,3,"LUA_FUNCTION",0,&tolua_err)) ||
		!tolua_isnoobj(tolua_S,4,&tolua_err)
        )
        goto tolua_lerror;
	else
#endif
	{
		const char* url = ((const char*)  tolua_tostring(tolua_S,2,0));
		LUA_FUNCTION funcID = (toluafix_ref_function(tolua_S,3,0));
		{
			CCWebView * tolua_ret = (CCWebView *) CCWebView::create(url, funcID);
			int nID = (tolua_ret) ? tolua_ret->m_uID : -1;
			int* pLuaID = (tolua_ret) ? &tolua_ret->m_nLuaID : NULL;
			toluafix_pushusertype_ccobject(tolua_S, nID, pLuaID, (void*)tolua_ret,"CCWebView");
		}
	}
	return 1;
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'create'.",&tolua_err);
    return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: startRecord of class VideoCamera */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_VideoCamera_startRecord00
static int tolua_Cocos2d_VideoCamera_startRecord00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if(
       !tolua_isusertype(tolua_S,1,"VideoCamera",0,&tolua_err) ||
       !tolua_isusertype(tolua_S,2,"CCNode",0,&tolua_err) ||
       !tolua_isnoobj(tolua_S,3,&tolua_err)
       )
		goto tolua_lerror;
	else
#endif
	{
		VideoCamera* self = (VideoCamera*) tolua_tousertype(tolua_S,1,0);
        CCNode* showNode = (CCNode *)tolua_tousertype(tolua_S,2,0);
		{
			self->startRecord(showNode);
		}
	}
	return 0;
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'startRecord'.",&tolua_err);
    return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: endRecord of class VideoCamera */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_VideoCamera_endRecord00
static int tolua_Cocos2d_VideoCamera_endRecord00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if(
       !tolua_isusertype(tolua_S,1,"VideoCamera",0,&tolua_err) ||
       !tolua_isnoobj(tolua_S,2,&tolua_err)
       )
		goto tolua_lerror;
	else
#endif
	{
		VideoCamera* self = (VideoCamera*) tolua_tousertype(tolua_S,1,0);
		{
			self->endRecord();
		}
	}
	return 0;
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'endRecord'.",&tolua_err);
    return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE

/* method: create of class VideoCamera */
#ifndef TOLUA_DISABLE_tolua_Cocos2d_VideoCamera_create00
static int tolua_Cocos2d_VideoCamera_create00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertable(tolua_S, 1, "VideoCamera", 0, &tolua_err) ||
		!tolua_isnoobj(tolua_S,2,&tolua_err)
        )
        goto tolua_lerror;
	else
#endif
	{
		{
			VideoCamera * tolua_ret = (VideoCamera *) VideoCamera::create();
			int nID = (tolua_ret) ? tolua_ret->m_uID : -1;
			int* pLuaID = (tolua_ret) ? &tolua_ret->m_nLuaID : NULL;
			toluafix_pushusertype_ccobject(tolua_S, nID, pLuaID, (void*)tolua_ret,"VideoCamera");
		}
	}
	return 1;
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'create'.",&tolua_err);
    return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE


#ifndef TOLUA_DISABLE_tolua_Cocos2d_Scissor_create00
static int tolua_Cocos2d_Scissor_create00(lua_State* tolua_S)
{
#ifndef TOLUA_RELEASE
	tolua_Error tolua_err;
	if (
		!tolua_isusertable(tolua_S, 1, "Scissor", 0, &tolua_err) ||
		!tolua_isnoobj(tolua_S,2,&tolua_err)
        )
        goto tolua_lerror;
	else
#endif
	{
		{
			Scissor * tolua_ret = (Scissor *) Scissor::create();
			int nID = (tolua_ret) ? tolua_ret->m_uID : -1;
			int* pLuaID = (tolua_ret) ? &tolua_ret->m_nLuaID : NULL;
			toluafix_pushusertype_ccobject(tolua_S, nID, pLuaID, (void*)tolua_ret,"Scissor");
		}
	}
	return 1;
#ifndef TOLUA_RELEASE
tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'create'.",&tolua_err);
    return 0;
#endif
}
#endif //#ifndef TOLUA_DISABLE


TOLUA_API int tolua_ext_reg_types(lua_State* tolua_S)
{
 tolua_usertype(tolua_S,"CCExtendNode");
 tolua_usertype(tolua_S,"CCExtendSprite");
 tolua_usertype(tolua_S,"CCExtendLabelTTF");
 tolua_usertype(tolua_S,"CCTextInput");
 tolua_usertype(tolua_S,"CCImageLoader");
 tolua_usertype(tolua_S,"CCTouchLayer");
 tolua_usertype(tolua_S,"Lightning");
 tolua_usertype(tolua_S,"CCAlphaTo");
 tolua_usertype(tolua_S,"CCNumberTo");
 tolua_usertype(tolua_S,"CCShake");
 tolua_usertype(tolua_S,"CCHttpRequest");
 tolua_usertype(tolua_S,"CCCrypto");
 tolua_usertype(tolua_S,"CCNative");
 tolua_usertype(tolua_S,"CCWebView");
 tolua_usertype(tolua_S,"VideoCamera");
 tolua_usertype(tolua_S,"Scissor");
 return 1;
}

TOLUA_API int tolua_ext_reg_modules(lua_State* tolua_S)
{
  tolua_function(tolua_S,"convertToSprite", tolua_Cocos2d_convertToSprite00);
  tolua_cclass(tolua_S,"CCExtendNode","CCExtendNode","CCNode",NULL);
  tolua_beginmodule(tolua_S,"CCExtendNode");
   tolua_function(tolua_S, "create", tolua_Cocos2d_CCExtendNode_create00);
   tolua_function(tolua_S, "setHueOffset", tolua_Cocos2d_CCExtendNode_setHueOffset00);
   tolua_function(tolua_S, "setSatOffset", tolua_Cocos2d_CCExtendNode_setSatOffset00);
   tolua_function(tolua_S, "setValOffset", tolua_Cocos2d_CCExtendNode_setValOffset00);
  tolua_endmodule(tolua_S);
  tolua_cclass(tolua_S,"CCExtendSprite","CCExtendSprite","CCSprite",NULL);
  tolua_beginmodule(tolua_S,"CCExtendSprite");
   tolua_function(tolua_S, "isAlphaTouched", tolua_Cocos2d_CCExtendSprite_isAlphaTouched00);
   tolua_function(tolua_S, "recurSetColor", tolua_Cocos2d_CCExtendSprite_recurSetColor00);
   tolua_function(tolua_S, "recurSetGray", tolua_Cocos2d_CCExtendSprite_recurSetGray00);
   tolua_function(tolua_S, "create", tolua_Cocos2d_CCExtendSprite_create00);
   tolua_function(tolua_S, "createWithSpriteFrameName", tolua_Cocos2d_CCExtendSprite_createWithSpriteFrameName00);
   tolua_function(tolua_S, "setHueOffset", tolua_Cocos2d_CCExtendSprite_setHueOffset00);
  tolua_endmodule(tolua_S);
  tolua_cclass(tolua_S,"CCExtendLabelTTF","CCExtendLabelTTF","CCExtendNode",NULL);
  tolua_beginmodule(tolua_S,"CCExtendLabelTTF");
   tolua_function(tolua_S,"setStroke",tolua_Cocos2d_CCExtendLabelTTF_setStroke00);
   tolua_function(tolua_S,"create",tolua_Cocos2d_CCExtendLabelTTF_create00);
  tolua_endmodule(tolua_S);
  tolua_cclass(tolua_S,"CCTextInput", "CCTextInput", "CCTextFieldTTF", NULL);
  tolua_beginmodule(tolua_S, "CCTextInput");
   tolua_function(tolua_S, "create", tolua_Cocos2d_CCTextInput_create00);
   tolua_function(tolua_S, "setTouchPriority", tolua_Cocos2d_CCTextInput_setTouchPriority00);
   tolua_function(tolua_S, "setColor", tolua_Cocos2d_CCTextInput_setColor00);
   tolua_function(tolua_S, "clearString", tolua_Cocos2d_CCTextInput_clearString00);
   tolua_function(tolua_S, "getString", tolua_Cocos2d_CCTextInput_getString00);
  tolua_endmodule(tolua_S);
  tolua_cclass(tolua_S,"CCImageLoader","CCImageLoader","CCNode",NULL);
  tolua_beginmodule(tolua_S,"CCImageLoader");
   tolua_function(tolua_S,"addImage",tolua_Cocos2d_CCImageLoader_addImage00);
   tolua_function(tolua_S,"create",tolua_Cocos2d_CCImageLoader_create00);
  tolua_endmodule(tolua_S);
  tolua_cclass(tolua_S,"CCTouchLayer","CCTouchLayer","CCNode",NULL);
  tolua_beginmodule(tolua_S,"CCTouchLayer");
   tolua_function(tolua_S,"registerScriptTouchHandler",tolua_Cocos2d_CCTouchLayer_registerScriptTouchHandler00);
   tolua_function(tolua_S,"create",tolua_Cocos2d_CCTouchLayer_create00);
  tolua_endmodule(tolua_S);
  tolua_cclass(tolua_S,"Lightning", "Lightning", "CCSpriteBatchNode", NULL);
  tolua_beginmodule(tolua_S,"Lightning");
   tolua_function(tolua_S, "create", tolua_Cocos2d_Lignting_create00);
   tolua_function(tolua_S, "midDisplacement", tolua_Cocos2d_Lignting_midDisplacement00);
   tolua_function(tolua_S, "setColor", tolua_Cocos2d_Lignting_setColor00);
   tolua_function(tolua_S, "setFadeOutRate", tolua_Cocos2d_Lignting_setFadeOutRate00);
  tolua_endmodule(tolua_S);
  tolua_cclass(tolua_S,"CCAlphaTo","CCAlphaTo","CCActionInterval",NULL);
  tolua_beginmodule(tolua_S,"CCAlphaTo");
   tolua_function(tolua_S, "create", tolua_Cocos2d_CCAlphaTo_create00);
  tolua_endmodule(tolua_S);
  tolua_cclass(tolua_S,"CCNumberTo","CCNumberTo","CCActionInterval",NULL);
  tolua_beginmodule(tolua_S,"CCNumberTo");
   tolua_function(tolua_S, "create", tolua_Cocos2d_CCNumberTo_create00);
  tolua_endmodule(tolua_S);
  tolua_cclass(tolua_S,"CCShake","CCShake","CCActionInterval",NULL);
  tolua_beginmodule(tolua_S,"CCShake");
   tolua_function(tolua_S, "create", tolua_Cocos2d_CCShake_create00);
  tolua_endmodule(tolua_S);
  tolua_cclass(tolua_S,"CCHttpRequest","CCHttpRequest","CCObject",NULL);
  tolua_beginmodule(tolua_S,"CCHttpRequest");
   tolua_function(tolua_S,"create", tolua_Cocos2d_CCHttpRequest_create00);
   tolua_function(tolua_S,"addPostValue", tolua_Cocos2d_CCHttpRequest_addPostValue00);
   tolua_function(tolua_S,"setTimeout", tolua_Cocos2d_CCHttpRequest_setTimeout00);
   tolua_function(tolua_S,"start", tolua_Cocos2d_CCHttpRequest_start00);
   tolua_function(tolua_S,"getResponseStatusCode", tolua_Cocos2d_CCHttpRequest_getResponseStatusCode00);
   tolua_function(tolua_S,"getResponseString", tolua_Cocos2d_CCHttpRequest_getResponseString00);
  tolua_endmodule(tolua_S);
  tolua_cclass(tolua_S,"CCCrypto","CCCrypto","",NULL);
  tolua_beginmodule(tolua_S, "CCCrypto");
   tolua_function(tolua_S,"md5encode", tolua_Cocos2d_CCCrypto_md5encode00);
   tolua_function(tolua_S,"rsaSign", tolua_Cocos2d_CCCrypto_rsaSign00);
  tolua_endmodule(tolua_S);
  tolua_cclass(tolua_S,"CCNative","CCNative","",NULL);
  tolua_beginmodule(tolua_S, "CCNative");
   tolua_function(tolua_S,"openURL", tolua_Cocos2d_CCNative_openURL00);
   tolua_function(tolua_S,"postNotification", tolua_Cocos2d_CCNative_postNotification00);
   tolua_function(tolua_S,"clearLocalNotification", tolua_Cocos2d_CCNative_clearLocalNotification00);
  tolua_endmodule(tolua_S);
  tolua_cclass(tolua_S,"CCWebView","CCWebView","CCObject",NULL);
   tolua_beginmodule(tolua_S,"CCWebView");
   tolua_function(tolua_S, "create", tolua_Cocos2d_CCWebView_create00);
  tolua_endmodule(tolua_S);

  tolua_cclass(tolua_S,"VideoCamera","VideoCamera","CCNode",NULL);
  tolua_beginmodule(tolua_S,"VideoCamera");
   tolua_function(tolua_S,"startRecord",tolua_Cocos2d_VideoCamera_startRecord00);
   tolua_function(tolua_S,"endRecord",tolua_Cocos2d_VideoCamera_endRecord00);
   tolua_function(tolua_S,"create",tolua_Cocos2d_VideoCamera_create00);
  tolua_endmodule(tolua_S);

  tolua_cclass(tolua_S,"Scissor","Scissor","CCNode",NULL);
  tolua_beginmodule(tolua_S,"Scissor");
   tolua_function(tolua_S,"create",tolua_Cocos2d_Scissor_create00);
  tolua_endmodule(tolua_S);
  return 1;
}
//打开状态
//注册类型

//使用全局的module 模块
//注册模块
int tolua_MyExt_open(lua_State *tolua_S) {
    tolua_open(tolua_S);
    tolua_ext_reg_types(tolua_S);
    tolua_module(tolua_S, NULL, 0);
    tolua_beginmodule(tolua_S, NULL);
    tolua_ext_reg_modules(tolua_S);
    tolua_endmodule(tolua_S);
	return 1;
}
