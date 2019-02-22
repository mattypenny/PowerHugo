﻿$DefaultImageUrlRoot = 'http://salisburyandstonehenge.net'
$DefaultDefaultImage = "http://salisburyandstonehenge.net/images/View%20of%20the%20spire%20from%20Salisbury%20Cathedral's%20cafe.JPG"
$DefaultImagePath = '/home/matt/salisburyandstonehenge.net/static/images'
$DefaultTwitterCard = "summary_large_image"
$DefaultTwitterSite = "@salisbury_matt"
$DefaultTwitterCreator = "@salisbury_matt"
<#
Needs to look like this:
twitter:
  card: "summary_large_image"
  site: "@salisbury_matt"
  creator: "@salisbury_matt"
  title: "9th January 1728 - Thomas Warton, Written at Stonehenge writer was born"
  description: "On this day, 9th January in 1728,  poet laureate Thomas Warton was born in Basingstoke. He wrote Written at Stonehenge."
  image: "https://salisburyandstonehenge.net/images/Thomaswarton.jpg"
  url: "http://salisburyandstonehenge.net/on-this-day/9th-january-1728-thomas-warton-written-at-stonehenge-writer-was-born"
         

#>

function Get-ExtractedTwitterCardText {
    [CmdletBinding()]
    param (
        $HugoMarkdownFile,
        [string]$Card = "summary_large_image",
        [string]$Site = $DefaultTwitterSite,
        [string]$Creator = $DefaultTwitterCreator,
        [string]$DescriptionMaxLength = 240,
        [string]$ImageUrlRoot = $DefaultImageUrlRoot,
        [string]$DefaultImage = $DefaultDefaultImage,
        [string]$UrlRoot = $DefaultUrlRoot,
        [string]$ImagePath = $DefaultImagePath
    )
    
    write-startfunction

    
    if (test-path $HugoMarkdownFile) 
    {
        write-dbg "Found files matching $HugoMarkdownFile"
    }
    else
    {
        $SplatParams = @{
            ExceptionName = "No such markdown files"
            ExceptionMessage = "No markdown files match $MultipleHugoMarkdownFiles"
            errorId = "ERR-042"            
            ErrorCategory = InvalidArgument
        }    
        write-dbg "$SplatParams.ExceptionName"
        ThrowError @SplatParams
    }

    $SplatParams = @{
        HugoMarkdownFile = $HugoMarkdownFile
        Card = $Card
        Site = $Site
        Creator = $Creator
        DescriptionMaxLength = $DescriptionMaxLength
        ImageUrlRoot = $ImageUrlRoot
        DefaultImage = $DefaultImage
        UrlRoot = $UrlRoot
        ImagePath = $ImagePath
    }
    
    
    $TwitterCardMetaData = Get-TwitterCardMetaData @SplatParams
    $TwitterCardMetaDataCount = $($TwitterCardMetaData | Measure-Object).count
    write-dbg "`$TwitterCardMetaDataCount: <$TwitterCardMetaDataCount>"
    


    $ExtractedTwitterCardText = ""
    foreach ($T in $TwitterCardMetaData) {
        [string]$Title = $T.Title
        [string]$ImageUrl = $T.ImageUrl
        [string]$Description = $T.Description
        [string]$Url = $T.Url
        
        write-dbg "Processing `$TwitterCardMetaData for `$Title: <$Title>"
        $ExtractedTwitterCardText += @"
$ExtractedTwitterCardText
twitter:
    card: $Card
    site: $Site
    creator: $Creator
    title: $Title
    description: $Description
    image: $ImageURL
    url: $URL
"@

    }

    write-endfunction

    write-dbg "`$ExtractedTwitterCardText: <$ExtractedTwitterCardText>"
    $ExtractedTwitterCardText
}

function Get-TwitterCardMetaData {
    [CmdletBinding()]
    param (
        $HugoMarkdownFile,
        [string]$Card = "summary_large_image",
        [string]$Site = $DefaultSite,
        [string]$Creator = $DefaultCreator,
        [string]$DescriptionMaxLength = 240,
        [string]$ImageUrlRoot = $DefaultImageUrlRoot,
        [string]$DefaultImage = $DefaultDefaultImage,
        [string]$UrlRoot = $DefaultUrlRoot,
        [string]$ImagePath = $DefaultImagePath
    )
    
    write-startfunction

    $MultipleHugoMarkdownFiles = $HugoMarkdownFile
    $TwitterMetaCardData = @()
    
    if (test-path $MultipleHugoMarkdownFiles) 
    {
        $ChildItems = Get-ChildItem $MultipleHugoMarkdownFiles -ErrorAction Continue
    }
    else
    {
        $SplatParams = @{
            ExceptionName = "No such markdown files"
            ExceptionMessage = "No markdown files match $MultipleHugoMarkdownFiles"
            errorId = "ERR-041"            
            ErrorCategory = InvalidArgument
        }    
        write-dbg "$SplatParams.ExceptionName"
        ThrowError @SplatParams
    }

    foreach ($H in $ChildItems)
    {
    
        [string]$HugoMarkdownFile = $H.fullname

        write-dbg "Picking out data for: `$HugoMarkdownFile <$HugoMarkdownFile>"
        if (!(test-path $HugoMarkdownFile)) {
            throw "HugoMarkdownFile $HugoMarkDownFile does not exist"
        }


        $HugoContent = get-HugoContent -HugoMarkdownFile $HugoMarkdownFile

        [string]$Title = $HugoContent.Title
        write-dbg "`$Title <$Title>"

        if ($HugoContent.URL)
        {
            [string]$URL = $UrlRoot + $HugoContent.URL
            write-dbg "In if `$URL: <$URL>"
        }
        else 
        {
            $FileDetails = Get-ChildItem $HugoMarkdownFile 
            
            [string]$URL = $FileDetails.Name
            $URL = $Url.TrimEnd('.md')
            $Url = $UrlRoot + '/' + $Url
            write-dbg "In else `$URL: <$URL>"

        }

        write-dbg "`$URL <$URL>"

        [string]$BodyText = $HugoContent.Body
        # get first image
        $Image = get-ImageDetails -PostPath $HugoMarkdownFile -ImagePath $ImagePath  | Select-Object -first 1

        if ($Image)
        {
            [string]$ImageUrl = $ImageUrlRoot + $Image.Image
            write-dbg "In if `$ImageUrl: <$ImageUrl>"
            if (!$Image.ImageExists)
            {
                Write-Warning "Image $ImageUrl does not exist"
            }
        }
        else 
        {
            $ImageUrl = $DefaultImage
            write-dbg "In else `$ImageUrl: <$ImageUrl>"
                
        }



        $Description = Get-DescriptionFromBodyText -BodyText  $BodyText -MaximumLength 240 

        $TwitterMetaCardData += [PSCustomObject]@{
            Title = $Title
            ImageUrl = $ImageUrl
            Description = $Description 
            Url = $Url
        }
    }

    $TwitterMetaCardData
    
}


function Get-DescriptionFromBodyText {
    [CmdletBinding()]
    param (
        [string]$BodyText,
        [int]$MaximumLength = 240        
    )
    # $DebugPreference = "Continue"

    write-startfunction
    
    write-dbg "Remove markup `$BodyText: <$BodyText>"
    [string]$ReturnString = Get-BodyTextWithMarkupRemoved -BodyText $BodyText

    
    write-dbg "Chop string `$ReturnString: <$ReturnString>"
    if ($ReturnString.Length -ge $MaximumLength) {
        [string]$ReturnString = $ReturnString.substring(0,$MaximumLength)
    }

    write-dbg "Locate full stop before the 240th charactor or use last charactor `$ReturnString: <$ReturnString>"

    [int]$LastFullStop = $ReturnString.lastindexof('.') + 1
    write-dbg "`$LastFullStop: <$LastFullStop>"
    if ($LastFullStop -gt 0) {
        $ReturnString = $ReturnString.substring(0, $LastFullStop)
    }
    
    write-dbg "Returning `$ReturnString: <$ReturnString>"
    
    write-endfunction
    # $DebugPreference = "SilentlyContinue"
    $ReturnString
}

function Get-BodyTextWithMarkupRemoved {
    [CmdletBinding()]
    param (
        [string]$BodyText        
    )
    write-startfunction
    
    write-dbg "Remove stuff in <>"
    $BodyText = Get-BodyTextWithMarkupRemovedForASpecificCharacter -BodyText $BodyText -StartMarkupString "<" -EndMarkupString ">"

    write-dbg "Remove stuff in []"
    $BodyText = Get-BodyTextWithMarkupRemovedForASpecificCharacter -BodyText $BodyText -StartMarkupString "[" -EndMarkupString "]"

    write-dbg "Remove stuff in ()"
    $BodyText = Get-BodyTextWithMarkupRemovedForASpecificCharacter -BodyText $BodyText -StartMarkupString "(" -EndMarkupString ")"

    $BodyText = $BodyText.replace('!','')
    
    $BodyText = $BodyText.replace("^`r","")
    $BodyText = $BodyText.replace("^`r","")

    $BodyText = $BodyText.replace("`r"," ")
    
    $BodyText = $BodyText.replace("^`n","")
    $BodyText = $BodyText.replace("^`n","")    
    $BodyText = $BodyText.replace("`n", " ")
    
    $BodyText = $BodyText.replace("^ ","")
    $BodyText = $BodyText.replace("^ ","")   
    
    $BodyText = $BodyText.replace("  "," ")  
    $BodyText = $BodyText.trimstart()    
    

    write-dbg "Returning `$BodyText: $BodyText"
    write-endfunction

    return $BodyText

}

function Get-BodyTextWithMarkupRemovedForASpecificCharacter {
    [CmdletBinding()]
    param (
        [string]$BodyText,
        [string]$StartMarkupString,
        [string]$EndMarkupString
                
    )
    write-startfunction

    [string]$BodyTextWithMarkupRemoved = ""
    [int]$BracketLevel = 0
    $Length = $BodyText.Length

    for ($i=0; $i -le $Length; $i++) {

        if ($BodyText[$i] -eq $StartMarkupString) {
            $BracketLevel = $BracketLevel + 1
        }
        if ($BracketLevel -eq 0) {
            $BodyTextWithMarkupRemoved = $BodyTextWithMarkupRemoved + $BodyText[$i]
        }

        if ($BodyText[$i] -eq $EndMarkupString) {
            $BracketLevel = $BracketLevel - 1
        }
    }

    if ($BracketLevel) {
        write-warning 'Brackets dont match up :('
    }

    $BodyTextWithMarkupRemoved.replace('  ',' ')
    write-endfunction
}

<#
.Synopsis
   Do a dir (get-childiem), but order by the 'Weight' defined in the Hugo front-matter
.DESCRIPTION
   For all the files in the path, do a listing, but order by the Hugo weight field..
.EXAMPLE
   Get-ContentByWeight *apr* 


    Directory: D:\onedrive\salisburyandstonehenge.net\content\on-this-day


Mode                LastWriteTime         Length Name                                                                                  
----                -------------         ------ ----                                                                                  
-a----       20/10/2016     17:39           1321 3rd-april-1969-desmond-dekker-play-the-alex-disco.md                                  
-a----       20/10/2016     17:40           1058 4th-april-1989-bbc-wiltshire-begins.md                                                
-a----       20/10/2016     17:39           1363 6th-april-1967-pink-floyd-play-salisbury-city-hall.md                                 
-a----       20/10/2016     17:40           1602 7th-april-1948-lester-piggott-rides-professionalyy-for-the-first-time-at-salisbury-rac
                                                 es.md                                                                                 
-a----       20/10/2016     17:39           1282 10th-april-1969-fairport-convention-play-the-alex-disco.md                            
-a----       23/11/2016     23:25           1594 14th-april-2013-more-swing-rioters-transported.md                                     
-a----       23/11/2016     23:09           1327 18th-april-1698-the-first-hms-salisbury-is-launched.md                                
-a----       05/11/2016     11:35            707 21th-apr-1965-the-kinks-play-the-city-hall.md                                         
-a----       20/10/2016     17:40            988 29th-april-2003-buzzcocks-play-salisbury-city-hall.md                                 
-a----       20/10/2016     17:40           3274 29th-april-1384-parliament-meets-in-the-bishops-palace-in-the-close.md         
#>
function Get-ChildItemByWeight
{
    [CmdletBinding()]
    [Alias()]
    Param
    (
        $Path = ".",
        $StartWeight = 0,
        $EndWeight = 999999
    )

    if (($Path.length - $Path.indexof('md')) -ne 2)
    {
	$Path = "$Path*md"
    }
    
    
    $MatchingFiles = foreach ($F in $(dir $Path))
    {
        $Filename = $F.name
	write-dbg "`$Filename: <$Filename>"
        $WeightMatch = select-string "Weight: " $Filename

        [string]$WeightLine = $WeightMatch.Line

	write-dbg "`$WeightLine: <$WeightLine>"
        [int]$Weight = $WeightLine.split(':')[1]


        $F | add-member -NotePropertyName Weight -NotePropertyValue $Weight
    
        $F
    }

    $MatchingFiles |
	where-object Weight -ge $StartWeight |
	where-object Weight -le $EndWeight |
	sort-object -property Weight
}

set-alias dird Get-ChildItemByWeight
set-alias dirow Get-ChildItemByWeight

function add-NextAndPreviousLinksToMarkdownFile {
<#
.SYNOPSIS
  Append next page and previous page links to Markdown Files based on the weighting
.DESCRIPTION
  Longer description

.PARAMETER folder
  Folder 

.EXAMPLE




#>
  [CmdletBinding()]
  Param( [string]$Folder = ".")
  
  write-startfunction
  
  $YamlFromAllTheFolders = foreach ($File in $Folder)
  {
      get-yaml $File
  }
  
  $SortedYamlFromAllTheFolders = $YamlFromAllTheFolders | sort-object -property weighting, url

  foreach ($Yaml in $SortedYamlFromAllTheFolders)
  {
    <# $File = $Yaml.????
   
    $PreviousNextText = "???"
    
    copy ??? ??? # take a backup
    
    "$PreviousText" >> $File
    #>
  }  
  write-endfunction
  return 
}

function get-HugoContent { 
<#
.SYNOPSIS
    Return the HugoContent as an object
.DESCRIPTION
    Todo: get it to work for Json and Toml
.PARAMETER HugoMarkdownFile

.EXAMPLE
     get-HugoContent -HugoMarkDownFile D:\hugo\sites\example.com\content\on-this-day\10th-june-1668-samuel-pepys-visits-salisbury.md

title           : 10th June 1668 - Samuel Pepys visits Salisbury
description     : 
lastmod         : 2016-06-07
date            : 2013-11-29
tags            : {pepys, literary, old george mall}
categories      : on-this-day
aliases         : /on-this-day/june/10th-june-1668-samuel-pepys-visits-salisbury
draft           : No
publishdate     : 2013-11-29
weight          : 610
markup          : md
url             : /on-this-day/june/10th-june-1668-samuel-pepys-visits-salisbury
unknownproperty : 
body            : 
                  
                  <a href="/images/Pepys_portrait_by_Kneller.png"><img src="/images/Pepys_portrait_by_Kneller-254x300.png" 
                  alt="Pepys_portrait_by_Kneller" width="254" height="300" class="alignright size-medium wp-image-9038" /></a></a>On the 10th June 
                  1667, Samuel Pepys stayed that night at the Old George Inn, now the Boston Tea Party cafe<a name="Source1" href="#Note1">[1]</a>.
                  
                  He had visited Old Sarum. The 'prodigous' 'great fortifications' did 'afright' him<a name="Source2" href="#Note2">[2]</a>  
                  
                  Full text
                  > 
                  > 10th. So come to Hungerford, where very good trouts, eels, and cray- fish.  Dinner:  a mean town.  At dinner there, 12s.  
                  Thence set out with a guide, who saw us to Newmarket-heath, and then left us, 3s. 6d.  
                  > 
                  > So all over the plain by the sight of the steeple (the plain high and low) to Salisbury by night; but before I came to the 
                  town, I saw a great fortification, and there light, and to it and in it; and find it prodigious, so as to fright me to be in it 
                  all alone at that time of night, it being dark.  I understand since it to be that that is called Old Sarum.  
                  > 
                  > Come to the George Inne, where lay in a silk bed; and very good diet.  To supper; then to bed.


.EXAMPLE
    $otd = get-HugoContent -f D:\hugo\sites\example.com\content\on-this-day\*July*    
    $otd | select date, title, weight | ft -AutoSize

date       title                                                                                                                  weight           
----       -----                                                                                                                  ------           
2014-02-26 6th July 1893 - Salisbury celebrates marriage of Duke of York to Princess Mary                                         706              
2013-11-04 22nd July 1654 - diarist John Evelyn visits Stonehenge                                                                 722              
2013-11-15 10th July 1899 - Barnum & Bailey's Greatest Show on Earth visits Salisbury                                             710              
2013-12-04 1st July 1906 - Salisbury rail disaster                                                                                701              
2013-12-04 1st July 1875 - Fisherton Jail opens to visitors                                                                       701              
2013-12-04 3rd July 1997 - the Independent reports that Gigant St brewery is closing                                              703              
2013-12-04 8th July 1858 - Bishop Hamilton consecrates the new Saint Andrew's Church                                              708              
2013-12-04 11th July 2012 - the Olympic torch arrives in Salisbury                                                                711 
#>
    [CmdletBinding()]
    Param( [string][Alias ("f")]$HugoMarkdownFile = "$pwd"  ) 

    write-startfunction

    $Files = dir $HugoMarkDownFile

    foreach ($File in $Files)
    {
        # $MarkdownLines = select-string -pattern '^' $File -encoding ascii
        $MarkdownLines = select-string -pattern '^' $File -encoding ascii

        $NumberOfMarkDownLines = $MarkdownLines | measure-object -Line
        write-dbg "`$NumberOfMarkDownLines: $NumberOfMarkDownLines"

    
        $PropertyCount = 0
        $YamlDividingLines = 0

        # initialize the output values
        $description = ""
        $lastmod = ""
        $date = ""
        $tags = @{}
        $categories = @{}
        $aliases = ""
        $draft = ""
        $publishdate = ""
        $weight = ""
        $markup = ""
        $url = ""
        $body = ""
        $card = ""
        $site = ""
        $creator = ""
        $title = ""
        $description = ""
        $image = ""
        $TwitterCardURL = ""

           
        <#
            Initialize the potentially multi-value and/or multi-line properties
        #>
        $TagString = ""
        $CategoriesString = ""
        $AliasesString = ""
        [int]$TitleCount = 0
        
        [Boolean]$TwitterCardFound = $False
               
        foreach ($MarkdownLine in $MarkDownLines)
        {
            [string]$Line = $MarkdownLine.Line
            if ($Line -like "---*")
            {
                $YamlDividingLines = $YamlDividingLines + 1
            }
            else
            {
                if ($YamlDividingLines -eq 1 -and $Line.trim() -ne "")
                {

                    <#
                        Retrieve Property Name and Line i.e. key and value
                    #>
                    $HugoNameAndValue = get-HugoNameAndFirstLineValue -FrontMatterLine $Line
                    [string]$PropertyName = $HugoNameAndValue.Propertyname
                    [string]$PropertyValue = $HugoNameAndValue.PropertyValue
 
                    $PropertyName = $PropertyName.Trim()
                    $PropertyValue = $PropertyValue.Trim()

                    write-dbg "`$PropertyName: <$PropertyName>"
                    write-dbg "`$PropertyValue: <$PropertyValue>"
    
                    $PropertyCount = $PropertyCount + 1
                
                    
                    switch ($PropertyName) 
                    {
                        "title" 
                        { 
                            write-dbg "in switch"; 
                            $title = $PropertyValue
                            $TitleCount = $TitleCount + 1
                            
                            if ($TitleCount -gt 1)
                            {
                                if ($TwitterCardFound -eq $True)
                                {
                                    
                                    $TwitterCardTitle = $PropertyValue
                                }
                            }
                        }
                        "description"
                        { 
                            write-dbg "$PropertyValue - in switch"; 
                            $description = $PropertyValue 
                        }
                        "lastmod"
                        { 
                            write-dbg "$PropertyValue - in switch"; 
                            $lastmod = $PropertyValue 
                        }
                        "date"
                        { 
                            write-dbg "$PropertyValue - in switch"; 
                            $date = $PropertyValue 
                        }
                        "tags" 
                        {
                            
                            write-dbg "$PropertyValue - in switch"; 
                            $TagString = $PropertyValue
                            
                        }
                        # aliases CAN be multiple, but I've not coded for this yet
                        "aliases"
                        { 
                            write-dbg "$PropertyValue - in switch"; 
                            $aliasesString = $PropertyValue 
                        }
                        "categories"
                        { 
                            write-dbg "$PropertyValue - in switch"; 
                            $categoriesString = $PropertyValue 
                        }
                    
                        "draft"
                        { 
                            write-dbg "$PropertyValue - in switch"; 
                            $draft = $PropertyValue 
                        }
                        "publishdate"
                        { 
                            write-dbg "$PropertyValue - in switch"; 
                            $publishdate = $PropertyValue 
                        }
                        "weight"
                        { 
                            write-dbg "$PropertyValue - in switch"; 
                            $weight = $PropertyValue 
                        }
                        "markup"
                        { 
                            write-dbg "$PropertyValue - in switch - markup"; 
                            $markup = $PropertyValue 
                        }
                        "url"
                        { 
                            write-dbg "$PropertyValue - in switch"; 
                            if ($TwitterCardFound)
                            {
                                $TwitterCardURL = $PropertyValue
                                write-dbg "`$TwitterCardURL: <$TwitterCardURL>"
                            }
                            else 
                            {
                                $url = $PropertyValue
                            } 
                        }  
                        "twitter"
                        { 
                            write-dbg "$PropertyValue - in switch"; 
                            $TwitterCardFound = $True
                        }
                        "card"
                        { 
                            write-dbg "$PropertyValue - in switch"; 
                            $Card = $PropertyValue 
                        }
                        "site"
                        { 
                            write-dbg "$PropertyValue - in switch"; 
                            $site = $PropertyValue 
                        }
                        "creator"
                        { 
                            write-dbg "$PropertyValue - in switch"; 
                            $creator = $PropertyValue 
                        }
                        "description"
                        { 
                            write-dbg "$PropertyValue - in switch"; 
                            $description = $PropertyValue 
                        }
                        "image"
                        { 
                            write-dbg "$PropertyValue - in switch"; 
                            $image = $PropertyValue 
                        }
                        <#
                            if the Property name is null, either it's an invalid line
                            or it's multiline
                        #>
                        ""
                        {
                            switch ($PropertyNameFromPreviousLine)
                            {
                                "tags"
                                { 
                                    write-dbg "in `$PropertyNameFromPreviousLine switch Tags"; 
                                    $TagString = "$TagString, $PropertyValue"
                                }
                        
                                "categories"
                                { 
                                    write-dbg "in `$PropertyNameFromPreviousLine switch categories `$PropertyValue: <$PropertyValue>"; 
                                    
                                    $StartofValue = $PropertyValue.indexof('-') + 1 
                                    $PropertyValue = $PropertyValue.substring($StartOfValue, $PropertyValue.length - $StartOfValue)
                                    $CategoriesString = "$CategoriesString~$PropertyValue"
                                    write-dbg "in `$PropertyNameFromPreviousLine switch: `$CategoriesString: <$CategoriesString>"; 
                                }
                        
                                "aliases"
                                { 
                                    write-dbg "in `$PropertyNameFromPreviousLine switch Aliases"; 
                                    $aliasesString = "$AliasesString, $PropertyValue"
                                }
                                "default"
                                {
                                    write-error "ERR010: There is an invalid line: Line: <$Line> PropertyName: <$PropertyName> PropertyValue <$PropertyValue>"
                                    write-error "ERR010: `$PropertyNameFromPreviousLine: <$PropertyNameFromPreviousLine>"
                                }
                             } 
                        }
    
                    
                        Default
                        { 
                                    write-error "ERR020: There is an invalid line: Line: <$Line> PropertyName: <$PropertyName> PropertyValue <$PropertyValue> File <$File>"
                        }
                                
    
                    }
                    if ($PropertyName)
                    {
                        $PropertyNameFromPreviousLine = $PropertyName
                    }
    
                }
                elseif ($YamlDividingLines -gt 1)
                {
                    <#
                        The front matter is over, so the rest is body
                    #>
                    write-dbg "Adding to body <$Line>"
                    $CarriageReturn = [char]13
                    $Body = @"
$Body$Line$CarriageReturn
"@
    
                }
            }
        }
        
        $Body = $Body.TrimStart('')

        $TagsArray = get-HugoValueArrayFromString -MultipleValueString $TagString -DElimiter ','
        $AliasesArray = get-HugoValueArrayFromString -MultipleValueString $AliasesString ','
        $CategoriesArray = get-HugoValueArrayFromString -MultipleValueString $CategoriesString '~'

        write-dbg @"
        Returning...
        [PSCustomObject]@{
            title = $title        
            description = $description
            lastmod = $lastmod
            date = $date
            tags = $tagsArray
            categories = $categoriesArray
            aliases = $aliasesArray
            draft = $draft
            publishdate = $publishdate
            weight = $weight 
            markup = $markup
            url = $url
            unknownproperty = $unknownproperty
            body = $body
            TwitterCard = $card
            TwitterSite = $site
            TwitterCreator = $creator
            TwitterTitle = $TwitterCardTitle
            TwitterImage = $image
            TwitterUrl = $Url
            TwitterDescription = $description
        }
"@

        [PSCustomObject]@{
            title = $title        
            description = $description
            lastmod = $lastmod
            date = $date
            tags = $tagsArray
            categories = $categoriesArray
            aliases = $aliasesArray
            draft = $draft
            publishdate = $publishdate
            weight = $weight 
            markup = $markup
            url = $url
            unknownproperty = $unknownproperty
            TwitterCard = $card
            TwitterSite = $site
            TwitterCreator = $creator
            TwitterTitle = $TwitterCardTitle
            TwitterImage = $image
            TwitterUrl = $Url
            TwitterDescription = $description
            body = $body

        }
            
    }
    write-endfunction

}


<#
vim: tabstop=4 softtabstop=4 shiftwidth=4 expandtab
#>

function get-HugoNameAndFirstLineValue {

<#
.SYNOPSIS
  Return property name and any value on the same line 
.DESCRIPTION
  

.PARAMETER FrontMatterLine
  Folder 

.EXAMPLE
#>
  [CmdletBinding()]
  Param( [string]$FrontMatterLine = ".")
  
  write-startfunction


  $PositionOfFirstColon = $FrontMatterline.IndexOf(':')
  if ($PositionOfFirstColon -eq -1)
  {
    $PositionOfFirstColon = 0
  }

  $PropertyName = $FrontMatterLine.Substring(0,$PositionOfFirstColon)
                
  $PropertyValue = $FrontMatterLine.Substring($PositionOfFirstColon +1  )
            
  $PropertyValue = $PropertyValue.trimstart(' ') 
  $PropertyValue = $PropertyValue.trimend(' ') 
  $PropertyValue = $PropertyValue.trimstart('"') 
  $PropertyValue = $PropertyValue.trimend('"') 

  write-dbg "Returning PropertyName <$PropertyName> PropertyValue <$PropertyValue>"

  [PSCustomObject]@{ 
    PropertyName = $PropertyName
    PropertyValue = $PropertyValue 
  }

}


function get-HugoValueArrayFromString {

<#
.SYNOPSIS
  
.DESCRIPTION
  

.PARAMETER MultipleValueString
  Folder 

.EXAMPLE
#>
  [CmdletBinding()]
  Param( [string]$MultipleValueString = '[ "pepys", "literary", "visitors"," old george mall", "high street" ]',
         [string]$Delimiter = ',')
  
  write-startfunction

  write-dbg "`$MultipleValueString: <$MultipleValueString>"
  $MultipleValueString = $MultipleValueString.trimstart('[')
  $MultipleValueString = $MultipleValueString.trimend(']')
  $MultipleValueString = $MultipleValueString.trim()
  $ValueArray = $MultipleValueString.split($Delimiter)
                        
  
  write-dbg "`$MultipleValueString: <$MultipleValueString>"


  $CleanedUpMultipleValueString = @{}                     
  $Values = foreach ($Value in $ValueArray)
  {
    write-dbg "1: `$Value: <$Value>"
    $Value = $Value.trim()
    write-dbg "2: `$Value: <$Value>"
    $Value = $Value.trim('"')
    $Value = $Value.trim()
    write-dbg "3: `$Value: <$Value>"
    if ($Value -ne "")
    {
      $Value 
    }
  }
  return $Values
}
#>


function set-HugoContent { 
<#
.SYNOPSIS
    Amends or creates Hugo markdown files
.DESCRIPTION
    Todo: get it to work for Json and Toml
.PARAMETER HugoMarkdownFile

.EXAMPLE
     

title           : 10th June 1668 - Samuel Pepys visits Salisbury
description     : 
lastmod         : 2016-06-07
date            : 2013-11-29
tags            : {pepys, literary, old george mall}
categories      : on-this-day
aliases         : /on-this-day/june/10th-june-1668-samuel-pepys-visits-salisbury
draft           : No
publishdate     : 2013-11-29
weight          : 610
markup          : md
url             : /on-this-day/june/10th-june-1668-samuel-pepys-visits-salisbury
unknownproperty : 
body            : 

.EXAMPLE
#>
    [CmdletBinding()]
    Param( 
        [string]$HugoMarkdownFile = "c:\temp\markdown_file.md",
        [string]$aliases,
        [string]$body,
        [string]$categories,
        [string]$date,
        [string]$description,
        [string]$draft,
        [string]$lastmod,
        [string]$markup,
        [string]$publishdate,
        $tags,
        [string]$title,
        [string]$unknownproperty,
        [string]$url,
        [string]$weight,
        [switch]$nobackup
    )


    write-startfunction

    if (test-path $HugoMarkdownFile)
    {
        backup-filetooldfolder $HugoMarkdownFile
    }

    write-dbg "`$Tags: <$Tags>"
    $TagsString = foreach ($Element in $Tags)
    {
       write-dbg "`$Element: <$Element>"
       @"

 - "$Element"
"@ 
    }
    
    $CategoriesString = foreach ($Element in $Categories)
    {
       @"

 - "$Element"
"@ 
    }
    
    $AliasesString = foreach ($Element in $Categories)
    {
       @"

 - "$Element"
"@ 
    }
    
    [string]$HugoString = @"
---
title           : $title
description     : $Description
lastmod         : $lastmod
date            : $date
tags            : $tagsstring
categories      : $CategoriesString
aliases         : $AliasesString
draft           : $Draft
publishdate     : $PublishDate
weight          : $Weight
markup          : $Markup
url             : $url
---
$body
"@

    $HugoString | set-content $HugoMarkdownFile

    write-endfunction
}

function backup-FileToOldFolder { 
<#
.SYNOPSIS
Copies the target file to an 'old' directory (creates the old directory if there isn't one) 

.DESCRIPTION
Function 'backs up' the target file to an 'old' directory. It creates the 'old' directory under the directory of the target file if it doesn't exist. The backup copy is suffixed with the date and time.

.PARAMETER file
The file you want to back up, with the full filepath

.EXAMPLE
backup-FileToOldFolder g:\my_scripts\x.txt

#>
  Param( [String] $file,
         [String] $OldFolder)

  write-startfunction

  $FsFile="Filesystem::$File"

  if ($OldFolder)
  {
    write-dbg "`$Oldfolder specified"
  }
  else
  {
    $OldFolder = $(get-childitem $FsFile).directory
    $OldFolder = join-path -path $OldFolder -childpath "old"
  }
  write-dbg "Old folder is $OldFolder"

  # If 'old' folder doesn't exist, create it
  $OldFolderExists = test-path $OldFolder
  if ($OldFolderExists -eq $FALSE) 
  {
    mkdir $OldFolder
  }

  # get the date in YYYYMMDD format
  $DateSuffix = get-date -uformat "%Y%m%d%H%M"

  # get the filename without the folder
  $FileName = $(get-childitem $File).name
  write-dbg "FileName is $FileName"

  # copy the existing file to the 'old' directory
  $OldFile = join-path -Path $OldFolder -ChildPath $($FileName + '_' + $DateSuffix)
  write-dbg "OldFile is $OldFile"
  copy $File $OldFile

}




function new-HugoParentPage { 
<#
.SYNOPSIS
    One-line description
.DESCRIPTION
    Longer description
.PARAMETER

.EXAMPLE
    Example of how to use this cmdlet

.EXAMPLE
    Another example of how to use this cmdlet
#>
    [CmdletBinding()]
    Param( [string]$NewParentPage,
           [string]$FileSpec,
           [String]$HeaderText,
           [String]$FooterText)
            

    write-startfunction

    $HugoPages = foreach ($file in $(dir $FileSpec | where extension -eq '.md')) 
    { 
        $H = get-HugoContent $file 
        [PSCustomObject]@{ url = $H.url
                           title = $H.title
                           weight = $H.weight
                         }
    }

    foreach ($H in $HugoPages | sort-object -property weight)
    {
        [string]$url = $h.url
        [string]$Title = $h.title
        [string]$Weight = $h.Weight
        $HyperLink = "<a href=`"$url`">$title</a>"
        write-dbg "`$Hyperlink: <$Hyperlink>"
        $BodyText = @"
$BodyText
$HyperLink
"@
    }

    $PageText = @"
$HeaderText

$BodyText

$FooterText
"@

   if ($NewParentPage)
   {
        # todo: backup page
        # todo: write this!
        write-host "todo"

   }

   return $PageText

   write-endfunction

}

<#
.Synopsis
   Short description
.DESCRIPTION
   Only works with inline style markdown
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function get-PostsWithImages
{
    [CmdletBinding()]
    
    Param
    (
        # Param1 help description
        
        $Posts
        
    )

    write-startfunction

    foreach ($P in $(dir $Posts))
    {
        $Images = @()
        
        write-dbg "Processing post `$P: <$P>"
        $MarkdownStyleImageLines = select-string "\!\[" $P

        $HtmlStyleImageLines = select-string "<img" $P
    
        foreach ($L in $MarkdownStyleImageLines)
        {
            $Line = $L.Line

            write-dbg "MD Line: $Line"
            $Images += get-imagesFromMarkdownStyleImageLines -line $Line
        }   
        foreach ($L in $HtmlStyleImageLines)
        {
            $Line = $L.Line

            write-dbg "Html Line: $Line"
            $Images += get-imagesFromHtmlStyleImageLines -line $Line
        }   

        foreach ($I in $Images)
        {
            [PSCustomObject]@{
                Name = $P.Name
                Fullname = $P.FullName
                Image = $I 
            }
        }
    }
    
    write-endfunction
}

function write-dbgobject {
    [CmdletBinding()]
    param (
        $Object
    )
    
    
}


<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>


function get-imagesFromMarkdownStyleImageLines
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        $Line
    )
    write-startfunction
    write-dbg "Line: $Line"
    
    # Format in markdown is ![alt text](/images/pic.jpg)
    
    $Line = $Line.replace("`)", "`(")
    write-dbg "Line (bracket swapped): $Line"
    
    $SplitLine = $Line.Split("(")
    write-dbg "SplitLine: $SplitLine"
    
    $NumberofElements = $SplitLine.Length
    write-dbg "`$NumberofElements: <$NumberofElements>"

    $Images = @()
    for ($i=-1; $i -lt $NumberofElements; $i = $i +2)
    {
        $Element = $SplitLine[$i]
                
        $Element = $Element.trim()
        write-dbg "`$NumberofElements: <$NumberofElements> `$i: <$i> `$Element: <$Element>"

        if (test-ElementIsImage -Element $Element)
        {
            $Images += $Element
            write-dbg "Returning `$Element: <$Element>"
        }
    }
    return $Images
    write-endfunction
}

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   get-PostsWithImages *May* | select image, name

Image                                                                    Name                                                          
-----                                                                    ----                                                          
/Skythian_archer_plate_BM_E135_by_Epiktetos.jpg                          3rd-may-2002-wessex-archaeologists-uncover-the-amesbury-arc...
/20120107202452!Churchill_V_sign_HU_55521.jpg                            8th-may-1945-ve-day.md                                        
/Franklin_SC1_1847.jpg                                                   21st-may-1774-benjamen-franklin-signs-letter-as-a-freeholde...
/images/Breamore-The-Hulse-Familys-Home-300x176.jpg                      9th-november-1927-lady-hulse-becomes-first-woman-mayor-of-s...
/images/Stonehenge-at-sun-rise1-300x193.jpg                              11th-may-2000-english-heritage-announce-open-access-to-ston...
.EXAMPLE
   foreach ($I in $(get-PostsWithImages *Apr*.md )) {$image = $i.image; [PSCustomObject]@{ Image=$Image ; 
              Extant=$(test-path "d:\onedrive\salisburyandstonehenge.net\static\$image")} }

/images//William_Hazlitt_1870_portrait.jpg                                   False
/images/Fairport_Convention.png                                              False
/Convicts_at_Botany_Bay.jpg                                                  False
/images/Titanic-sinks.jpg                                                    False
/Colonel_John_Penruddock_1619-1655.jpg                                       False
/HMSMordaunt.jpg                                                             False

#>
function get-imagesFromHtmlStyleImageLines
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        $Line
    )

    write-startfunction
    write-dbg "Line: $Line"
    
    # Format in html is <a href="/images/Titanic-sinks.jpg"><img src="/images/Titanic-sinks.jpg" alt="Titanic"/></a>
    $Line = $Line.replace(" ", "")
    write-dbg "Line: $Line"
    
    
    $SplitLine = $Line -Split "imgsrc=`""
    write-dbg "SplitLine: $SplitLine"
    
    $NumberofElements = $SplitLine.Length
    write-dbg "`$NumberofElements: <$NumberofElements>"

    $Images = @()
    for ($i=0; $i -lt $NumberofElements; $i = $i +2)
    {
        $Element = $SplitLine[$i -1]
        write-dbg "`$NumberofElements: <$NumberofElements> `$i: <$i> `$Element: <$Element>"
        
        $TrimmedElement = $Element.split("`"")[0]
        
        if (test-ElementIsImage -Element $TrimmedElement)
        {
            $Images += $TrimmedElement
            write-dbg "Added `$TrimmedElement: <$TrimmedElement>"
        }
    }
    
    write-endfunction
    return $Images
}




<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function test-ElementIsImage
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        [string]$Element,

        # Param2 help description
        $ImageFileTypes = ("jpg", "jpeg", "png")
    )
    write-startfunction

    $ElementIsImage = $False
    
    $SplitElement = $Element.split('.')
    
    $NumberOfSplits = $SplitElement.length
    
    $PossibleFileType = $( $SplitElement[$NumberOfSplits - 1])
    write-dbg "`$PossibleFileType: <$PossibleFileType>"
    
    if ($ImageFileTypes -icontains $PossibleFileType)
    {
        $ElementIsImage = $True
    }
    
    write-endfunction
    
    return $ElementIsImage
}

<#
vim: tabstop=4 softtabstop=4 shiftwidth=4 expandtab
#>


<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   get-ImageDetails -PostPath *apr*.md | ? ImageExists -eq $False
   /Colonel_John_Penruddock_1619-1655.jpg                                         False 18th-april-1655-penruddock-goes-on-trial-at-...
/HMSMordaunt.jpg                                                                  False 18th-april-1698-the-first-hms-salisbury-is-l...
.EXAMPLE
   Another example of how to use this cmdlet
#>
function get-ImageDetails
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (        
        $PostPath,
        $ImagePath = "d:\onedrive\salisburyandstonehenge.net\static"
    )

    write-startfunction

    $PostsReferencingImages = get-PostsWithImages $PostPath

    foreach ($I in $PostsReferencingImages) 
    {
        $image = $i.image
        $name = $i.Name
        $fullname = $i.Fullname
        
        write-host "Testing $(join-path $ImagePath $image)>"
        $ImageExists = test-path $(join-path $ImagePath $image)
        
        write-dbg @"
        [PSCustomObject]@{ Image=$Image  
            ImageExists=$ImageExists
            Name = $name
            Fullname = $FullName }
"@
        
        
        [PSCustomObject]@{ Image=$Image  
                           ImageExists=$ImageExists
                           Name = $name
                           Fullname = $FullName }
    }

    write-endfunction
}
 



<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
    get-MarkdownLinkForHugoFile * -NoDrafts | select MarkdownFormatLink | out-file -Width 200 c:\temp\links.txt
.EXAMPLE
   Another example of how to use this cmdlet
#> 
function get-MarkdownLinkForHugoFile
{
    [CmdletBinding()]
    [Alias()]
    Param
    (        
        $Filename = "*",
        [switch]$NoDrafts = $False
    )

    $Links = @()
    foreach ($F in $(Get-ChildItemByWeight  $Filename | ? extension -eq '.md'))
    {
        $fullname = $f.fullname
	
        $HugoContent =get-HugoContent -HugoMarkdownFile $fullname 

        $Draft = $HugoContent.Draft
 
        if ($NoDrafts -eq $False -or $Draft -ne "Yes" )
        {
            [string]$Title = $HugoContent.title
            [string]$Url = $HugoContent.Url
            
            $MarkdownFormatLink = "[$Title]($url)" 
            $HtmlFormatLink = "<a href=`"$url`">$Title</a>" 

            $Links += [PSCustomObject]@{
                MarkDownFormatLink = $MarkdownFormatLink
                HtmlFormatLink = $HtmlFormatLink 
		        }
        }

    }
    $Links
}

<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Get-MarkdownLinkForImageFile
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        $File = "$Images\*" ,
        $SortOrder = "LastWriteTime",
        $RootFolder = "$Static",
        $SubFolder = "images",
        [switch]$Last = $False
    )
    write-dbg "`$File: <$File>"    
    $FilesToProcess = $(get-childitem $File)

    if ($Last -eq $True)
    {
        $FilesToProcess = $FilesToProcess | sort-object -Property LastWriteTime | select -Last 1
        write-dbg "In last"
    }

    if ($SortOrder -eq "LastWriteTime")
    {
        $FilesToProcess = $FilesToProcess | sort-object -Property LastWriteTime
    }

    foreach ($F in $FilesToProcess)
    {
        $File = $F.FullName
        write-dbg "`$File: <$File>" 

        $File = [System.IO.Path]::GetFileName($File)
        write-dbg "`$File: <$File>" 

        $File = $File.replace("\", '/')
        write-dbg "`$File: <$File>" 
        
        $Description = $File.replace('/', '')
        write-dbg "`$Description: <$Description>"

        $Description = $Description.replace('.jpg','')
        write-dbg "`$Description: <$Description>"
        
        $Description = $Description.replace('/', '')
        write-dbg "`$Description: <$Description>"
        
        
        $Description = $Description.replace('/', '')
        $Description = $Description.replace('-', ' ')
        $Description = $Description.replace('_', ' ')
        $Description = $Description.replace('0x', '')
        $Description = $Description.replace('images', '')
        $Description = $Description -replace "[0-9][0-9]*x[0-9][0-9]*",""
        write-dbg "`$Description: <$Description>"
        
        

        $Link = "![$Description]($File)"

        $Link
    }


        
    
}


function write-startfunction { 
    <#
    .SYNOPSIS
      Marks start of function in logfile or debug output
    .DESCRIPTION
      Gets parameters back from Get-PSCallStack
    .EXAMPLE
      write-startfunction $MyInvocation
    #>
      [CmdletBinding()]
      Param(  ) 
    
      $CallDate = get-date -format 'hh:mm:ss.ffff' 
        
      $CallingFunction = Get-PSCallStack | Select-Object -first 2 | select-object -last 1
    
      [string]$Command = $CallingFunction.Command        
      [string]$Location = $CallingFunction.Location 
      [string]$Arguments = $CallingFunction.Arguments 
      # [string]$FunctionName = $CallingFunction.FunctionName
       
      write-debug "$Command`: starting at: $CallDate"
      $Arguments = $Arguments.trimstart('{')
      $Arguments = $Arguments.trimend('}')
      $SplitArguments = $Arguments.split(',')
      foreach ($A in $SplitArguments)
      {
        write-debug "$Command`: Parameter: $($A.trimstart())"
      }
      write-debug "$Command`: $Location"
      return
    }
    
    function write-endfunction { 
    <#
    .SYNOPSIS
      Marks end of function in logfile or debug output
    .EXAMPLE
      write-endfunction
    #>
      [CmdletBinding()]
      Param(  ) 
    
      if ($DebugPreference -ne 'SilentlyContinue')
      {
        $CallDate = get-date -format 'hh:mm:ss.ffff' 
        $CallingFunction = Get-PSCallStack | Select-Object -first 2 | select-object -last 1
        
        [string]$Command = $CallingFunction.Command        
        [string]$Location = $CallingFunction.Location 
        
        write-debug "$Command`: Finish: $CallDate $Location"
      }
      return
    }

    function write-dbg { 
        <#
        .SYNOPSIS
          write-dbg with function and time stamp
        .DESCRIPTION
          Gets parameters back from Get-PSCallStack
        .EXAMPLE
          write-startfunction $MyInvocation
        #>
          [CmdletBinding()]
          Param( $x ) 
        
          if ($DebugPreference -ne 'SilentlyContinue')
          {
                 
            $CallingFunction = Get-PSCallStack | Select-Object -first 2 | select-object -last 1
            
            [string]$Command = $CallingFunction.Command        
            
            # $CallDate = get-date -format 'hh:mm:ss.ffff' 
            
            # write-dbg "$CallDate $Command`: $x"
            
            write-debug "$Command`: $x"
          }
          return
    }
    