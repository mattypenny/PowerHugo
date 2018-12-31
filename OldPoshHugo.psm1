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
        write-debug "`$NumberOfMarkDownLines: $NumberOfMarkDownLines"

    
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
           
        <#
            Initialize the potentially multi-value and/or multi-line properties
        #>
        $TagString = ""
        $CategoriesString = ""
        $AliasesString = ""
               
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
                    write-debug "`$PropertyName: <$PropertyName>"
                    write-debug "`$PropertyValue: <$PropertyValue>"
    
                    $PropertyCount = $PropertyCount + 1
                
                    
                    switch ($PropertyName) 
                    {
                        "title" 
                        { 
                            write-debug "in switch"; 
                            $title = $PropertyValue 
                        }
                        "description"
                        { 
                            write-debug "description - in switch"; 
                            $description = $PropertyValue 
                        }
                        "lastmod"
                        { 
                            write-debug "in switch"; 
                            $lastmod = $PropertyValue 
                        }
                        "date"
                        { 
                            write-debug "in switch"; 
                            $date = $PropertyValue 
                        }
                        "tags" 
                        {
                            
                            write-debug "in switch"; 
                            $TagString = $PropertyValue
                            
                        }
                        # aliases CAN be multiple, but I've not coded for this yet
                        "aliases"
                        { 
                            write-debug "in switch"; 
                            $aliasesString = $PropertyValue 
                        }
                        "categories"
                        { 
                            write-debug "in switch"; 
                            $categoriesString = $PropertyValue 
                        }
                    
                        "draft"
                        { 
                            write-debug "in switch"; 
                            $draft = $PropertyValue 
                        }
                        "publishdate"
                        { 
                            write-debug "in switch"; 
                            $publishdate = $PropertyValue 
                        }
                        "weight"
                        { 
                            write-debug "in switch"; 
                            $weight = $PropertyValue 
                        }
                        "markup"
                        { 
                            write-debug "in switch - markup"; 
                            $markup = $PropertyValue 
                        }
                        "url"
                        { 
                            write-debug "in switch"; 
                            $url = $PropertyValue 
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
                                    write-debug "in `$PropertyNameFromPreviousLine switch Tags"; 
                                    $TagString = "$TagString, $PropertyValue"
                                }
                        
                                "categories"
                                { 
                                    write-debug "in `$PropertyNameFromPreviousLine switch categories `$PropertyValue: <$PropertyValue>"; 
                                    
                                    $StartofValue = $PropertyValue.indexof('-') + 1 
                                    $PropertyValue = $PropertyValue.substring($StartOfValue, $PropertyValue.length - $StartOfValue)
                                    $CategoriesString = "$CategoriesString~$PropertyValue"
                                    write-debug "in `$PropertyNameFromPreviousLine switch: `$CategoriesString: <$CategoriesString>"; 
                                }
                        
                                "aliases"
                                { 
                                    write-debug "in `$PropertyNameFromPreviousLine switch Aliases"; 
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
                                    write-error "ERR020: There is an invalid line: Line: <$Line> PropertyName: <$PropertyName> PropertyValue <$PropertyValue>"
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
                    write-verbose "Adding to body <$Line>"
                    $CarriageReturn = [char]13
                    $Body = @"
$Body$Line$CarriageReturn
"@
    
                }
            }
        }
        # $Body = $Body.trim('_')

        $TagsArray = get-HugoValueArrayFromString -MultipleValueString $TagString -DElimiter ','
        $AliasesArray = get-HugoValueArrayFromString -MultipleValueString $AliasesString ','
        $CategoriesArray = get-HugoValueArrayFromString -MultipleValueString $CategoriesString '~'


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
        }
            
    }
    write-endfunction

}

set-alias temp get-template

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

  write-debug "Returning PropertyName <$PropertyName> PropertyValue <$PropertyValue>"

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

  write-debug "`$MultipleValueString: <$MultipleValueString>"
  $MultipleValueString = $MultipleValueString.trimstart('[')
  $MultipleValueString = $MultipleValueString.trimend(']')
  $MultipleValueString = $MultipleValueString.trim()
  $ValueArray = $MultipleValueString.split($Delimiter)
                        
  
  write-debug "`$MultipleValueString: <$MultipleValueString>"


  $CleanedUpMultipleValueString = @{}                     
  $Values = foreach ($Value in $ValueArray)
  {
    write-debug "1: `$Value: <$Value>"
    $Value = $Value.trim()
    write-debug "2: `$Value: <$Value>"
    $Value = $Value.trim('"')
    $Value = $Value.trim()
    write-debug "3: `$Value: <$Value>"
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

    write-debug "`$Tags: <$Tags>"
    $TagsString = foreach ($Element in $Tags)
    {
       write-debug "`$Element: <$Element>"
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
    write-debug "`$Oldfolder specified"
  }
  else
  {
    $OldFolder = $(get-childitem $FsFile).directory
    $OldFolder = "Filesystem::$OldFolder\old"
  }
  write-debug "Old folder is $OldFolder"

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
  write-debug "FileName is $FileName"

  # copy the existing file to the 'old' directory
  $OldFile = $OldFolder + "\" + $FileName + "_" + $DateSuffix
  write-debug "OldFile is $OldFile"
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
        write-debug "`$Hyperlink: <$Hyperlink>"
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

set-alias temp get-template

<#
vim: tabstop=4 softtabstop=4 shiftwidth=4 expandtab
#>



