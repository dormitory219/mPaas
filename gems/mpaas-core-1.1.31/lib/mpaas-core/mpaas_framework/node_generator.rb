# frozen_string_literal: true

# node_generator.rb
# MpaasKit
#
# Created by quinn on 2019-01-11.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class MpaasFramework
    # 节点生成器
    #
    class NodeGenerator
      require_relative 'node_factory'
      require_relative 'generator_action'
      require_relative 'node_generator/target_node_generator'

      include BasicInfo::Mixin

      # 初始化
      #
      # @param project [XCProjectObject] 工程对象
      #
      def initialize(project)
        @project = project
        @root = nil
        @update_phase = false
      end

      # 生成节点树
      #
      # @param mpaas_info [MpaasInfo] mpaas 框架信息
      # @return [MpaasNode] 整个框架的根节点
      #
      def generate(mpaas_info)
        UILogger.info('初始化构造 mPaaS 框架')
        # 初始化框架
        init_outline_structure
        # 生成框架根节点
        generate_root(mpaas_info)
      end

      # 重新生成节点树
      #
      # @param updated_mpaas_info [MpaasInfo] 更新的 mpaas 框架信息
      #
      def regenerate(updated_mpaas_info)
        UILogger.info('刷新 mPaaS 框架节点信息')
        @update_phase = true
        # 用更新后的信息，生成框架根节点
        generate_root(updated_mpaas_info)
      end

      private

      # 初始化概要结构
      # 以 MpaasNode 为节点的树状结构
      #
      def init_outline_structure
        @root = NodeFactory.create(:group, Constants::MPAAS_GROUP_KEY)
        targets_node = NodeFactory.create(:group, Constants::TARGETS_GROUP_KEY)
        # 为所有 target 添加 node
        @project.targets.each { |name| targets_node.append_child(NodeFactory.create(:group, name)) }
        @root.append_child(targets_node)
        @root.append_child(NodeFactory.create(:group, Constants::RESOURCES_GROUP_KEY))
        @root.append_child(NodeFactory.create(:group, Constants::FRAMEWORKS_GROUP_KEY))
      end

      # 处理 mpaas 框架信息
      #
      # @param mpaas_info [MpaasInfo] mpaas 框架信息
      # @return [MpaasNode] 整个框架的根节点
      #
      def generate_root(mpaas_info)
        # 如果导入数据，只处理 target 节点
        handle_mpaas_file_node(mpaas_info) unless mpaas_info.empty?
        # 处理各个 target 节点
        @project.targets.each { |target_name| handle_target_node(target_name, mpaas_info) }
        handle_frameworks_node(mpaas_info) unless mpaas_info.empty?
        handle_resources_node(mpaas_info) unless mpaas_info.empty?
        @root
      rescue StandardError
        @root&.close
        raise
      end

      # 执行更新节点操作
      #
      # @param &block 更新操作 block
      #
      def update_phase_action
        return unless @update_phase
        # 更新操作
        yield if block_given?
      end

      # 配置信息节点
      #
      def handle_mpaas_file_node(mpaas_info)
        UILogger.debug('处理配置信息节点')
        node_name = @project.mpaas_file.name
        mpaas_file_node = @root.find(node_name)
        op = mpaas_file_node.nil? ? :add : :alt
        mpaas_file_node ||= NodeFactory.create(:normal, node_name, mpaas_info.dump)
        @root.insert_child(0, mpaas_file_node) if op == :add
        update_phase_action do
          # 如果所有模块都被移除，就标记删除
          op = :del if @project.mpaas_targets.reject { |target| mpaas_info[target].empty? }.empty?
          # 更新/添加内容及引用标记
          GeneratorAction.operate!(@root, node_name, mpaas_info.dump, :normal, op)
          GeneratorAction.store!(@root, @project.mpaas_file.name, @project.active_target, op)
        end
      end

      # frameworks 节点
      #
      # @param mpaas_info [MpaasInfo] 框架信息
      #
      def handle_frameworks_node(mpaas_info)
        UILogger.debug('添加 Frameworks 节点')
        frameworks_node = @root.find(Constants::FRAMEWORKS_GROUP_KEY)
        # 取各target节点全集添加
        @project.targets.flat_map { |t| mpaas_info[t].mpaas_frameworks }.each do |name, location, _|
          node = frameworks_node.find(name)
          # 节点存在就继续
          next unless node.nil?
          GeneratorAction.operate!(frameworks_node, name, location, :framework, :add)
        end
        update_phase_action do
          # 更新节点信息
          mpaas_info[@project.active_target].mpaas_frameworks.each do |name, location, op|
            # 如果当前是删除操作，但是其它target不同意删除，节点文件则不删除，其它情况以当前target为主
            op = :none if op == :del && !agree_del_operation(mpaas_info, name, :mpaas_frameworks)
            GeneratorAction.operate!(frameworks_node, name, location, :framework, op)
          end
          store_operation(frameworks_node, mpaas_info, :mpaas_frameworks)
        end
      end

      # resources 节点
      #
      # @param mpaas_info [MpaasInfo] 框架信息
      #
      def handle_resources_node(mpaas_info)
        UILogger.debug('添加 Resources 节点')
        resources_node = @root.find(Constants::RESOURCES_GROUP_KEY)
        # 取各target节点全集添加
        @project.targets.flat_map { |t| mpaas_info[t].mpaas_resources }.each do |name, location, _|
          node = resources_node.find(name)
          # 节点存在就继续
          next unless node.nil?
          GeneratorAction.operate!(resources_node, name, location, :resource, :add)
        end
        update_phase_action do
          # 更新节点信息
          mpaas_info[@project.active_target].mpaas_resources.each do |name, location, op|
            # 如果当前是删除操作，但是其它target不同意删除，节点文件则不删除，其它情况以当前target为主
            op = :none if op == :del && !agree_del_operation(mpaas_info, name, :mpaas_resources)
            GeneratorAction.operate!(resources_node, name, location, :resource, op)
          end
          store_operation(resources_node, mpaas_info, :mpaas_resources)
        end
      end

      # 保存各节点集成的操作类型
      # !!保证查找方法返回的数据结构一致
      #
      # @param [MpaasNode] parent_node
      # @param [MpaasInfo] mpaas_info
      # @param [Symbol] search_func 查找的方法
      #
      def store_operation(parent_node, mpaas_info, search_func)
        @project.mpaas_targets.each do |target|
          # 保存各target的操作类型
          mpaas_info[target].method(search_func).call.each do |name, _, op|
            # 非主 target 直接不处理引用
            op = :none if target != @project.active_target
            GeneratorAction.store!(parent_node, name, target, op)
          end
        end
      end

      # 是否同意删除操作
      # !!保证查找方法返回的数据结构一致
      #
      # @param [MpaasInfo] mpaas_info
      # @param [String] name
      # @param [Symbol] search_func 查找的方法
      # @return [Bool]
      #
      def agree_del_operation(mpaas_info, name, search_func)
        agree_del_op = true
        # 如果其它target有非删除的，则不可以删除
        @project.targets.reject { |t| t == @project.active_target }.each do |t|
          agree_del_op = mpaas_info[t].method(search_func).call.find do |n, _, op|
            n == name && op != :del
          end.nil?
          break unless agree_del_op
        end
        agree_del_op
      end
    end
  end
end
