支持带alpha图片 和 不带 alpha图片

采用ETC1 压缩方式 
如果是 RGBA 8 8 8 8 图像 可以节约4倍率的 显存使用
如果是 RGBA 4 4 4 4 图像 可以节约2倍率的 显存使用
没有alpha的图片 RGB888  压缩比例6:1
显存使用大小只和图片大小有关 因此 推荐使用 8 8 8 8 的图片来进行压缩 制作ETC1 的图片


ETC1原理 将图片4X4区域的色快 转化成64bit长度的数据


使用方法：
在sample Lua miaomiao2 中 Resource image2 文件夹 getAlpha.py 用于转化带alpha 图片为ext1图片
普通无alpha图片 直接使用 etc1tool 转化即可


修改代码 Classes
ComNative.cpp 中增加了 setGLProgram 修改shader的代码
Resources 中是新增的 shader 代码

LuaScript 中TestScene.lua 是demo 信息


etc1tool 是android-sdk中的工具


adobe flash 在手机平台上也使用这种算法压缩纹理
