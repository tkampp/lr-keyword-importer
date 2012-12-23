return {
	
	LrSdkVersion = 3.0,
	LrSdkMinimumVersion = 1.3, -- minimum SDK version required by this plug-in

	LrToolkitIdentifier = 'de.kampp.lightroom.keywordimporter',

	LrPluginName = LOC "$$$/KeywordImporter/PluginName=Keyword Importer",
	
	-- Add the menu item to the Library menu.
	
	LrLibraryMenuItems = {
	    {
		    title = LOC "$$$/KeywordImporter/CustomDialog=Import keywords from CSV File",
		    file = "KeywordImporter.lua",
		},		
	},
	VERSION = { major=1, minor=0, revision=1, build=831116, },

}


	