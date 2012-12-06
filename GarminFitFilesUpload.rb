#! /usr/bin/env ruby
# author: Livio Bieri
# usage:
# $ uploadGarminTracks.rb username password [FIT directory]

require 'mechanize'

begin
	username = ARGV[0] or raise('Please provide the username for your garmin account')
	password = ARGV[1] or raise("Please provide the password for '#{username}'")
  folder = ARGV[2] or raise('Please provide a folder which should be used to uploaded FIT files')

  agentGarmin = Mechanize.new { |agent|
    agent.follow_meta_refresh = true
  }

  # We have to be logged in to upload stuff
  agentGarmin.get('http://connect.garmin.com/') do |pageGarmin|
    signInPage = agentGarmin.click(pageGarmin.link_with(:text => 'Sign In'))
    homePage = signInPage.form_with(:name => 'login') do |login_form|
      login_form["login:loginUsernameField"] = username
      login_form["login:password"] = password
    end.submit

  Dir.glob("#{folder}/*.fit") do |eachFile|
    puts "Processing #{eachFile.to_s} ..."
    # Upload a single fit file
    agentGarmin.get('http://connect.garmin.com/api/upload/widget/manualUpload.faces') do |pageUpload|
      pageUpload.form_with(:id => 'uploadForm') do |upload_form|
        # they do some "fancy" javascript stuff to ensure the uploaded file
        # is valid (not too big, correct file format etc.) but in the end
        # they just POST it to to the URL below :-)
        upload_form.action = "/proxy/upload-service-1.1/json/upload/.fit"
        upload_form.file_uploads.first.file_name = eachFile.to_s
      end.submit
    end
  end
end
rescue Exception => e
	puts " => #{e.message} #{e.backtrace.inspect}"
end
