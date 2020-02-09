# frozen_string_literal: true

module HolyRider
  module Service
    module Command
      class HunterGearUp
        def initialize(command, message_type)
          @command = command
          @message_type = message_type
        end

        def call
          player = Player.find(telegram_username: @command[@message_type]['from']['username'])
          return unless player.admin?

          message = @command[@message_type]['text'].split(' ')
          name = message[1]
          sso_cookie = message[2]
          trophy_hunter = TrophyHunter.find(name: name)
          result = trophy_hunter&.full_authentication(sso_cookie)

          result ? ["#{name} locked & load"] : ["#{name} не смог аутентифицроваться"]
        end
      end
    end
  end
end
