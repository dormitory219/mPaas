# frozen_string_literal: true

# target_node_generator.rb
# MpaasKit
#
# Created by quinn on 2019-03-08.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class MpaasFramework
    # 节点生成器，target 节点部分
    #
    class NodeGenerator
      private

      # 处理 target 节点
      #
      # @param [String] target
      # @param [MpaasInfo] mpaas_info
      #
      def handle_target_node(target, mpaas_info)
        UILogger.debug("添加 target 节点: #{target}")
        target_node = @root.find(target)
        raise "编辑的 target 不存在: #{target}" if target_node.nil?
        # 取当前 target 信息，避免多次生成
        target_info = mpaas_info[target]
        # 按顺序处理节点
        handle_header_node!(target_node, target_info)
        handle_pch_node!(target_node, target_info)
        handle_module_category_node!(target_node, target_info)
        handle_app_info_node!(target_node)
        handle_sg_image_node!(target_node, target_info)
      end

      # 处理头文件节点
      # 只有增改操作
      #
      # @param target_node [MpaasNode] target 节点
      # @param target_info [MpaasTargetInfo] target 框架信息
      #
      def handle_header_node!(target_node, target_info)
        name, template, op = target_info.header
        # 如果未集成模块，不添加header节点
        return if name.nil?
        # 添加节点，保证空框架和加载已有框架时节点存在，已存在节点不会处理
        GeneratorAction.operate!(target_node, name, template, :normal, :add)
        update_phase_action do
          # 更新框架时 add 操作内部处理，避免重复添加
          GeneratorAction.operate!(target_node, name, template, :normal, op)
          GeneratorAction.store!(target_node, name, target_node.name, op)
        end
      end

      # 处理pch节点
      # 只有增改操作
      #
      # @param target_node [MpaasNode] target 节点
      # @param target_info [MpaasTargetInfo] target 框架信息
      #
      def handle_pch_node!(target_node, target_info)
        header_file, op = target_info.pch
        # 如果未集成模块，不添加pch节点
        return if header_file.nil?
        # 处理节点
        project_pch_path = XcodeHelper.search_pch_path(@project.xcodeproj_path, target_node.name)
        pch_template = TemplatesFactory.load_template(:pch,
                                                      :header_file => header_file,
                                                      :project_pch => project_pch_path,
                                                      :remove => op == :del)
        pch_file_name = pch_template.products.shift
        # 保证节点存在
        GeneratorAction.operate!(target_node, pch_file_name, pch_template, :normal, :add)
        update_phase_action do
          # 只有增改操作
          op = :alt if op != :add
          GeneratorAction.operate!(target_node, pch_file_name, pch_template, :normal, op)
          GeneratorAction.store!(target_node, pch_file_name, target_node.name, op)
        end
      end

      # 处理模块分类文件节点
      #
      # @param target_node [MpaasNode] target 节点
      # @param target_info [MpaasTargetInfo] target 框架信息
      #
      def handle_module_category_node!(target_node, target_info)
        target_info.categories.each do |category_dir_name, category_name, category_template, op|
          m_node = target_node.find(category_dir_name)
          # 先处理模块节点，再处理分类节点，只添加一次，放在外层，防止框架初始化的时候 mpaas info 为空不走
          m_node ||= GeneratorAction.operate!(target_node, category_dir_name, nil, :group, :add)
          # 保证节点存在
          GeneratorAction.operate!(m_node, category_name, category_template,
                                   category_name.end_with?('.m') ? :source : :normal, :add)
          update_phase_action do
            GeneratorAction.operate!(m_node, category_name, category_template,
                                     category_name.end_with?('.m') ? :source : :normal, op)
            GeneratorAction.store!(m_node, category_name, target_node.name, op)
          end
        end
      end

      # 处理应用信息节点
      # 只有增改操作
      #
      # @param target_node [MpaasNode] target 节点
      #
      def handle_app_info_node!(target_node)
        # 生成 app info 节点
        GeneratorAction.operate!(target_node, Constants::APP_INFO_FILE_NAME,
                                 basic_info.app_info, :normal, :add)
        update_phase_action do
          is_active = target_node.name == @project.active_target
          # 本地化标记为 alt
          GeneratorAction.operate!(target_node, Constants::APP_INFO_FILE_NAME,
                                   basic_info.app_info, :normal, is_active ? :alt : :none)
          # 集成标记为 add
          GeneratorAction.store!(target_node, Constants::APP_INFO_FILE_NAME,
                                 target_node.name, is_active ? :add : :none)
        end
      end

      # 处理无线保镖图片节点
      # 只有增改操作
      #
      # @param target_node [MpaasNode] target 节点
      #
      def handle_sg_image_node!(target_node, target_info)
        # 无线保镖图片内容
        sg_image_content = SGImageGenerator.image_bin(basic_info.app_info[Constants::CONFIG_BASE64_CODE_KEY])
        # 保证节点存在
        GeneratorAction.operate!(target_node, Constants::SG_IMAGE_FILE_NAME,
                                 sg_image_content, :resource, :add)
        update_phase_action do
          is_active = target_node.name == @project.active_target
          exist = (@project.src_root + target_node.find(Constants::SG_IMAGE_FILE_NAME).path).exist?
          # 本地化标记为 alt / none 私有云取不到值，公有云
          # 导入配置文件时，不管本地文件是否存在，导入私有云不替换，否则全替换
          # 其它情况，本地文件存在，不替换（防止配置文件的内容不正确覆盖掉图片内容），否则全替换
          pre_condition = target_info.empty? ? sg_image_content.nil? : exist
          op = pre_condition || !is_active ? :none : :alt
          GeneratorAction.operate!(target_node, Constants::SG_IMAGE_FILE_NAME,
                                   sg_image_content || '', :resource, op)
          # 集成标记为 add
          GeneratorAction.store!(target_node, Constants::SG_IMAGE_FILE_NAME,
                                 target_node.name, is_active ? :add : :none)
        end
      end
    end
  end
end
