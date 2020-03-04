class Notifier
  def self.call(message, channel)
    payload = {
      body: {
        text: message,
        channel: channel
      }.to_json
    }
    Thread.new do
      HTTP.post(Config.slack_web_hook_url, payload)
    end
  end
end
