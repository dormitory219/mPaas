# frozen_string_literal: true

# user_content_image.rb
# workspace
#
# Created by quinn on 2019-03-22.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # mpaas 框架目录中，用户内容镜像
  # 升级基线的时候需要保留用户在 MPaaS 目录下的修改痕迹
  #
  class UserContentImage
    # 构建镜像，执行操作，恢复镜像
    #
    # @param [XCProjectObject] project
    # @param &block 操作回调
    #
    def self.build_and_recover(project)
      instance = new(project)
      yield instance if block_given?
      instance.recover
    end

    # 初始化
    #
    # @param [XCProjectObject] project
    #
    def initialize(project)
      @project = project
      @image_nodes = []
    end

    # 创建镜像，保存已有文件
    #
    def build(nodes)
      UILogger.info('创建用户内容镜像')
      @image_nodes = nodes
      # 创建镜像
      @image_nodes.each do |node|
        mirror_path = corresponding_mirror_path(node.path)
        # 创建镜像目录
        FileUtils.mkdir_p(mirror_path.parent)
        # 原文件拷贝到镜像目录
        UILogger.debug("镜像文件: #{File.basename(node.path)}")
        FileUtils.cp_r(node.path, mirror_path.parent)
      end
      # 移除工程
      UILogger.debug('镜像文件从工程中分离')
      @image_nodes.each { |n| n.remove_from_project(@project.xcodeproj_path) }
    end

    # 恢复镜像，将冲突文件还原
    #
    def recover
      UILogger.info('从镜像还原用户内容')
      # 去除不需要恢复的节点
      @image_nodes.select(&method(:node_need_recover)).each do |node|
        # 还原文件
        UILogger.debug("还原文件: #{File.basename(node.path)}")
        FileUtils.cp_r(corresponding_mirror_path(node.path), File.dirname(node.path),
                       :remove_destination => true)
        # 复原到工程
        node.recover_to_project(@project.xcodeproj_path)
      end
      # 清除镜像目录
      clean_mirror
    end

    private

    # 获取原路径对应的镜像文件路径
    #
    # @param [String] path
    # @return [Pathname]
    #
    def corresponding_mirror_path(path)
      relative_path = Pathname.new(path).relative_path_from(@project.src_root)
      mirror_dir + relative_path
    end

    # 节点是否需要恢复
    #
    # @param [ImageNode] node
    # @return [Bool]
    #
    def node_need_recover(node)
      # 文件存在，并且镜像文件比新集成的文件大，直接还原；文件不存在，表示非框架文件，直接还原
      mirror_path = corresponding_mirror_path(node.path)
      node.force || !File.exist?(node.path) || File.size(mirror_path) > File.size(node.path)
    end

    # 镜像文件保存的目录
    #
    # @return [Pathname]
    #
    def mirror_dir
      @mirror_dir ||= Pathname.new(Dir.mktmpdir)
    end

    # 清理镜像目录
    #
    def clean_mirror
      UILogger.debug('清理镜像目录')
      FileUtils.remove_entry(mirror_dir) if Dir.exist?(mirror_dir)
    end
  end
end
