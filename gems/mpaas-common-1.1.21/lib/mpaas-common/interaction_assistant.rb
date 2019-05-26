# frozen_string_literal: true

# interaction_assistant.rb
# MpaasKit
#
# Created by quinn on 2019-02-23.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 交互助手
  #
  class InteractionAssistant
    # 命令行交互提示（带选项）
    #
    # @param message [String] 提示消息
    # @param possible_answers [Array] 提示的备选答案
    # @return [String] 选择的答案
    #
    def self.ask_with_answers(message, possible_answers)
      UILogger.console(message + "(#{possible_answers.join('/')})", :green)
      answer = ''
      loop do
        answer = gets.downcase.chomp
        break if possible_answers.map(&:downcase).include? answer
        UILogger.console("(#{possible_answers.join('/')})", :green)
      end
      answer
    end

    # 命令行交互提示（纯输入）
    #
    # @param message [String] 提示消息
    # @return [String] 输入的答案
    #
    def self.ask(message)
      UILogger.console(message, :green)
      gets.downcase.chomp
    end
  end
end
