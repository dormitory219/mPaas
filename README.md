https://tech.antfin.com/docs/2/51750

安装了 开发者工具 后，除了 mPaaS 插件，您还可以使用 命令行工具 辅助开发。

命令列表如下：

分类	命令	功能
工程管理命令
mpaas project create

创建 Xcode 工程
mpaas project target

获取 Xcode 工程的 targets 信息
mpaas project import

向工程导入云端配置数据
mpaas project edit

增删 mPaaS 模块依赖
mpaas project upgrade

升级 mPaaS 模块依赖
SDK 管理命令
mpaas sdk version

显示最新可用的 SDK 版本
mpaas sdk list

查看本地已安装的 SDK 列表
mpaas sdk search

根据名称模糊查询 SDK 信息
基础工具命令
mpaas inst hotpatch sign

获取生成热修复包的密钥签名
mpaas inst hotpatch package

对原始脚本文件进行加签，生成热修复包
mpaas inst sgimage

生成无线保镖图片
Xcode 插件命令
mpaas xcode unsign

去除 Xcode 签名
mpaas xcode restore

恢复 Xcode 签名
mpaas xcode plugins version

显示当前安装的 mPaaS 的 Xcode 插件版本号
mpaas xcode plugins install

安装 mPaaS 的 Xcode 插件
mpaas xcode plugins uninstall

卸载 mPaaS 的 Xcode 插件
mpaas xcode plugins update

更新 mPaaS 的 Xcode 插件
mpaas xcode plugins refresh

刷新 mPaaS 的 Xcode 插件的 UUID
更新开发者工具命令
mpaas update

更新开发者工具
环境配置命令
mpaas env

显示当前环境信息
诊断命令
mpaas diagnose report

生成 mPaaS 诊断报告
我要反馈

