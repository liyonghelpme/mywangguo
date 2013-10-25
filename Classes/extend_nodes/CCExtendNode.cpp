#include "CCExtendNode.h"

#include "effects/CCGrid.h"
// externals
#include "kazmath/GL/matrix.h"

NS_CC_EXT_BEGIN

CCExtendNode::CCExtendNode(void)
: m_bClip(false),
m_pHSVHandler(NULL)
{
}

CCExtendNode::~CCExtendNode(void)
{
	if(m_pHSVHandler!=NULL)
		delete m_pHSVHandler;
}

CCExtendNode* CCExtendNode::create(const CCSize contentSize, bool isClip)
{
    CCExtendNode *pobNode = new CCExtendNode();
    if (pobNode)
    {
		pobNode->setContentSize(contentSize);
        pobNode->autorelease();
		pobNode->m_bClip = isClip;
        return pobNode;
    }
    CC_SAFE_DELETE(pobNode);
    return NULL;
}

void CCExtendNode::setClip(bool value)
{
	this->m_bClip = value;
}

void CCExtendNode::setHueOffset(int offset, bool isRecur)
{
	if(m_pHSVHandler==NULL){
		m_pHSVHandler = new CCHSVShaderHandler();
	}
	m_pHSVHandler->setHueOffset(this, offset, isRecur);
}

void CCExtendNode::setSatOffset(int offset, bool isRecur)
{
	if(m_pHSVHandler==NULL){
		m_pHSVHandler = new CCHSVShaderHandler();
	}
	m_pHSVHandler->setSatOffset(this, offset, isRecur);
}

void CCExtendNode::setValOffset(int offset, bool isRecur)
{
	if(m_pHSVHandler==NULL){
		m_pHSVHandler = new CCHSVShaderHandler();
	}
	m_pHSVHandler->setValOffset(this, offset, isRecur);
}

void CCExtendNode::setHSVParentOffset(int hoff, int soff, int voff)
{
	if(m_pHSVHandler==NULL){
		m_pHSVHandler = new CCHSVShaderHandler();
	}
	m_pHSVHandler->setHSVParentOffset(this, hoff, soff, voff);
}

void CCExtendNode::addChild(CCNode *child, int zOrder, int tag)
{
	if (m_pHSVHandler!=NULL && m_pHSVHandler->isRecur())
	{
		m_pHSVHandler->recurSetShader(this, child);
	}
	CCNode::addChild(child, zOrder, tag);
}

void CCExtendNode::visit()
{
    if (!m_bVisible)
    {
        return;
    }
	
	CCSize wsize = CCDirector::sharedDirector()->getVisibleSize();
	CCPoint leftBottomPoint = this->convertToWorldSpace(CCPointZero);
	const CCSize& size = this->getContentSize();
	CCPoint rightTopPoint = this->convertToWorldSpace(CCPointMake(size.width, size.height));
	if(leftBottomPoint.x>wsize.width || leftBottomPoint.y>wsize.height || rightTopPoint.x < 0 || (2*rightTopPoint.y -leftBottomPoint.y)<0)
	{
		return;
	}

	kmGLPushMatrix();
	
	if(this->m_bClip)
	{
		glEnable(GL_SCISSOR_TEST);
		glScissor(leftBottomPoint.x, leftBottomPoint.y, rightTopPoint.x-leftBottomPoint.x, rightTopPoint.y-leftBottomPoint.y);
	}
     if (m_pGrid && m_pGrid->isActive())
     {
         m_pGrid->beforeDraw();
     }

    this->transform();

    CCNode* pNode = NULL;
    unsigned int i = 0;

    if(m_pChildren && m_pChildren->count() > 0)
    {
        sortAllChildren();
        // draw children zOrder < 0
        ccArray *arrayData = m_pChildren->data;
        for( ; i < arrayData->num; i++ )
        {
            pNode = (CCNode*) arrayData->arr[i];

			if ( pNode && pNode->getZOrder() < 0 ) 
            {
                pNode->visit();
            }
            else
            {
                break;
            }
        }
        // self draw
        this->draw();

        for( ; i < arrayData->num; i++ )
        {
            pNode = (CCNode*) arrayData->arr[i];
            if (pNode)
            {
                pNode->visit();
            }
        }        
    }
    else
    {
        this->draw();
    }

    // reset for next frame
    m_uOrderOfArrival = 0;

     if (m_pGrid && m_pGrid->isActive())
     {
         m_pGrid->afterDraw(this);
    }
	 
	if(this->m_bClip)
	{
		glDisable(GL_SCISSOR_TEST);
	}
    kmGLPopMatrix();
}
NS_CC_EXT_END