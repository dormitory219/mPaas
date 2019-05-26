# frozen_string_literal: true

# version_compare.rb
# MpaasKit
#
# Created by quinn on 2019-02-21.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 版本号比较
  #
  class VersionCompare
    # 版本对比
    #
    # @param [String] version 原始版本
    # @return [VersionCompare]
    #
    # e.g. VersionCompare.compare('1.0.0').with('1.0.1')
    #
    def self.compare(version)
      new(version)
    end

    # 初始化
    #
    # @param [String] version 原始版本号
    #
    def initialize(version)
      @base_version = version
    end

    # 版本比较
    #
    # @param [String] version 对比版本号
    # @return [Integer] 比较结果
    #         e.g. 1: 大于，0: 等于，-1: 小于
    #
    def compare_with(version)
      base_numbers = @base_version.split('.').map(&:to_i)
      cmp_numbers = version.split('.').map(&:to_i)
      count = [base_numbers.count, cmp_numbers.count].max
      # 补0
      base_numbers = base_numbers.fill(0, base_numbers.count..count - 1)
      cmp_numbers = cmp_numbers.fill(0, cmp_numbers.count..count - 1)
      # 元素比较
      base_numbers <=> cmp_numbers
    end
    alias with compare_with

    # 是否大于对比版本
    #
    # @param [String] version 对比版本号
    # @return [Bool]
    #
    def greater_than?(version)
      with(version).positive?
    end

    # 是否大于等于对比版本
    #
    # @param [String] version 对比版本号
    # @return [Bool]
    #
    def greater_than_or_equal?(version)
      !smaller_than?(version)
    end

    # 是否小于对比版本
    #
    # @param [String] version 对比版本号
    # @return [Bool]
    #
    def smaller_than?(version)
      with(version).negative?
    end

    # 是否小于等于对比版本
    #
    # @param [String] version 对比版本号
    # @return [Bool]
    #
    def smaller_than_or_equal?(version)
      !greater_than?(version)
    end

    # 是否等于对比版本
    #
    # @param [String] version 对比版本号
    # @return [Bool]
    #
    def equal_to?(version)
      with(version).zero?
    end
  end
end
