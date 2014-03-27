#ifndef	__CAESARS_NODE_CCEXTENDNODE_H__
#define __CAESARS_NODE_CCEXTENDNODE_H__

#include "cocos2d_ext_const.h"
#include "CCGL.h"
#include "base_nodes/CCNode.h"
#include "extend_shader/CCHSVShaderHandler.h"


NS_CC_EXT_BEGIN
class CCExtendNode : public CCNode, public CCHSVShaderProtocol
{
private:
	bool m_bClip;
	CCHSVShaderHandler* m_pHSVHandler;
public:
	static CCExtendNode* create(const CCSize contentSize, bool isClip);
public:
    CCExtendNode(void);
    ~CCExtendNode(void);

    virtual void visit();

	virtual void setHueOffset(int offset, bool recur);
	virtual void setSatOffset(int offset, bool recur);
	virtual void setValOffset(int offset, bool recur);
	virtual void setHSVParentOffset(int hoff, int soff, int voff);

	virtual void addChild(CCNode *child, int zOrder, int tag);

	void setClip(bool value);
};

NS_CC_EXT_END

#endif //__CAESARS_NODE_CCEXTENDNODE_H__