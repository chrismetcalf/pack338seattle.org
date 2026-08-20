#!/usr/bin/env ruby
# frozen_string_literal: true

# Fetch the Groups.io calendar feed and write upcoming events to _data/events.yml
# so Jekyll can render them at build time.
#
# This replaces an older approach that fetched the .ics in the browser through
# public CORS proxies — those proxies went down, taking the events widget with
# them. Fetching server-side has no CORS problem, works with JavaScript off, and
# fails loudly in CI instead of silently in a visitor's browser.
#
# Run with TZ set to the pack's timezone so floating and TZID-qualified times
# land in the right zone:
#
#   TZ=America/Los_Angeles ruby script/fetch-events.rb
#
# Options:
#   --file PATH    parse a local .ics instead of fetching (for testing)
#   --limit N      keep at most N upcoming events (default 10)

require 'net/http'
require 'uri'
require 'yaml'
require 'time'
require 'date'

FEED_URL = 'https://pack338.groups.io/g/all/ics/12344147/2126990759/feed.ics'
OUTPUT = File.expand_path('../_data/events.yml', __dir__)
DEFAULT_LIMIT = 10

# --- iCal parsing -----------------------------------------------------------

# RFC 5545 folds long lines by inserting CRLF + a single space or tab.
def unfold(text)
  text.gsub(/\r\n/, "\n").gsub(/\r/, "\n").gsub(/\n[ \t]/, '')
end

# "DTSTART;TZID=America/Los_Angeles:20250917T183000" =>
#   ["DTSTART", {"TZID" => "America/Los_Angeles"}, "20250917T183000"]
def split_line(line)
  name_and_params, _, value = line.partition(':')
  return nil if value.nil? || _.empty?

  name, *raw_params = name_and_params.split(';')
  params = raw_params.each_with_object({}) do |param, acc|
    key, _sep, val = param.partition('=')
    acc[key.upcase] = val.delete('"') unless val.empty?
  end

  [name.upcase, params, value]
end

def unescape(value)
  value.gsub(/\\([\\;,nN])/) { |_m| %w[n N].include?(Regexp.last_match(1)) ? ' ' : Regexp.last_match(1) }
end

# Returns [Time or Date, all_day?]. Date-only values become Date so they render
# without a spurious midnight time.
def parse_datetime(value)
  case value
  when /\A(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})Z\z/
    [Time.utc($1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i, $6.to_i).getlocal, false]
  when /\A(\d{4})(\d{2})(\d{2})T(\d{2})(\d{2})(\d{2})\z/
    # Floating or TZID-qualified. We assume the feed's zone matches TZ, which is
    # true for this pack's calendar; a mismatch would shift times.
    [Time.local($1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i, $6.to_i), false]
  when /\A(\d{4})(\d{2})(\d{2})\z/
    [Date.new($1.to_i, $2.to_i, $3.to_i), true]
  end
end

def parse_events(ics)
  events = []
  current = nil
  # Only read properties inside VEVENT — VTIMEZONE blocks contain their own
  # DTSTART lines (the 1970 DST boundaries) that are not events.
  depth_component = nil

  unfold(ics).split("\n").each do |raw|
    line = raw.strip
    next if line.empty?

    if line == 'BEGIN:VEVENT'
      current = {}
      depth_component = 'VEVENT'
      next
    elsif line == 'END:VEVENT'
      events << current if current && current[:summary] && current[:start]
      current = nil
      depth_component = nil
      next
    elsif line.start_with?('BEGIN:')
      depth_component ||= line.split(':', 2).last
      next
    elsif line.start_with?('END:')
      depth_component = nil if current.nil?
      next
    end

    next unless current

    name, _params, value = split_line(line) || next

    case name
    when 'SUMMARY'  then current[:summary] = unescape(value)
    when 'LOCATION' then current[:location] = unescape(value)
    when 'URL'      then current[:url] = value if value.start_with?('http://', 'https://')
    when 'DTSTART'
      parsed, all_day = parse_datetime(value)
      next unless parsed

      current[:start] = parsed
      current[:all_day] = all_day
    when 'DTEND'
      parsed, = parse_datetime(value)
      current[:end] = parsed if parsed
    end
  end

  events
end

# --- Selection and output ---------------------------------------------------

def to_time(value)
  value.is_a?(Date) && !value.is_a?(DateTime) ? Time.local(value.year, value.month, value.day) : value.to_time
end

def upcoming(events, limit:, now: Time.now)
  events
    .select { |e| to_time(e[:start]) >= now }
    .sort_by { |e| to_time(e[:start]) }
    .first(limit)
end

def serialize(events)
  events.map do |event|
    entry = {
      'summary' => event[:summary],
      'start' => event[:start].is_a?(Date) && !event[:start].is_a?(DateTime) ? event[:start] : event[:start].iso8601,
      'all_day' => event[:all_day]
    }
    if event[:end]
      entry['end'] = event[:end].is_a?(Date) && !event[:end].is_a?(DateTime) ? event[:end] : event[:end].iso8601
    end
    entry['location'] = event[:location] if event[:location]
    entry['url'] = event[:url] if event[:url]
    entry
  end
end

# Groups.io rejects requests with the default Ruby user agent (403), so send a
# real one and follow the redirects it sometimes issues.
USER_AGENT = 'Mozilla/5.0 (compatible; Pack338SiteBuilder/1.0; +https://pack338seattle.org)'

def fetch(url, redirects_left: 3)
  uri = URI.parse(url)
  request = Net::HTTP::Get.new(uri, 'User-Agent' => USER_AGENT, 'Accept' => 'text/calendar, */*')

  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: uri.scheme == 'https',
                                                     open_timeout: 15, read_timeout: 30) do |http|
    http.request(request)
  end

  case response
  when Net::HTTPSuccess
    response.body
  when Net::HTTPRedirection
    raise 'Too many redirects fetching feed' if redirects_left.zero?

    fetch(URI.join(url, response['location']).to_s, redirects_left: redirects_left - 1)
  else
    raise "Feed returned HTTP #{response.code}"
  end
end

# --- Main -------------------------------------------------------------------

if $PROGRAM_NAME == __FILE__
  local_file = ARGV[ARGV.index('--file') + 1] if ARGV.include?('--file')
  limit = ARGV.include?('--limit') ? ARGV[ARGV.index('--limit') + 1].to_i : DEFAULT_LIMIT

  ics = local_file ? File.read(local_file) : fetch(FEED_URL)
  all_events = parse_events(ics)
  selected = upcoming(all_events, limit: limit)

  warn "Parsed #{all_events.size} events, #{selected.size} upcoming (TZ=#{Time.now.zone})"

  payload = {
    'events' => serialize(selected)
  }

  header = <<~HEADER
    # Generated by script/fetch-events.rb from the Groups.io calendar.
    # Do not edit by hand — .github/workflows/update-events.yml overwrites it.
    # Source: #{FEED_URL}
  HEADER

  body = payload['events'].empty? ? "events: []\n" : payload.to_yaml.sub(/\A---\n/, '')
  File.write(OUTPUT, header + body)

  warn "Wrote #{OUTPUT}"
end
