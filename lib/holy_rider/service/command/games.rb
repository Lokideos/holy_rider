# frozen_string_literal: true

module HolyRider
  module Service
    module Command
      class Games
        def initialize(command, message_type)
          @command = command
          @message_type = message_type
        end

        def call
          game_title = @command[@message_type]['text'].split(' ')[1..-1].join(' ')
          games_list = Game.relevant_games(game_title, @command, @message_type)
          return unless games_list

          player_username = @command[@message_type]['from']['username']
          message = []
          message << "@#{player_username}"
          message << '<b>Найденные игры:</b>'
          games_list.each_with_index do |game, index|
            message << "/#{index + 1} <b>#{game}</b>"
          end
          message << 'Игорь нет' if games_list.empty?

          [message.join("\n")]
        end
      end
    end
  end
end
