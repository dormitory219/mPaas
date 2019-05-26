# frozen_string_literal: true

# entitlement_template.rb
# workspace
#
# Created by quinn on 2019-03-31.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 签名文件模块
  #
  class EntitlementTemplate < BaseTemplate
    def parse_ext_param(ext_param)
      @bundle_id = ext_param.fetch(:bundle_id)
      @user_id = ext_param.fetch(:user_id)
    end

    def edit
      label_hash = {
        'BUNDLEID' => @bundle_id,
        'USERID' => @user_id
      }
      FileProcessor.global_replace_file_content!(label_hash, working_dir + root_name)
    end

    def save(dest_path)
      FileUtils.mv(working_dir + root_name, dest_path)
    end

    def root_name
      'entitlements.plist'
    end

    def products
      ['entitlements.plist']
    end
  end
end
