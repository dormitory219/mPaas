require_relative 'xcode'

class XcodeUnsigner
  extend CLI

  def self.unsign_xcode
    process '正在查找安装的 Xcode...'
    xcodes = Xcode.find_xcodes
                  .select { |xcode| xcode.version.to_f >= 8 }
                  .select(&:signed?)

    separator

    if xcodes.empty?
      error "没有发现任何有签名的 Xcode 8+."
      return
    end

    notice
    separator

    selection = Ask.list "选择你想要去掉签名的 Xcode(按上下键改变箭头)", xcodes
    return unless selection

    xcode = xcodes[selection]

    # unsign_xcodebuild = Ask.confirm "Unsign xcodebuild too?"
    unsign_xcodebuild = true

    separator

    process '正在去除签名...'
    if xcode.unsign_binary! &&
       (!unsign_xcodebuild || (unsign_xcodebuild && xcode.unsign_xcodebuild!))
      success '完成! 🎉'
    else
      error "未能取消 #{xcode.path} 的签名\n"\
            '请联系mPaaS开发者'
    end
  end

  def self.restore_xcode
    process '正在查找安装的 Xcode...'
    xcodes = Xcode.find_xcodes
                  .select { |xcode| xcode.version.to_f >= 8 }
                  .select(&:restorable?)

    separator

    if xcodes.empty?
      error "没有发现任何可恢复签名的 Xcode 8+."
      return
    end

    selection = Ask.list "选择你想要恢复签名的 Xcode(按上下键改变箭头)", xcodes
    return unless selection

    xcode = xcodes[selection]

    separator

    process '正在恢复签名...'

    success = true

    if xcode.binary_restorable? && !xcode.restore_binary!
      error "未能恢复 #{xcode.path} 的签名\n"\
            '请联系mPaaS开发者'
      success = false
    end

    if xcode.xcodebuild_restorable? && !xcode.restore_xcodebuild!
      error "未能恢复 xcodebuild 的签名\n"\
            '请联系mPaaS开发者'
      success = false
    end

    success '完成! 🎉' if success
  end

  def self.update_plugins

  end

  def self.notice
    puts [
      '取消Xcode的签名将会跳过插件的签名验证，从而允许加载插件'.colorize(:yellow),
      '然而，未签名的Xcode会产生一定的安全风险，Apple和你的系统都会不信任未签名的Xcode'\
      '请不要使用未签名的Xcode进行打包操作，正常开发没有问题'.colorize(:red),
      "这个工具会产生签名文件的备份，以便于之后你可以用下面的命令安装reuse_xcode_plugins和恢复签名\n",
      '$ gem install reuse_xcode_plugins'.colorize(:light_blue),
      '$ reuse_xcode_plugins --restore'.colorize(:light_blue)
    ]
  end
end
