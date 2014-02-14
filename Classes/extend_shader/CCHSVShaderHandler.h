#ifndef	__CAESARS_PROTOCOL_CCHSVSHADERPROTOCOL_H__
#define __CAESARS_PROTOCOL_CCHSVSHADERPROTOCOL_H__

#define	kCCHSVTransfer_Frag	"ccHSVTransfer_frag"

#include "base_nodes/CCNode.h"
#include "cocos2d_ext_const.h"

NS_CC_EXT_BEGIN

class CCHSVShaderProtocol
{
public:
	virtual void setHueOffset(int offset, bool recur) = 0;
	virtual void setSatOffset(int offset, bool recur) = 0;
	virtual void setValOffset(int offset, bool recur) = 0;
	virtual void setHSVParentOffset(int hoff, int soff, int voff) = 0;

	virtual void addChild(CCNode *child, int zOrder, int tag) = 0;
};

class CCHSVShaderHandler
{
private:
	int m_uHueOffset;
	int m_uSatOffset;
	int m_uValOffset;
	int m_uParentHueOffset;
	int m_uParentSatOffset;
	int m_uParentValOffset;
	//÷ªµ›πÈ“ª≤„
	bool m_bRecur;
public:
	CCHSVShaderHandler(void);
	~CCHSVShaderHandler(void);

	void setHueOffset(CCNode* node, int offset, bool recur);
	void setSatOffset(CCNode* node, int offset, bool recur);
	void setValOffset(CCNode* node, int offset, bool recur);
	void setHSVParentOffset(CCNode* node, int hoff, int soff, int voff);
	bool isRecur();
	void recurSetShader(CCNode* base, CCNode* node);
private:
	void updateHSVShader(CCNode* base);
};

extern const GLchar * ccHSVTranfer_frag;

NS_CC_EXT_END

#endif //__CAESARS_PROTOCOL_CCHSVSHADERPROTOCOL_H__