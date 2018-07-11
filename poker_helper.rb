module PokerHelper
  def game_started?
    !h[channel_id].nil?
  end

  def can_vote?
    return unless game_started?
    h[channel_id][user_name].nil?
  end
end