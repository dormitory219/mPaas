# frozen_string_literal: true

# component.rb
# MpaasKit
#
# Created by quinn on 2019-02-23.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  class Command
    class Devkit
      # 生产基线配置
      #
      class Component < Devkit
        require_relative 'component_const'

        def summary
          '基线模块组件配置文件处理'
        end

        def define_parser(parser)
          parser.description = summary
          parser.add_argument('-o [PATH]',
                              :desc => '输出路径', :default => -> { FileUtils.pwd }) { |opt| @output = opt }
          parser.add_argument('--gen-package',
                              :desc => '生成 sdk 包') { |opt| @gen_package = opt }
        end

        def run(argv)
          super(argv)
          user_authentication do
            baseline_manager = BaselineManager.new
            baseline_manager.check_new_feature('0.0.0')
            baseline_manager.check_for_updates
            module_obj_list = baseline_manager.fetch_all_modules
            if @gen_package
              distribute_sdk(module_obj_list)
            else
              info = read_info(module_obj_list)
              File.open(Pathname.new(@output) + 'Component.json', 'wb') { |f| f.write(JSON.pretty_generate(info)) }
            end
          end
        end

        private

        def distribute_sdk(module_obj_list)
          module_obj_list.each do |module_obj|
            module_obj.framework_locations.each do |path|
              Dir.mktmpdir do |tmp_dir|
                prod_dir = tmp_dir + '/Products'
                FileUtils.mkdir_p(prod_dir)
                FileUtils.cp_r(path, prod_dir)
                zip_path = @output + "/#{module_obj.version.tr('.', '_')}.tgz"
                Dir.chdir(tmp_dir) { CommandExecutor.exec("tar czf #{zip_path} Products") }
              end
            end
          end
        end

        def extract_module_info(module_obj_list)
          module_obj_list.select(&:component?).map do |module_obj|
            { :name => ComponentConst.module_name_map[module_obj.name.to_sym], :title => module_obj.title,
              :description => module_obj.description, :releaseNote => module_obj.release_note,
              :system_dependencies => ComponentConst.system_dependency_map.fetch(module_obj.name.to_sym, []),
              :frameworks => module_obj.frameworks }
          end
        end

        def get_info_from_spec(name, version)
          spec_file = Pathname.new('/Users/quinn/.cocoapods/repos/alipay_wallet') +
                      name + version + "#{name}.podspec.json"
          spec_info = JSON.parse(File.read(spec_file))
          resources = [spec_info.fetch('resources', [])].flatten
          dependencies = spec_info.fetch('dependencies', {}).keys.map do |d|
            d.end_with?('.framework') ? d : d + '.framework'
          end
          [resources, dependencies]
        end

        def make_framework_info(module_obj_list, framework_elem, all_headers)
          name = framework_elem['artifactId']
          module_obj = module_obj_list.find { |m| m.name == name } ||
                       module_obj_list.find { |m| m.frameworks.map { |f| f.gsub('.framework', '') }.include?(name) }
          UILogger.debug("处理 #{name}")
          headers = all_headers.select { |header| header.start_with?('<' + name + '/') }
          version = framework_elem['version']
          resources, dependencies = get_info_from_spec(name, version)
          { :name => name + '.framework', :version => module_obj ? module_obj.version : version,
            :headers => headers, :resources => resources, :dependencies => dependencies }
        end

        def generate_component_info(frameworks, module_obj_list)
          component_info = { :baseline => '10.1.18', :updateTime => Time.now.to_i, :frameworks => [], :modules => [] }
          all_headers = module_obj_list.map(&:header_files).flatten.uniq
          component_info[:frameworks] = frameworks.map { |f| make_framework_info(module_obj_list, f, all_headers) }
          component_info[:modules] = extract_module_info(module_obj_list)
          component_info
        end

        def read_info(module_obj_list)
          res = 'curl -s https://huoban.alipay.com/api/rest' \
'\?apiCode\=baseline.search\&platform\=iOS\&apiCode\=baseline.search' \
'\&appKey\=891aab9276067dd23de6e5b08f26e212\&projectUniqueId\=cp_change_9628'
          frameworks_result = JSON.parse(`#{res}`)
          frameworks = frameworks_result['resultMes']['result']
          generate_component_info(frameworks, module_obj_list)
        end
      end
    end
  end
end
