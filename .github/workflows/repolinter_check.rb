# frozen_string_literal: true
# Copyright (c) 2021 Oracle and/or its affiliates.

require 'json'

file_name = 'repolinter_results.json'

file_name = ARGV[0] unless ARGV.empty?

if ENV.include?('INPUT_JSON_RESULTS_FILE') && !ENV['INPUT_JSON_RESULTS_FILE'].to_s.empty?
  file_name = ENV['INPUT_JSON_RESULTS_FILE']
end

unless File.exist?(file_name)
  puts "ERROR - invalid (missing) file name given: #{file_name}"
  exit(1)
end

file_data = IO.read(file_name)

if file_data.length <= 0
  puts 'WARNING - no data read (0 byte JSON file).'

  puts '::set-output name=passed::true'
  puts '::set-output name=errored::false'
  puts '::set-output name=disclaimer_found::true'
  puts "::set-output name=disclaimer_details::Unable to read input JSON file (#{filename})"
  puts '::set-output name=readme_file_found::true'
  puts "::set-output name=readme_file_details::Unable to read input JSON file (#{filename})"
  puts '::set-output name=license_file_found::true'
  puts "::set-output name=license_file_details::Unable to read input JSON file (#{filename})"
  puts '::set-output name=blacklisted_words_found::true'
  puts "::set-output name=blacklisted_words_details::Unable to read input JSON file (#{filename})"
  puts '::set-output name=copyright_found::true'
  puts "::set-output name=copyright_details::Unable to read input JSON file (#{filename})"

  exit(0)
end

json_data = JSON.parse(file_data)

def markdown_message(result = 'PASSED', message = '')
  case result
  when 'PASSED'
    ":white_check_mark: - #{message}"
  when 'NOT_PASSED_WARN'
    ":warning: - #{message}"
  when 'NOT_PASSED_ERROR'
    ":x: - #{message}"
  else
    message
  end
end

puts "::set-output name=passed::#{json_data['passed']}"
puts "::set-output name=errored::#{json_data['errored']}"

json_data['results'].each do |f|
  case f['ruleInfo']['name']
  when /disclaimer-present/
    puts "::set-output name=disclaimer_found::#{f['status'] == 'PASSED' ? 'true' : 'false'}"

    msg = ''
    f['lintResult']['targets'].each do |t|
      msg += '<br />' unless msg.empty?
      msg += markdown_message(t['passed'] == true ? 'PASSED' : 'NOT_PASSED_ERROR', "#{t['path']}: #{t['message']}")
    end
    puts "::set-output name=disclaimer_details::#{msg}"
  when /readme-file-exists/
    puts "::set-output name=readme_file_found::#{f['status'] == 'PASSED' ? 'true' : 'false'}"

    msg = ''
    f['lintResult']['targets'].each do |t|
      msg += '<br />' unless msg.empty?
      msg += markdown_message(t['passed'] == true ? 'PASSED' : 'NOT_PASSED_ERROR', "#{t['path']}: #{t['message']}")
    end
    puts "::set-output name=readme_file_details::#{msg}"
  when /license-file-exists/
    puts "::set-output name=license_file_found::#{f['status'] == 'PASSED' ? 'true' : 'false'}"

    msg = ''
    f['lintResult']['targets'].each do |t|
      msg += '<br />' unless msg.empty?
      msg += markdown_message(t['passed'] == true ? 'PASSED' : 'NOT_PASSED_ERROR', "#{t['path']}: #{t['message']}")
    end
    puts "::set-output name=license_file_details::#{msg}"
  when /blacklist-words-not-found/
    puts "::set-output name=blacklisted_words_found::#{f['status'] == 'PASSED' ? 'false' : 'true'}"

    msg = ''
    f['lintResult']['targets'].each do |t|
      msg += '<br />' unless msg.empty?
      msg += markdown_message(t['passed'] == true ? 'PASSED' : 'NOT_PASSED_ERROR', "#{t['path']}: #{t['message']}")
    end
    puts "::set-output name=blacklisted_words_details::#{msg}"
  when /copyright-notice-present/
    puts "::set-output name=copyright_found::#{f['status'] == 'PASSED' ? 'true' : 'false'}"

    msg = ''
    f['lintResult']['targets'].each do |t|
      msg += '<br />' unless msg.empty?
      msg += markdown_message(t['passed'] == true ? 'PASSED' : 'NOT_PASSED_WARN', "#{t['path']}: #{t['message']}")
    end
    puts "::set-output name=copyright_details::#{msg}"
  end
end
