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
    agent.follow_meta_refresh = true,
    agent.ssl_version = 'SSLv3',

    # Notice that I use OpenSSL::SSL::VERIFY_NONE. 
    # That means you are theoretically vulnerable to 
    # man-in-the-middle attack, but that's not something 
    # I worry too much in this particular case
    agent.verify_mode = OpenSSL::SSL::VERIFY_NONE
  }

  # we have to be logged in to upload stuff
  agentGarmin.get('https://sso.garmin.com/sso/login?
    service=http%3A%2F%2Fconnect.garmin.com%2Fpost-auth%2Flogin&
    webhost=olaxpw-connect02.garmin.com&source=http%3A%2F%2Fconnect.garmin.com%2Fen-US%2Fsignin&
    redirectAfterAccountLoginUrl=http%3A%2F%2Fconnect.garmin.com%2Fpost-auth%2Flogin&
    redirectAfterAccountCreationUrl=http%3A%2F%2Fconnect.garmin.com%2Fpost-auth%2Flogin&
    gauthHost=https%3A%2F%2Fsso.garmin.com%2Fsso&locale=en_US&id=gauth-widget&
    cssUrl=https%3A%2F%2Fstatic.garmincdn.com%2Fcom.garmin.connect%2Fui%2Fcss%2Fgauth-custom-v1.0-min.css&clientId=GarminConnect&
    rememberMeShown=true&rememberMeChecked=false&createAccountShown=true&openCreateAccount=false&
    usernameShown=true&displayNameShown=false&consumeServiceTicket=false&initialFocus=true&embedWidget=false#')

  form = agentGarmin.page.forms.first

  # fill in user login and submit form
  form["username"] = username
  form["password"] = password
  form.submit

  Dir.glob("#{folder}/*.fit") do |eachFile|

    # Upload files only once and flag them afterwards
    uploadedFlagFile = "#{eachFile.to_s}.uploaded"
    next if File.exists?(uploadedFlagFile)

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
    File.new(uploadedFlagFile, "w")
  end
rescue Exception => e
	puts " => #{e.message} #{e.backtrace.inspect}"
end
