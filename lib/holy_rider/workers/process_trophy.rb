# frozen_string_literal: true

module HolyRider
  module Workers
    class ProcessTrophy
      include Sidekiq::Worker
      sidekiq_options queue: :trophies, retry: 5, backtrace: 20

      def perform(player_id, trophy_id, trophy_earning_time, initial)
        HolyRider::Service::Watcher::SaveTrophyService.new(player_id, trophy_id,
                                                           trophy_earning_time, initial).call
      end
    end
  end
end
