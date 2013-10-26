#include "CCHSVShaderHandler.h"

#include "shaders/CCShaderCache.h"
#include "shaders/ccShaders.h"

extern "C"
{
#include <stdio.h>
}

NS_CC_EXT_BEGIN
	
const GLchar * ccHSVTranfer_frag = 
#include "ccShader_HSVTransfer_frag.h"

CCHSVShaderHandler::CCHSVShaderHandler(void)
:m_uHueOffset(0),
m_uSatOffset(0),
m_uValOffset(0),
m_uParentHueOffset(0),
m_uParentSatOffset(0),
m_uParentValOffset(0),
m_bRecur(false)
{
}

CCHSVShaderHandler::~CCHSVShaderHandler(void)
{
}

void CCHSVShaderHandler::setHueOffset(CCNode* node, int offset, bool recur)
{
	if(offset!=m_uHueOffset){
		m_uHueOffset = offset;
		m_bRecur = recur;
		updateHSVShader(node);
	}
}

void CCHSVShaderHandler::setSatOffset(CCNode* node, int offset, bool recur)
{
	if(offset!=m_uSatOffset){
		m_uSatOffset = offset;
		m_bRecur = recur;
		updateHSVShader(node);
	}
}
void CCHSVShaderHandler::setValOffset(CCNode* node, int offset, bool recur)
{
	if(offset!=m_uValOffset){
		m_uValOffset = offset;
		m_bRecur = recur;
		updateHSVShader(node);
	}
}

void CCHSVShaderHandler::setHSVParentOffset(CCNode* node, int hoff, int soff, int voff)
{
	if(m_uParentHueOffset!=hoff || m_uParentSatOffset!=soff || m_uParentValOffset!=voff){
		m_uParentHueOffset = hoff;
		m_uParentSatOffset = soff;
		m_uParentValOffset = voff;
		updateHSVShader(node);
	}
}

bool CCHSVShaderHandler::isRecur()
{
	return m_bRecur;
}

void CCHSVShaderHandler::updateHSVShader(CCNode* base){
	int h = m_uHueOffset+m_uParentHueOffset;
	int s = m_uSatOffset+m_uParentSatOffset;
	int v = m_uValOffset+m_uParentValOffset;
	CCGLProgram* pProgram;
	if(h==0 && s==0 && v==0){
		pProgram = CCShaderCache::sharedShaderCache()->programForKey(kCCShader_PositionTextureColor);
	}
	else{
		char* key = new char[50];
		sprintf(key, "%s_%d_%d_%d", kCCHSVTransfer_Frag, h, s, v);
		pProgram = CCShaderCache::sharedShaderCache()->programForKey(key);
		if (pProgram==NULL)
		{
			pProgram = new CCGLProgram();
			pProgram->initWithVertexShaderByteArray(ccPositionTextureColor_vert, ccHSVTranfer_frag);
			pProgram->addAttribute(kCCAttributeNamePosition, kCCVertexAttrib_Position);  
			pProgram->addAttribute(kCCAttributeNameColor, kCCVertexAttrib_Color);  
			pProgram->addAttribute(kCCAttributeNameTexCoord, kCCVertexAttrib_TexCoords); 
			pProgram->link();
			pProgram->updateUniforms();

			int m_uHueShaderLocation = glGetUniformLocation(pProgram->getProgram(), "u_hueOffset");
			glUniform1f(m_uHueShaderLocation, h/60.0f);
			int m_uSatShaderLocation = glGetUniformLocation(pProgram->getProgram(), "u_satOffset");
			glUniform1f(m_uSatShaderLocation, s/100.0f);
			int m_uValShaderLocation = glGetUniformLocation(pProgram->getProgram(), "u_valOffset");
			glUniform1f(m_uValShaderLocation, v/100.0f);
			
			CCShaderCache::sharedShaderCache()->addProgram(pProgram, key); 
			pProgram->release();
		}
	}
	base->setShaderProgram(pProgram);
	if(m_bRecur){
		CCArray* childs = base->getChildren();
		for(unsigned int i=0; i<childs->count(); i++){
			CCNode* node = (CCNode *)(childs->objectAtIndex(i));
			recurSetShader(base, node);
		}
	}
}

void CCHSVShaderHandler::recurSetShader(CCNode* base, CCNode* node)
{
	CCHSVShaderProtocol* extend = dynamic_cast<CCHSVShaderProtocol*>(node);
	if (extend!=NULL)
	{
		extend->setHSVParentOffset(m_uHueOffset+m_uParentHueOffset, m_uSatOffset+m_uParentSatOffset, m_uValOffset+m_uParentValOffset);
	}
	else
	{
		node->setShaderProgram(base->getShaderProgram());
	}
}

NS_CC_EXT_END