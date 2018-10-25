# 1.模式设计

* 类似bilibili的模式，用户可上传内容，也可在网站浏览内容

* 发行一种平台币，作为网站的经济激励
* 奖励细则：
  * up主上传好的视频资源，获用户点赞越多，获得的代币奖励越多
  * 用户浏览网站视频，可根据浏览时长给予代币奖励
  * 用户注册，奖励一定量的代币
  * 用户每日登录可获得固定数量的代币奖励
  * 接入YouTube的搜索API，用户可在本站搜索YouTube内容，返回结果包含两部分：本站相关的内容和YouTube上的内容，如果本站有用户需要的内容，可直接观看；如果没有，可翻墙的用户直接通过搜索返回的YouTube链接跳转到YouTube，不会翻墙的可以用自己的代币发起一份悬赏，鼓励up主从YouTube搬运资源到本站

# 2.细节

* 前端：
  * 五个页面：首页、搜索结果展示页、视频播放页、悬赏列表页、个人中心
  * 一些简单的交互
* 后端：
  * 数据库（sqlite或MySQL），用户表，资源表（图片、视频存路径）等，接口用Python封装好，方便调用
  * flask route，和前端配合
  * 接入YouTube的搜索API

# 3.更进一步

* 可以尝试在以太坊上发行我们的平台币，类似传统的网站积分，发行总量固定，比如100000000，开发团队保留30%，20%用作运营基金，50%作为平台用户奖励

### 以上只是一个简单设想，实现起来有难度，大家有不同意见就在群里提出来




## 初步分锅，先实现基础功能

### 前端
	推荐Vue.js
	首页：展示现在视频库里面的视频之类的（缩略图）
	个人主页：用户信息、以及发布的视频
	播放页：视频播放（怎么和后端接起来是个问题，最好边加载边播放）
	上传页：视频上传，可加上一句话描述

### 后端
	Flask，处理GET/POST请求，返回前端需要的json格式数据
	数据库：
		个人信息表，个人发布的视频表，所有视频资源的表（id，视频路径等，描述）
		常用的数据库查询操作封装好，返回json格式数据，方便调用
	搜索：本地搜索，在所有资源列表里根据资源描述和搜索关键词进行匹配
		youtube搜索，调用youtube提供的api
	
