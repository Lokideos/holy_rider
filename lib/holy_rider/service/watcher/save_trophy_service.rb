# frozen_string_literal: true

module HolyRider
  module Service
    module Watcher
      class SaveTrophyService
        PLATINUM_STICKER = 'BQADAgADTwsAAkKvaQABElnJclGri9EC'

        def initialize(player_id, trophy_id, trophy_earning_time, initial)
          @player = Player.find(id: player_id)
          @trophy = Trophy.find(id: trophy_id)
          @trophy_earning_time = trophy_earning_time
          @initial = initial
        end

        def call
          # TODO: add service to also add earned date to join table via transaction
          @player.add_trophy(@trophy)
          trophy_acquisition = @player.reload.trophy_acquisitions.find do |acquisition|
            acquisition.trophy_id == @trophy.id
          end
          trophy_acquisition.update(earned_at: @trophy_earning_time)
          return if @initial

          HolyRider::Workers::ProcessTrophyTopUpdate.perform_async(@player.id)

          # TODO: probably should use ruby built-in url generators for this
          link = URI("http://#{ENV['FQDN']}/trophy?" \
                     "player_account=#{@player.trophy_account}&" \
                     "trophy_title=#{@trophy.trophy_name}&" \
                     "trophy_description=#{@trophy.trophy_description}&" \
                     "trophy_type=#{@trophy.trophy_type}&" \
                     "trophy_rarity=#{@trophy.trophy_earned_rate}&" \
                     "icon_url=#{@trophy.trophy_icon_url}&" \
                     "game_title=#{@trophy.game.title}").to_s
          message = "@#{@player.telegram_username} - <a href='#{link}'>" \
                    "#{@trophy.game.title} #{@trophy.game.platform}</a>"

          HolyRider::Service::Bot::SendChatMessageService.new(chat_id: ENV['PS_CHAT_ID'],
                                                              message: message).call
          return unless @trophy.trophy_type == 'platinum'

          HolyRider::Service::Bot::SendStickerService.new(chat_id: ENV['PS_CHAT_ID'],
                                                          sticker: PLATINUM_STICKER).call
        end
      end
    end
  end
end
