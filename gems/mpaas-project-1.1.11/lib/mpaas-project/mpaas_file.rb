# frozen_string_literal: true

# mpaas_file.rb
# MpaasKit
#
# Created by quinn on 2019-01-11.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 工程下 mpaas 框架信息配置文件
  #
  class MpaasFile
    # 打开 mpaas file
    #
    # @param project_src_root 工程的主目录
    #
    def self.open(project_src_root)
      new(project_src_root)
    end

    # 初始化
    #
    # @param project_src_root 工程的主目录
    #
    def initialize(project_src_root)
      @src_root = Pathname.new(project_src_root)
    end

    # 配置文件名称
    #
    # @return [String]
    #
    def name
      Constants::MPAAS_FILE_NAME
    end

    # 是否存在
    #
    # @return [Bool]
    #
    def exist?
      file_path.exist?
    end

    # 读取文件内容
    #
    # @return [Hash]
    #
    def read
      JSON.parse(File.read(file_path)) if exist?
    end

    # 配置文件搜索路径
    #
    # @return [Pathname]
    #
    def file_path
      @src_root + Constants::MPAAS_GROUP_KEY + name
    end
  end
end
