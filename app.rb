require "roda"
require "sequel"

class PlanningPoker < Roda
  plugin :json

  VALID_VOTES = [1, 2, 3, 5, 8, 13, 20, 40]
  h = {}

  route do |r|
    r.on "help" do
      # TODO
    end

    r.on "poker" do
      command = r.params["text"]
      user_name = r.params["user_name"]
      channel_id = r.params["channel_id"]

      if command.include?("deal")
        if h[channel_id]
          {
            response_type: "in_channel",
            text: "Poker has already begun.",
            mrkdwn: true
          }
        else
          h[channel_id] = {}
          {
            response_type: "in_channel",
            text: "Starting game!",
            mrkdwn: true
          }
        end
      elsif command.include?("vote")
        if h[channel_id].nil?
          {
            response_type: "in_channel",
            text: "Please deal first.",
            mrkdwn: true
          }
        elsif !h[channel_id][user_name].nil?
          {
            response_type: "in_channel",
            text: "You already voted.",
            mrkdwn: true
          }
        else
          vote = command.split("vote").last.to_i
          if VALID_VOTES.include?(vote)
            h[channel_id][user_name] = vote
            {
              response_type: "in_channel",
              text: "#{user_name} voted #{vote}.",
              mrkdwn: true
            }
          else
            {
              response_type: "in_channel",
              text: "Number must be a valid vote.",
              mrkdwn: true
            }
          end
        end
      elsif command.include?("tally")
        if !h[channel_id].nil?
          if h[channel_id].count == 0
            text = "No one has voted."
          elsif h[channel_id].count == 1
            text = "#{h[channel_id].keys.first.capitalize} has voted."
          else
            text = "#{h[channel_id].keys.map(&:capitalize).join(", ")} have voted."
          end
          {
            response_type: "in_channel",
            text: text,
            mrkdwn: true
          }
        end
      elsif command.include?("reveal")
        if !h[channel_id].nil? and h[channel_id].any?
          votes = {}
          h[channel_id].each do |_, v|
            votes[v] = v
          end
          if votes.count == 1
            puts votes.inspect
            text = "Everyone agrees! This is a #{votes.keys.first} point task!"
          else
            text = "No concensus reached. What a drag! Play again."
          end
          h.delete(channel_id)
          {
            response_type: "in_channel",
            text: text,
            mrkdwn: true
          }
        end
      else
        {
          response_type: "in_channel",
          text: "Welp",
          mrkdwn: true
        }
      end
    end
  end
end