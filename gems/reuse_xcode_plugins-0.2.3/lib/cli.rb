module CLI
  def self.dry_run?
    ARGV.include?('-d') || ARGV.include?('--dry-run')
  end

  def self.unsign_xcode?
    ARGV.include?('--unsign')
  end

  def self.restore_xcode?
    ARGV.include?('--restore')
  end

  def self.update_plugins?
    ARGV.include?('--update_plugins')
  end

  def self.no_colors?
    ARGV.include?('--no-colors')
  end

  def self.non_interactive?
    ARGV.include?('--non-interactive')
  end

  def self.codesign_exists?
    `which codesign` && $CHILD_STATUS.exitstatus == 0
  end

  def self.chown_if_required(path)
    return yield if File.owned?(path)

    puts
    puts "* 正在修改 #{path} 的所有者，之后会恢复".colorize(:light_blue)

    previous_owner = File.stat(path).uid
    system("sudo chown $(whoami) \"#{path}\"")

    raise "不能修改 #{path} 的所有者" unless File.owned?(path)

    result = yield
    system("sudo chown #{previous_owner} \"#{path}\"")
    puts "* 恢复 #{path} 的所有者".colorize(:light_blue)

    result
  end

  {
    title: :blue,
    process: :light_blue,
    warning: :yellow,
    error: :red,
    success: :green
  }.each do |type, color|
    if CLI.no_colors?
      define_method type.to_sym do |str| puts str end
    else
      define_method type.to_sym do |str| puts str.colorize(color) end
    end
  end

  def separator
    puts
  end
end
