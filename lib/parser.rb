
class Parser
  LOGGER = VectorClient.new(type: :udp, host: 'vector', port: 9000)

  attr_accessor :feeds

  def initialize(feeds)
    self.feeds = feeds
  end

  def parse_feeds
    feeds.each do |feed|
      sleep 5
      feed_name, feed_url, feed_notify = feed['name'], feed['url'], feed['notify']
      puts "parsing #{feed_name}"
      last_checked_at = last_checked(feed_name)
      puts "Feed #{feed_name} last new at #{last_checked_at}"
      doc = load_xml(feed_url) || next

      doc.xpath('//item').each do |item|
        job_item = build_json(feed_name, item)

        if job_item[:published_at] > last_checked_at
          puts "Feed #{feed_name} new job found: #{job_item[:title]}"
          LOGGER.info(job_item)
          notify(job_item) if feed_notify
          update_marker(feed_name)
        end

      end
    end
  end

  private

    def build_json(feed_name, item)
      desc = item.at_xpath('description').content
      published_at = (Time.parse(item.at_xpath('pubDate').content).utc rescue 0)
      {
        feed_name: feed_name,
        title: item.at_xpath('title').content,
        link: item.at_xpath('link').content,
        description: item.at_xpath('description').content,
        published_at: published_at,
        day_period: day_period(published_at),
        country: parse_content(desc, 'country'),
        skills: parse_content(desc, 'skills').split(', '),
        week_day: week_day(published_at),
        age: (TimeDifference.between(published_at, Time.now.utc).humanize rescue 0)
      }
    end

    def day_period(published_at)
      return '' if published_at == 0
      hour = published_at.hour
      [(0..4),(5..9),(10..14),(15..19),(20..24)].each_with_object('') do |period, memo|
        memo = period.to_s.gsub('..','-') if period.include? hour
        break memo if memo.length > 0
      end
    end

    def last_checked(feed_name)
      touch_marker = "last_checked_at_#{feed_name}"
      File.new(touch_marker, 'a')
      File.mtime(touch_marker)
    end

    def update_marker(feed_name)
      File.write("last_checked_at_#{feed_name}", "")
    end

    def load_xml(path)
      Nokogiri::XML open(path)
    rescue Net::OpenTimeout
      false
    end

    def parse_content(content, type)
      matches = content.match(/#{type}.*: ?(.*)(?:\n|<b)/i)
      return '' unless matches
      matches.size > 1 ? matches[1].gsub(/ {2,}/,' ') : ''
    end

    def notify(job)
      message = <<MSG
      *Job:* #{job[:title]} has been added #{job[:age]} ago
      *From:* #{job[:country]}
      *Skills:* #{job[:skills].join(', ')}
      *Open link:* #{job[:link]}
MSG
      Notifier.call(message, Config.slack_channel)
    end

    def week_day(published_at)
      return 0 if published_at == ''
      day = published_at.wday
      day = 7 if day == 0
      day
    end
end
