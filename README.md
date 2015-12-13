#Museum App
iOS App for the Museums to easily distribute extra content

##Setup
* Create a copy of Config.example.xcconfig in the MuseumApp directory called MuseumApp/Config.xcconfig
* Replace the BASEURL value with the URL to the server serving the app backend API

**More details on the way...**


#TODO List
It would be nice to get our hands on an actual device to test on to make sure
everything works outside of the simulator

####TODO List:
* Everything about the information page
  * Create a layout for the information page, more ViewControllers if necessary
  * Parse information data from API calls
  * Realm model for information
* Exhibit ViewControllers
  * All ExhibitViewControllers (Except Text in many cases)
    * Create Outlets to Views in Storyboard
    * Link data from exhibit properties to respective outlets
    * Get and display/load resource from local device
    * Might need to worry about synchronization if updates happened
    * Make sure media is displayed properly with autolayout
  * ExhibitVideoController
    * Figure out which view displays video
  * ExhibitAudioController
    * Figure out which view controls an audio file

####QOL Changes:
* Some kind of message if no outstanding events so not just a blank screen
Minor issues, not top priority:
* Might want to reorganize some of the API parsing logic out of the MainTableViewController.swift file
* Update ISO8601Transform to include support for optional ISO 8601 formats
* Event date currently pulled from startTime: can't really display multi-day/overnight events in any way
* Remove events from Realm after end time has passed?
* Media resources - Remove old media files if not referenced by any resource

####BEACONS!
* Have beacons (4), need to activate, we'll take it from there
* Use Eddystone protocol (I believe when I looked there was a pod for this)
* Add some kind of Tour? ViewController to select for live tracking with beacons (and add to menu)

####Backend TODO List:
* Create database and API entries for information content
* Figure out how to serve with SSL before final app deployment

NOTE:  MUST revert "App Transport Security Settings" -> "Allow Arbitrary Loads"
       before deployment (means must set up sever-side SSL)
