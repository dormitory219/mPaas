# frozen_string_literal: true

# reference_helper.rb
# MpaasKit
#
# Created by quinn on 2019-02-27.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 提供节点 xcode 引用相关操作
  #
  class MpaasNode
    protected

    # 引用的路径
    #
    # @param [Pathname] xcodeproj_path .xcodeproj 工程文件目录（绝对路径）
    # @return [Pathname]
    #
    def reference_path(xcodeproj_path)
      xcodeproj_path.parent + path
    end

    # 引用是否存在
    #
    # @param [Pathname] xcodeproj_path .xcodeproj 工程文件目录（绝对路径）
    # @return [Bool] 是否存在
    #
    def reference_exist?(xcodeproj_path)
      XcodeHelper.file_reference_exist?(xcodeproj_path, reference_path(xcodeproj_path))
    end

    # 添加文件引用
    #
    # @param [Pathname] xcodeproj_path .xcodeproj 工程文件目录（绝对路径）
    #
    def add_reference(xcodeproj_path)
      # 判断是否存在，避免重复添加
      return if reference_exist?(xcodeproj_path)
      # 添加引用
      XcodeHelper.add_file_reference(xcodeproj_path, reference_path(xcodeproj_path))
    end

    # 删除文件引用
    #
    # @param [Pathname] xcodeproj_path .xcodeproj 工程文件目录（绝对路径）
    #
    def remove_reference(xcodeproj_path)
      XcodeHelper.remove_file_reference(xcodeproj_path, reference_path(xcodeproj_path))
    end
  end
end
