GarminFitFilesUploader
======================

Simple script that helps you uploading your activities (.fit files) to garmin connect.

Usage is pretty easy:

	$ GarminFitFilesUploader.rb USERNAME PASSWORD ACTIVITIES_FOLDER

		> USERNAME: Your garmin connect username
		> PASSWORD: Your garmin connect user password
		> ACTIVITIES_FOLDER: Upload all .fit in this folder to garmin connect

Requirements:

  # 'mechanize' is used to automate interactions with the garmin connect site
  $ gem install mechanize
