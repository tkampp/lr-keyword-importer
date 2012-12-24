lr-keyword-importer
===================

Description
-----------
Keyword Importer Plugin for Adobe Lightroom

Installation
------------
Just install the plugin with the Plugin Manager or copy the contents of the folder to the modules-folrder of your LightRoom installation. You will then see the plugin registered within LightRoom called "Keyword Importer". It registeres its menu option "Import keywords from CSV file" within the library menu.

Usage
-----
Just click on the menu entry "Import keywords from CSV file". 

![Calling the plugin within Lightroom](/Docs/screenshot-lr-1.png "Calling the plugin within Lightroom")

You can then select a CSV file that corresponds to the following simple syntax: Filename and Keyword-Path separated by ";". 

    D:\Users\Photos\IMG_1218241000.JPG;Location\Europe\Iceland\Region\Suðurland\Hengilssvæðið
    D:\Users\Photos\IMG_1218241000.JPG;Misc\Nature\River
    D:\Users\Photos\IMG_1218241000.JPG;People\Test

Please note that the filename of the image has to be imported into the Lightroom database previously. Keyword-Path will be created from scratch.
When keyword import runs it shows the number of keywords added and finally shows a message dialog when it is done.
If Lightroom does not find a photo in its catalog, these keywords will be skipped and put into a logfile.

Hints
-----
Please create chunks of CSV files. I noticed that performance decreases over time, so using smaller files might help.

Migration from ACDSee to LightRoom
----------------------------------
One of the pressing use cases and reason for this script, was my migration form ACDSee to Lightroom. In order to this, just do the following:

Export your ACDSee catalog to a XML file - this is described in detail on various pages:
* Select: Tools | Database | Export | Database | Export database information to a text file
* Exports the selected information to an XML-based text file. Select the check boxes next to the information you want to include.

Convert the XML file to the CSV file format described above:
* To do that I created a XSLT file and used saxon to perform the transformation. There are most certainly other ways that are better suited for repeating tasks or more error prone, but this was the quickest way for my own one-time-migration.
* The stylesheet might need some additional adjustments with respect to path, in order to get working in your environment (also do not forget to add the xml processing instruction at the top of the export file). 
* You can then perform the transformtion with <code>transform acdsee_export_example.xml acdsee_export2csv_example.xslt > lightroom_import.csv</code>
* These sample scripts are in the "Scripts" folder.

Troubleshooting
---------------
If something fails, check out the debug information.  
You can also take a look into the KeywordImporter.txt log file that is being written in the user home directory.

Environment
-----------
Tested with Adobe LightRoom 4.2 64bit using Windows 8.

Credits & Dependencies
----------------------
Uses and includes the debugging-toolkit in Version 1.5 (See http://www.johnrellis.com/lightroom/debugging-toolkit.htm)  
It also includes some functions borrwed from RcFileUtils.lua by Rob Cole, http://www.robcole.com 
