require_relative 'xcode'
require_relative 'xcode_plugin'

class PluginsUpdater
  extend CLI

  def self.update_plugins
    xcodes = Xcode.find_xcodes

    if xcodes.empty?
      error "没有发现任何安装的 Xcode"
      return
    else
      title '已找到'
      puts xcodes.map { |xcode| "- #{xcode.detailed_description}" }
    end

    separator

    plugins = XcodePlugin.find_plugins

    if plugins.empty?
      error "未发现任何已安装的Xcode插件"
      return
    else
      title '插件:'
      puts plugins.map { |s| "- #{s}" }
    end

    separator
    process '更新UUID...'

    uuids = xcodes.collect(&:uuid)
    uuids.each do |uuid|
      plugins.each do |plugin|
        if plugin.add_uuid(uuid) && !CLI.dry_run?
          success "添加 #{uuid} 到 #{plugin}"
        end
      end
    end

    separator
    success '完成! 🎉'

    return if CLI.no_colors?

    # if xcodes.any? { |xcode| xcode.version.to_f >= 8 }
    #   separator
    #   warning 'It seems that you have Xcode 8+ installed!'
    #   puts 'Some plugins might not work on recent versions of Xcode because of library validation.',
    #        "See #{'https://github.com/alcatraz/Alcatraz/issues/475'.underline}"

    #   separator
    #   puts "Run `#{'update_xcode_plugins --unsign'.bold}` to fix this."
    # end
  end
end
