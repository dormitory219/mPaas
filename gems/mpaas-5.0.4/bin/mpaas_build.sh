#!/bin/sh

# sh mpaas_build.sh app_key=XXX bundle_id=xxx.xxx bundle_version=1.0.0.9 project_path=xxxxxx debug=false app_store=true env_switch=true
#    profile_uuid=XXXXX password=XXXX verbose=true rpc_gw=xxx log_gw=xxx push_id=xxx workspace_id=xxx security_file=xxx
# app_key: 应用的appkey，必填
# bundle_id: 应用的bundle id
# bundle_version: 打包的版本号
# project_path: xcodeproj文件路径，必填
# debug: 是否开启DEBUG宏，选填
# app_store: 是否编译appstore的包，必填
# env_switch: 是否在系统设置配置可以切换环境，选填
# codesign_identity：证书名称，必填，如 iPhone Distribution: Alipay.Com Co., Ltd.
# profile_uuid: 使用证书UUID，必填
# password: 证书密码，必填
# verbose: 是否显示完整信息，选填
# rpc_gw: Rpc网关地址
# log_gw: 日志网关地址
# push_id: push应用名
# workspace_id: 日志用的
# security_file: 无线保镖文件路径
#
# 范例
# sh mpaas_build.sh app_key=FinancialCloud bundle_id=com.alipay.client bundle_version=1.0.0.9 project_path=/Users/shenmo/Desktop/Develop/iOS/Alipay/mPaas/Source/demos/FinancialCloud/FinancialCloud.xcodeproj debug=false app_store=true env_switch=false profile_uuid=4e35f09c-9fc2-4070-9054-61f8fc62cd02 password=xxxx rpc_gw=xxx log_gw=xxx push_id=ANT_FINANCIAL workspace_id=xxx

echo "\n******************** 华丽的分割线 ********************"

app_key=""
bundle_id=""
bundle_version=""
project_path=""
debug="false"
app_store="false"
env_switch="true"
codesign_identity=""
profile_uuid=""
password=""
verbose="false"
rpc_gw=""
log_gw=""
push_id=""
workspace_id=""
security_file=""
workspace=""

RED(){ echo "\033[31m"$1"\033[0m"; }
GREEN(){ echo "\033[32m"$1"\033[0m"; }
PURPLE(){ echo "\033[35m"$1"\033[0m"; }
TIMESTAMP(){
    timeNow=`date '+%s'`
    echo `expr $timeNow - $timeBegin`
}

OLD_IFS="$IFS"
IFS=$'\n'
for i in $@; do
    eval $i
    # Bad arguments
    if [ $? -ne 0 ]; then
        RED "参数格式错误：$i"
        exit 1
    fi
done
IFS="$OLD_IFS"

PROJ_DIR=$(dirname $project_path)
echo "[yw PROJ_DIR：]" $PROJ_DIR
PROJ_FILE=$(basename $project_path)
echo "[yw ：PROJ_FILE]" $PROJ_FILE
PROJ_NAME="${PROJ_FILE%.*}"
echo "[yw ：PROJ_NAME]" $PROJ_NAME
if [[ "true" == $workspace ]]; then
    BUILD_TARGET="-workspace ${PROJ_NAME}.xcworkspace"
else
    BUILD_TARGET="-project ${PROJ_FILE}"
fi
echo "[yw BUILD_TARGET：]" $BUILD_TARGET
SCHEME_NAME=${PROJ_NAME}
echo "[yw SCHEME_NAME：]" $SCHEME_NAME
CODE_SIGN_IDENTITY=${codesign_identity}
echo "[yw CODE_SIGN_IDENTITY]" $CODE_SIGN_IDENTITY

# 读取provision文件的uuid值
if [ -z $profile_uuid ]
then
  echo "provision file is nil，please input"
  exit 1
fi
mobileprovision_uuid=`/usr/libexec/PlistBuddy -c "Print UUID" /dev/stdin <<< $(/usr/bin/security cms -D -i $profile_uuid)`
echo "UUID is: "${mobileprovision_uuid}


cd ${PROJ_DIR}

timeBegin=0

# if [[ -z $password ]]; then
#     RED "未指定用户密码：password"
#     exit 1
# fi

if [[ "true" == $debug ]]; then
    configuration="Debug"
else
    configuration="Release"
fi
unset debug

use_archive_flag=${app_store}

# Building Settings - Code Signing
GREEN "设置Code Signing"
ruby -e "
    Gem.path.insert(0, '/Users/Shared/.mpaaskit_gems')
    require 'xcodeproj'
    xcproj = Xcodeproj::Project.open('${PROJ_FILE}')
    xcproj.targets.each do |target|
        if target.display_name == '${PROJ_NAME}'
            target.build_configurations.each do |config|
              config.build_settings['CODE_SIGN_IDENTITY'] = '${codesign_identity}'
              config.build_settings['CODE_SIGN_IDENTITY[sdk=iphoneos*]'] = '${codesign_identity}'
              config.build_settings['PROVISIONING_PROFILE'] = '${mobileprovision_uuid}'
              config.build_settings['PROVISIONING_PROFILE[sdk=iphoneos*]'] = '${mobileprovision_uuid}'
            end
        end
    end
    xcproj.save"
if [[ 0 -ne $? ]]; then
    RED "清理Code Signing失败！"
    exit 1
fi
#xcproj.recreate_user_schemes

# 处理appkey
GREEN "处理appkey，appkey is '${app_key}'"
mainPath=`find . -name "main.m" -type f`
PURPLE "main.m文件路径：${mainPath}"
ruby -e "lines = IO.readlines('${mainPath}')
    overrideFile = File.new('${mainPath}', \"w\")
    lines.each do |l|
        if l =~ /\\s*mPaasInit\\s*\\(\\s*@\"\\w*\"\\s*,\\s*\\[\\s*\\w*\\s*class\\s*\\]\\s*\\)\\s*;\\s*/
            l.sub!(/@\"\\w*\"/, '@\"${app_key}\"')
        end
        overrideFile.puts l
    end
    overrideFile.close"

# 处理无线保镖文件
GREEN "处理无线保镖文件"
securityGuardFile=`find . -name "yw_1222.jpg" -type f`
PURPLE "无线保镖文件文件路径：${securityGuardFile}"
if [ -n "$securityGuardFile" ]; then
    if [ -n "$security_file" ]; then
        cp "${security_file}" "${securityGuardFile}"
    fi
fi

# 处理Info.plist
GREEN "处理Info.plist"
ruby -e "
    Gem.path.insert(0, '/Users/Shared/.mpaaskit_gems')
    require 'xcodeproj'
    path = \"\"
    xcproj = Xcodeproj::Project.open('${PROJ_FILE}')
    xcproj.targets.each do |target|
        if target.display_name == '${PROJ_NAME}'
            target.build_configurations.each do |config|
              path = config.build_settings['INFOPLIST_FILE']
              break
            end
        end
    end
    pathFile = File.new('plist_path.tmp', \"w\")
    pathFile.puts \"./\" + path
    pathFile.close"
mainInfoPlistPath=`head -1 plist_path.tmp`
rm plist_path.tmp
PURPLE "Info.plist文件路径：${mainInfoPlistPath}"
# 把版本号分割开
OLD_IFS="$IFS"
IFS="."
versionArray=($bundle_version)
IFS="$OLD_IFS"
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier ${bundle_id}" "${mainInfoPlistPath}"
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString ${versionArray[0]}.${versionArray[1]}.${versionArray[2]}" "${mainInfoPlistPath}"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${versionArray[3]}" "${mainInfoPlistPath}"
#修改Production Version
productVersionKey="Product Version"
/usr/libexec/PlistBuddy -c "Set :${productVersionKey} ${bundle_version}" "${mainInfoPlistPath}"

# 处理Settings.bundle
GREEN "处理Settings.bundle"
ruby -e "
    Gem.path.insert(0, '/Users/Shared/.mpaaskit_gems')
    require 'xcodeproj'
    xcproj = Xcodeproj::Project.open('${PROJ_FILE}')
    file = xcproj['${PROJ_NAME}']['Supporting Files']['Settings.bundle']
    if file
        if '${env_switch}' == 'false'
            puts \"Remove Settings.bundle\"
            xcproj.targets.each do |target|
                if target.display_name == '${PROJ_NAME}'
                    target.build_phases.each do |phase|
                        if phase.display_name == 'SourcesBuildPhase' || phase.display_name == 'ResourcesBuildPhase'
                            phase.remove_file_reference(file)
                        end
                    end
                end
            end
            xcproj.save
        end
    else
        puts 'Settings.bundle is not found!'
    end"
if [[ 0 -ne $? ]]; then
    RED "Settings.bundle处理失败！"
    exit 1
fi

GREEN "处理网关地址"
gatewayConfig=`find . -name "GatewayConfig.plist" -type f`
PURPLE "配置文件路径：${gatewayConfig}"
if [[ "false" == ${env_switch} ]]; then
    /usr/libexec/PlistBuddy -c "Delete :Debug" "${gatewayConfig}"
    /usr/libexec/PlistBuddy -c "Delete :Pre-release" "${gatewayConfig}"
fi
/usr/libexec/PlistBuddy -c "Set :Release:mPaasPushAppId ${push_id}" "${gatewayConfig}"
/usr/libexec/PlistBuddy -c "Set :Release:mPaasRpcGateway ${rpc_gw}" "${gatewayConfig}"
/usr/libexec/PlistBuddy -c "Set :Release:mPaasRpcETagURL ${rpc_gw}" "${gatewayConfig}"
/usr/libexec/PlistBuddy -c "Set :Release:mPaasLogServerGateway ${log_gw}" "${gatewayConfig}"
/usr/libexec/PlistBuddy -c "Set :Release:mPaasLogProductId ${app_key}-${workspace_id}" "${gatewayConfig}"

GREEN "设置目标目录"
release_dir=${PROJ_DIR}/Products/${configuration}-iphoneos
touch ${release_dir}/xrun.log

if [[ -d $release_dir ]]; then
    rm -r $release_dir
fi
mkdir -p $release_dir/dsym

timeBegin=`date '+%s'`
builtProductPath="$PWD/build"
[ ! -d "$builtProductPath" ] && { mkdir "$builtProductPath"; };
rm -rf "$builtProductPath"
PURPLE $release_dir

# PRODUCT_NAME
xcodeproj_build_settings=$(xcodebuild clean build ${BUILD_TARGET} -scheme ${SCHEME_NAME} -configuration ${configuration} -sdk iphoneos -showBuildSettings | grep " = " | sed "s# = #=#")
# PRODUCT_NAME
eval $(echo "$xcodeproj_build_settings" | grep " PRODUCT_NAME=" | head -n1)
[ -z "$PRODUCT_NAME" ] && {
    PRODUCT_NAME=${app_key};
}
PURPLE "目标名字：$PRODUCT_NAME"

if [[ "$use_archive_flag" == "true" ]]; then
    build_command="xcodebuild clean archive ${BUILD_TARGET} -scheme ${SCHEME_NAME} -configuration ${configuration} -sdk iphoneos -archivePath $builtProductPath/$PRODUCT_NAME"
else
    build_command="xcodebuild clean build ${BUILD_TARGET} -scheme ${SCHEME_NAME} -configuration ${configuration} -sdk iphoneos"
fi

security unlock-keychain -p alipay ~/Library/Keychains/login.keychain
PURPLE "构建指令：$build_command"
if [[ "$use_archive_flag" == "true" ]]; then
    xcodebuildResult=`xcodebuild clean archive ${BUILD_TARGET} -scheme ${SCHEME_NAME} -configuration ${configuration} -sdk iphoneos -archivePath $builtProductPath/$PRODUCT_NAME 2>&1`
else
    xcodebuildResult=`xcodebuild clean build ${BUILD_TARGET} -scheme ${SCHEME_NAME} -configuration ${configuration} -sdk iphoneos 2>&1`
fi
if [[ 0 -ne $? ]]; then
    RED "编译失败！"
    if [[ "true" == "$verbose" ]]; then
        echo "$xcodebuildResult"
    else
        echo "$xcodebuildResult" | grep -v "Toolchains/XcodeDefault.xctoolchain" | grep -v "DerivedData" | grep -vE "^write-file|Libtool|CompileC| *Ld| *cd| *export|warning:|Check dependencies|Write auxiliary files|===|\*\*" | grep -vE "^ *$"
    fi
    exit 1
fi
GREEN "编译成功！耗时$(TIMESTAMP)秒"

if [[ "$use_archive_flag" == "true" ]]; then
    appPath="$(find $builtProductPath -name "*.app" | head -n1)"
    dSYMPath="$(find $builtProductPath -name "dSYMs")"
else
    eval $(echo "$xcodeproj_build_settings" | grep -w "BUILD_DIR" | grep -oE "[^ ]*DerivedData/[^/]*" | head -n1)
    derivedDataPath=$BUILD_DIR
    appPath=${derivedDataPath}/Build/Products/${configuration}-iphoneos/$PRODUCT_NAME.app
    dSYMPath=${appPath}.dSYM

    PURPLE "目标derivedData路径：${derivedDataPath}"
fi

PURPLE "目标APP路径：${appPath}"
PURPLE "目标符号表文件路径：${dSYMPath}"

if [[ -d "$appPath" ]]; then
    uuid=`dwarfdump -u ${appPath}/$PRODUCT_NAME`
    PURPLE "${uuid}"
    # 日志记录包的UUID，写入数据库便于查找
    uarmv7=`echo "$uuid" | grep "armv7"`
    [[ -n $uarmv7 ]] && echo "$uarmv7" | awk -F " " '{print "UUID(armv7): "$2}' >> ${release_dir}/xrun.log
    uarm64=`echo "$uuid" | grep "arm64"`
    [[ -n $uarm64 ]] && echo "$uarm64" | awk -F " " '{print "UUID(arm64): "$2}' >> ${release_dir}/xrun.log
    cp -r $appPath $release_dir/dsym
else
    RED "app文件未生成，Build 失败！"
    [[ -d $builtProductPath ]] && rm -rf $builtProductPath
    exit 1
fi

if [[ -d $dSYMPath ]]; then
    if [[ "$use_archive_flag" == "true" ]]; then
        cp -av $dSYMPath/*.dSYM $release_dir/dsym
    else
        cp -r $dSYMPath $release_dir/dsym
    fi
else
    RED "dSYM文件未生成，Build 失败！"
    [[ -d $builtProductPath ]] && rm -rf $builtProductPath
    exit 1
fi

# run
security unlock-keychain -p alipay ~/Library/Keychains/login.keychain

if [[ "$use_archive_flag" == "true" ]]; then
    ipa_command="xcrun -sdk iphoneos PackageApplication -v $builtProductPath/$PRODUCT_NAME.xcarchive/Products/Applications/$PRODUCT_NAME.app -o ${release_dir}/${bundle_version}_${PRODUCT_NAME}.ipa"
else
    ipa_command="xcrun -sdk iphoneos PackageApplication -v ${release_dir}/dsym/$PRODUCT_NAME.app -o ${release_dir}/${bundle_version}_${PRODUCT_NAME}.ipa"
fi

PURPLE "构建ipa命令：$ipa_command"
if [[ "true" == "$verbose" ]]; then
    $ipa_command 2>&1
else
    $ipa_command 1>/dev/null 2>&1
fi

# 为 AppleWath 和 Swift 增加 Support 目录
#echo "Add WatchkitSupport & SwiftSupport.."
#if [[ -d "$builtProductPath" ]]; then
#    find "$builtProductPath" -name "*Support" | while read support_path; do
#        pushd "$(dirname $support_path)"
#            zip -r $release_dir/Portal.ipa $(basename $support_path);
#        popd
#    done
#fi

if [[ 0 -ne $? ]]; then
    RED "打包失败！耗时$(TIMESTAMP)秒"
    exit 1
else
    GREEN "打包成功！耗时$(TIMESTAMP)秒"
    FILE="${release_dir}/${bundle_version}_${PRODUCT_NAME}.ipa"
    PURPLE "包位于：${FILE}"
    echo "[INFO][FILENAME]${FILE}"
    SIZE=`ls -l ${FILE} | awk '{print $5}'`
    echo "[INFO][packageSize]${SIZE}"
    echo "[INFO][packageTime]$(TIMESTAMP)"
    # 提取dSYM
    timeBegin=`date '+%s'`
    GREEN "正在提取并打包dSYM ..."
    cd ${release_dir}
    tar -zcf dsym.tgz dsym
    rm -r dsym
    GREEN "dSYM打包成功！耗时$(TIMESTAMP)秒"
    # 删除~/Library/Developer/Xcode/DerivedData/下缓存目录
    [[ -d $builtProductPath ]] && rm -rf $builtProductPath
    open ${release_dir}
fi
