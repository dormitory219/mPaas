# frozen_string_literal: true

# authenticator.rb
# MpaasKit
#
# Created by quinn on 2019-02-23.
# Copyright © 2019 alipay. All rights reserved.
#

module Mpaas
  # 身份认证
  #
  class Authenticator
    class << self
      # 用管理员身份登录
      #
      # @return [Bool]
      #
      def login_as_admin
        password = InteractionAssistant.ask('请输入管理员密码: ')
        output, status = CommandExecutor.exec('security find-certificate -c mpaaskit-dev -p')
        if status.success? && !output.empty?
          # 证书存在，验证密码
          cert = OpenSSL::X509::Certificate.new(output)
          pub_key = OpenSSL::PKey::RSA.new(cert.public_key)
          token = pub_key.public_decrypt(Base64.decode64(encrypted_token))
          password = 'ant' + password + '000'
          UILogger.debug('密码错误') if token != password
          return true if token == password
        end
        UILogger.debug('证书错误')
        false
      end

      private

      # 加密 token
      #
      # @return [String]
      #
      def encrypted_token
        'si6t5kx+e4yaVMVKpVdEzpeEilXFv6BMj39UmvcoCIlO5gDP6QavN9' \
        'qot9fsNI0nEzMZ8A2SR7YDmmi4bHr43Gm+Ec6M6Q0GqynEloP9B8EI' \
        'EGxBsYOG1VGkTV2ZF2fAhX8dywFxtPQZDZOVhgWapvGi6O08qGxsYI' \
        'thHhHckkcyXHaNiAgXT2T7aOJMGeHxTqRbuWN0abqC0l+nSbkJVR9P' \
        'QCzvhLWTnURlOOHeLACBFh0pGp+feUTJygdwtARuoQ8U5GmBaBjtVu' \
        'qSBI2gd34KAN4Gxs6udiWrCq+EbgpEWrw4jAHQmV7uyBk8T7W6kli8' \
        '/gX8PNZEIWSmfq131A=='
      end
    end
  end
end
