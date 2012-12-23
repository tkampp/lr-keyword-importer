--[[
------------------------------------------------------------------------------------

Filename:           KeywordImporter.lua                
					by Thorsten Kampp, https://twitter.com/@thorstenkampp
------------------------------------------------------------------------------------
							
Credits:			Methods readFile and closeFile from RcFileUtils.lua 
					by Rob Cole, http://www.robcole.com (see Origin below)
		
------------------------------------------------------------------------------------
Origin:             Please do not delete these origin lines, unless this file has been
                    edited to the point where nothing original remains... - thanks, Rob.

    		        The contents of this file is based on code originally written by
                    Rob Cole, robcole.com, 2008-09-02.

                    Rob Cole is a software developer available for hire.
                    For details please visit www.robcole.com
------------------------------------------------------------------------------------
	
--]]

local Require = require 'Require'.path ("../debugscript.lrdevplugin")
local Debug = require 'Debug'.init ()

require 'strict'

local LrDialogs = import 'LrDialogs'
local LrApplication = import 'LrApplication'
local LrLogger = import 'LrLogger'
local LrProgressScope = import 'LrProgressScope'
local LrFunctionContext = import 'LrFunctionContext'
local LrStringUtils = import 'LrStringUtils'

local catalog = LrApplication.activeCatalog()

local logger = LrLogger( 'KeywordImporter' ) 
logger:enable( "logfile" )

KeywordImporter = {} 
  
function KeywordImporter.runProcess()
			
    local selectedCSV = LrDialogs.runOpenPanel({title = "Import CSV file with images and keyword", prompt = "Select", canChooseFiles = true, canChooseDirectories = false, canCreateDirectories = false, allowsMultipleSelection = false, fileTypes = "csv"})				
	local keycnt = 0
	
	if selectedCSV == nil then
		LrDialogs.message("No file selected.")
		return
	end	
	local csvFile = selectedCSV[1]
	
	logger:info("Opening file " .. csvFile)
	
	local contents, msg =  KeywordImporter.readFile( csvFile )    	
	if msg ~= nil then
		LrDialog.message(msg)
		return		
	end
	
    if contents ~= nil then
		
		local lines = KeywordImporter.split( contents, "\n" )
		
		LrFunctionContext.callWithContext( 'Keyword_Import', function (context)

			local numberDone = 0
			local totalCount = #lines			
			local skipped = 0
			
			local progressScope = LrProgressScope{ 
				title = "Keyword Importer",
				caption = "Importing " .. tostring(totalCount) .. " keywords." ,
				functionContext = context,
			}			
		
			progressScope:setCancelable( true )
			
			for  no,line in ipairs( lines ) do
			
				numberDone = numberDone + 1
				progressScope:setPortionComplete(numberDone, totalCount)				
				
				local caption = "Imported " .. tostring(keycnt) .. " of " .. tostring(totalCount) .. " keywords. "
				if skipped > 0 then
					caption = caption .. " (" .. tostring(skipped) .. " Skipped)"
				end
				
				progressScope:setCaption(caption)
				
				if progressScope:isCanceled() then break end			
			
				local parsedLine = KeywordImporter.split( line, ";" )			
				if parsedLine ~= nil then
				
					local filenameWithPath = parsedLine[1]
					local keywordPath = parsedLine[2]
					
					if filenameWithPath ~= nil and keywordPath ~= nil then
					
						-- Find photo first
						local affectedPhoto = catalog:findPhotoByPath( filenameWithPath )
						if affectedPhoto == nil then
							skipped = skipped + 1
							logger:warn( "findPhotoByPath with no result for photo=" .. filenameWithPath .. ",keyword=" .. keywordPath)											
						else					
							local keywordsSplitted = KeywordImporter.split( keywordPath, "\\" )		
																								
							local selectedKeyword = nil									
							catalog:withWriteAccessDo("createKeywordPath", function ()  				
								-- Create keywords			
								local parentKeyword = nil								
								for  keycnt,singleKeyword in ipairs( keywordsSplitted ) do				
									selectedKeyword = catalog:createKeyword( singleKeyword, {}, true, parentKeyword, true )	
									if selectedKeyword ~= nil then
										-- Iterate
										parentKeyword = selectedKeyword
									else 
										break
									end
								end	
							end)				
										
							if selectedKeyword ~= nil then			
																		
								-- Associate keywords
								catalog:withWriteAccessDo("associateKeyword", Debug.showErrors (function ()  									
									affectedPhoto:addKeyword( selectedKeyword )			
								end))		
								keycnt = keycnt + 1 
								
							else
								skipped = skipped + 1
								logger:warn( "keyword could not be selected for photo=" .. filenameWithPath .. ",keyword=" .. keywordPath)									
							end	
						end
					end
				else
					skipped = skipped + 1
					logger:warn( "KeywordImporter could not read data for no=" .. tostring(numberdone) .. ",line=" .. line)
				end
			end
		end	
		)
	else
		logger:error( "Message :" .. msg)
	end 
	
	logger:info( "Created " .. tostring(keycnt) .. " keywords." )
	LrDialogs.message( "Finished parsing " .. csvFile .. " and associated " .. tostring(keycnt) .. " keywords.")
	
end 

function KeywordImporter.split( str, delimiter )
    if str == nil then return nil end
    if str == '' then return {} end
    local token = {}
    local p = 1
    repeat
        local start, stop = str:find(delimiter, p, true)
        if start then
            token[#token+1] = LrStringUtils.trimWhitespace(str:sub(p,start-1))
            p = stop + 1
        else
            token[#token+1] = LrStringUtils.trimWhitespace(str:sub(p))
            break
        end
    until false
    return token
end

function KeywordImporter.closeFile( fileHandle )
    local ok = pcall( fileHandle.close, fileHandle )
    return ok
end

function KeywordImporter.readFile( filePath )
    local msg = nil
    local contents = nil
    local ok, fileOrMsg = pcall( io.open, filePath, "rb" )
    if ok and fileOrMsg then
        local contentsOrMsg
        ok, contentsOrMsg = pcall( fileOrMsg.read, fileOrMsg, "*all" )
        if ok then
            contents = contentsOrMsg
        else
            msg = LOC( "$$$/X=Read file failed, path: ^1, additional info: ^2", filePath, tostring( contentsOrMsg ) )
        end
        KeywordImporter.closeFile( fileOrMsg ) -- ignore return values.
    else
        msg = LOC( "$$$/X=Unable to open file for reading, path: ^1, additional info: ^2", filePath, tostring( fileOrMsg ) )
    end
    return contents, msg
end

import 'LrTasks'.startAsyncTask( Debug.showErrors (KeywordImporter.runProcess) )
