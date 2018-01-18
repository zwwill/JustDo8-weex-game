# 尝试用 Weex 码一个益智类小游戏

![](http://upload-images.jianshu.io/upload_images/1494908-c22761b059d5d35f?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

> 此文是对此 app 的详细介绍 https://github.com/zwwill/blog/issues/4

# 体验

IOS已上线 [https://itunes.apple.com/cn/app/id1299422482](https://itunes.apple.com/cn/app/id1299422482)

也可以直接使用 Weex Playground 扫码体验 [Weex Playground下载地址](http://weex.apache.org/cn/playground.html)

![](https://github.com/zwwill/just-do-8/raw/master/QR4WeexPG.png)

（仅针对ios进行的开发，Android 下可能会存在手势冲突问题）

# 运行
## 安装依赖包

```
$ npm install
```

## 运行ios

ios打包需要开发者帐号，如果不是付费用户就只能通过xcode调试的方式安装在自己的关联手机上（就是手机需要使用此帐号登录）或者虚拟机调试。
以下是无开发者付费帐号的执行方法

执行打包命令

```
$ weex build ios
```

此步骤只为了打包，并不用完全执行，详介请见 [https://github.com/zwwill/blog/issues/5](https://github.com/zwwill/blog/issues/5)

接下来使用xcode安装调试

