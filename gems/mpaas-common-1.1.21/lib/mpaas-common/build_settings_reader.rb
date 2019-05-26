# frozen_string_literal: true

# build_settings_reader.rb
# workspace
#
# Created by quinn on 2019-05-06.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 读取工程的 build setting
  #
  class BuildSettingsReader
    def initialize(project_path)
      @project_path = project_path
      @build_settings = {}
    end

    # 读取某个target的build setting的值
    #
    # @param [String] target target名称
    # @param [String] field 字段名称
    # @return [String] 字段值
    #
    def read(target, field)
      parse(target) unless @build_settings.key?(target)
      @build_settings[target][field]
    end

    # 是否匹配某一个工程
    #
    # @param [Bool] path
    #
    def match?(path)
      @project_path == path
    end

    private

    # 解析
    #
    # @param [String] target
    #
    def parse(target)
      output, status = CommandExecutor.exec(
        "xcodebuild -showBuildSettings -project '#{@project_path}' -scheme #{target} -json 2>/dev/null"
      )
      unless status.success?
        UILogger.error(output)
        raise '无法解析工程'
      end
      @build_settings[target] = JSON.parse(output).first['buildSettings']
    end
  end
end
