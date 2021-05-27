# Copyright (c) 2021 Oracle and/or its affiliates.

require 'json'

file_name = 'repolinter_results.json'

if ARGV.length > 0
  file_name = ARGV[0]
end

if ENV.include?('INPUT_JSON_RESULTS_FILE') && ENV['INPUT_JSON_RESULTS_FILE'].to_s.length > 0
  file_name = ENV['INPUT_JSON_RESULTS_FILE']
end

if !File.exist?(file_name)
  puts "ERROR - invalid (missing) file name given: #{file_name}"
  exit(1)
end

file_data = ''
open(file_name) do |f|
  file_data += f.read
end

if file_data.length <= 0
  puts "WARNING - no data read (0 byte JSON file)."
  
  puts "::set-output name=passed::true"
  puts "::set-output name=errored::false"
  puts "::set-output name=readme_file_found::true"
  puts "::set-output name=readme_file_details::Unable to read input JSON file (#{filename})"
  puts "::set-output name=license_file_found::true"
  puts "::set-output name=license_file_details::Unable to read input JSON file (#{filename})"
  puts "::set-output name=blacklisted_words_found::true"
  puts "::set-output name=blacklisted_words_details::Unable to read input JSON file (#{filename})"
  puts "::set-output name=copyright_found::true"
  puts "::set-output name=copyright_details::Unable to read input JSON file (#{filename})"
  
  exit(0)
end

json_data = JSON.parse(file_data)

unapproved_licenses = {}

def markdown_message(result = 'PASSED', message = '')
  ret = ''
  
  if result == 'PASSED'
    ret = ":white_check_mark: - #{message}"
  elsif result == 'NOT_PASSED_WARN'
    ret = ":warning: - #{message}"
  elsif result == 'NOT_PASSED_ERROR'
    ret = ":x: - #{message}"
  else
    ret = message
  end
  
  return ret
end

puts "::set-output name=passed::#{json_data['passed']}"
puts "::set-output name=errored::#{json_data['errored']}"


json_data['results'].each do |f|
  if f['ruleInfo']['name'] == 'readme-file-exists'
    puts "::set-output name=readme_file_found::#{f['status'] == 'PASSED' ? 'true' : 'false'}"
    
    msg = ""
    f['lintResult']['targets'].each do |t|
      msg += "<br />" if msg.length > 0
      msg += markdown_message("#{t['passed'] == true ? 'PASSED' : 'NOT_PASSED_ERROR'}", "#{t['path']}: #{t['message']}")
    end
    puts "::set-output name=readme_file_details::#{msg}"
  elsif f['ruleInfo']['name'] == 'license-file-exists'
    puts "::set-output name=license_file_found::#{f['status'] == 'PASSED' ? 'true' : 'false'}"
    
    msg = ""
    f['lintResult']['targets'].each do |t|
      msg += "<br />" if msg.length > 0
      msg += markdown_message("#{t['passed'] == true ? 'PASSED' : 'NOT_PASSED_ERROR'}", "#{t['path']}: #{t['message']}")
    end
    puts "::set-output name=license_file_details::#{msg}"
  elsif f['ruleInfo']['name'] == 'blacklist-words-not-found'
    puts "::set-output name=blacklisted_words_found::#{f['status'] == 'PASSED' ? 'false' : 'true'}"
    
    msg = ""
    f['lintResult']['targets'].each do |t|
      msg += "<br />" if msg.length > 0
      msg += markdown_message("#{t['passed'] == true ? 'PASSED' : 'NOT_PASSED_ERROR'}", "#{t['path']}: #{t['message']}")
    end
    puts "::set-output name=blacklisted_words_details::#{msg}"
  elsif f['ruleInfo']['name'] == 'copyright-notice-present'
    puts "::set-output name=copyright_found::#{f['status'] == 'PASSED' ? 'true' : 'false'}"
    
    msg = ""
    f['lintResult']['targets'].each do |t|
      msg += "<br />" if msg.length > 0
      msg += markdown_message("#{t['passed'] == true ? 'PASSED' : 'NOT_PASSED_WARN'}", "#{t['path']}: #{t['message']}")
    end
    puts "::set-output name=copyright_details::#{msg}"
  end
end
