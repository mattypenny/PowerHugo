$DebugPreference = "Continue"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
remove-module PowerHugo 
import-module PowerHugo 
$TestData = join-path -path $here -childpath "pesterdata"
$TMPNAME = 'tmp'
$TEMP = join-path -path "$ENV:HOME" -childPath $TMPNAME

# . "$here\$sut"

function write-TestNameToDebug {
    [CmdletBinding()]
    $PSCallStack = Get-PSCallStack | ? Command -eq 'It' | select -expandproperty Arguments

    [string]$Name = $PSCallStack.name
    
    $TestName = $Name.split(',')[1]

    write-debug "#"
    write-debug "#"
    write-debug "# It $Testname"
    write-debug "#"
    write-debug "#"
    
    
    write-host "#"
    write-host "#"
    write-host "# It $Testname"
    write-host "#"
    write-host "#"
   
}

$HugoContentFolder = join-path "." "PesterData"

Describe "get-HugoNameAndFirstLineValue" {
    It "returns name and value for a valid line" {
        $Hugo = get-HugoNameAndFirstLineValue -FrontMatterLine "Weight: 103"
        $value = $Hugo.PropertyValue
        $value | Should Be '103'
        # "103" | Should Be '103'
        # $Hugo.value | Should Be '103'
    }

}

<#
title: "10th June 1668 - Samuel Pepys visits Salisbury"
description: ""
lastmod: "2016-06-07"
date: "2013-11-29"
tags: [  ]
categories: 
 - "on-this-day"
aliases: ["/on-this-day/june/10th-june-1668-samuel-pepys-visits-salisbury"]
draft: No
publishdate: "2013-11-29"
weight: 610
markup: "md"
url: /on-this-day/june/10th-june-1668-samuel-pepys-visits-salisbury
#>

Describe "get-HugoContent for a single file" {
    
    $HugoContent = get-HugoContent -f $TestData\10th-june-1668-samuel-pepys-visits-salisbury.md

    It "returns title" {
        $title = $HugoContent.title
        $title | Should Be '10th June 1668 - Samuel Pepys visits Salisbury'
    }

    It "returns description" {
        $description = $HugoContent.description
        $description | Should Be ''
    }


    It "returns lastmod" {
        $lastmod = $HugoContent.lastmod
        $lastmod | Should Be '2016-06-07'
    }

    It "returns date" {
        $date = $HugoContent.date
        $date | Should Be '2013-11-29'
    }

    It "returns tags" {
        $tags = $HugoContent.tags
        $tags[0] | Should be "pepys"

        $tags[1] | Should be "literary"
        $tags[2] | Should be "visitors"
        $tags[3] | Should be "old george mall"
        $tags[4] | Should be "high street"

        
    }

    It "returns categories" {
        $categories = $HugoContent.categories
        $ExpectedCategories = @("on-this-day", "june", "diaries and things", "dummy")
        $Comparison = Compare-Object $categories $ExpectedCategories
        $Comparison.InputObject | Should Be "dummy"
        $Comparison.SideIndicator | Should Be "=>"
    }

    It "returns aliases" {
        $Content = $HugoContent.aliases
        $ExpectedContent = @("/on-this-day/june/10th-june-1668-samuel-pepys-visits-salisbury", "/about-Pepys-and-Salisbury", "dummy")
        $Comparison = Compare-Object $Content $ExpectedContent
        $Comparison.InputObject | Should Be "dummy"
        $Comparison.SideIndicator | Should Be "=>" 
    }

    It "returns draft" {
        $draft = $HugoContent.draft
        $draft | Should Be 'No'
    }

    It "returns publishdate" {
        $publishdate = $HugoContent.publishdate
        $publishdate | Should Be '2013-11-29'
    }

    It "returns weighting" {
        $Weight = $HugoContent.Weight
        $Weight | Should Be '610'
    }

    It "returns markup" {
        $markup = $HugoContent.markup
        $markup | Should Be 'Md'
    }

    It "returns url" {
        $url = $HugoContent.url
        $url | Should Be '/on-this-day/june/10th-june-1668-samuel-pepys-visits-salisbury'
    }
<#
    It "returns body" {
        [string]$ExpectedBody = get-content $TestData\Pepys-Body.txt
        [string]$body = $HugoContent.body
        $BodyFirst = $Body.Substring(1,10)
        $ExpectedBodyFirst = $ExpectedBody.Substring(1,10)

        $bodyFirst | Should Be $ExpectedBodyFirst
    }

    It "returns links" {
        $links = $HugoContent.links
        $links | Should Be ''
    }

    It "returns images" {
         
        $images | Should Be '610'
    }
    <#
    #>
}

Describe -Tag Twitterx "get-HugoContent for a single file which already has Twitter card data" {
    
    $HugoContent = get-HugoContent -f $TestData\9th-january-1728-thomas-warton-written-at-stonehenge-writer-was-born.md
    $FileDescription = "Warton"

    It "returns title for a file which already has Twitter card data ($FileDescription)" {
        $title = $HugoContent.title
        $Expected = @"
9th January 1728 - Thomas Warton, 'Written at Stonehenge' writer was born
"@
        $title | Should Be $Expected
    }



    It "returns lastmod for a file which already has Twitter card data ($FileDescription)" {
        $lastmod = $HugoContent.lastmod
        $lastmod | Should Be '2016-10-04'
    }

    It "returns date for a file which already has Twitter card data ($FileDescription)" {
        $date = $HugoContent.date
        $date | Should Be '2013-11-12'
    }

    It "returns tags for a file which already has Twitter card data ($FileDescription)" {
        $tags = $HugoContent.tags
        $tags.length | Should be 0

        
    }

    It "returns categories for a file which already has Twitter card data ($FileDescription)" {
        $categories = $HugoContent.categories
        $ExpectedCategories = @("on-this-day", "dummy")
        $Comparison = Compare-Object $categories $ExpectedCategories
        $Comparison.InputObject | Should Be "dummy"
        $Comparison.SideIndicator | Should Be "=>"
    }

    It "returns aliases for a file which already has Twitter card data ($FileDescription)" {
        $Content = $HugoContent.aliases
        $ExpectedContent = @("/on-this-day/january/9th-january-1728-thomas-warton-written-at-stonehenge-writer-was-born", "dummy")
        $Comparison = Compare-Object $Content $ExpectedContent
        $Comparison.InputObject | Should Be "dummy"
        $Comparison.SideIndicator | Should Be "=>" 
    }

    It "returns draft for a file which already has Twitter card data ($FileDescription)" {
        $draft = $HugoContent.draft
        $draft | Should Be ''
    }

    It "returns publishdate for a file which already has Twitter card data ($FileDescription)" {
        $publishdate = $HugoContent.publishdate
        $publishdate | Should Be '2013-11-12'
    }

    It "returns weighting for a file which already has Twitter card data ($FileDescription)" {
        $Weight = $HugoContent.Weight
        $Weight | Should Be '109'
    }

    It "returns markup for a file which already has Twitter card data ($FileDescription)" {
        $markup = $HugoContent.markup
        $markup | Should Be 'Md'
    }

    It "returns url for a file which already has Twitter card data ($FileDescription)" {
        
        write-TestNameToDebug
        Get-PSCallStack > /tmp/v.txt
        
        Get-PSCallStack | ? Command -eq 'Describe' | select -expandproperty Arguments  >> /tmp/v.txt

        Get-PSCallStack | ? Command -eq 'Describe' | select -expandproperty Arguments | gm  >> /tmp/v.txt

        Get-PSCallStack | ? Command -eq 'Describe' | select -expandproperty Arguments | select name >> /tmp/v.txt
        
        Get-PSCallStack | ? Command -eq 'It' | select -expandproperty Arguments | select name >> /tmp/v.txt
        
        $url = $HugoContent.url
        $url | Should Be ''
    }

    It "returns twitter card card for a file which already has Twitter card data ($FileDescription)" {
        $TwitterCard = $HugoContent.TwitterCard
        $TwitterCard | Should Be 'summary_large_image'
    }

    It "returns twitter card site for a file which already has Twitter card data ($FileDescription)" {
        $TwitterSite = $HugoContent.TwitterSite
        $TwitterSite | Should Be '@salisbury_matt'
    
    }

    It "returns twitter card creator for a file which already has Twitter card data ($FileDescription)" {
        $TwitterCreator = $HugoContent.TwitterCreator
        $TwitterCreator | Should Be '@salisbury_matt'
    }   
    

    It "returns twitter card title for a file which already has Twitter card data ($FileDescription)" {
        $TwitterCardTitle = $HugoContent.TwitterCardTitle
        $TwitterCardTitle | Should Be '9th January 1728 - Thomas Warton, Written at Stonehenge writer was born'
    }   
    

    It "returns twitter card description for a file which already has Twitter card data ($FileDescription)" {
        $TwitterDescription = $HugoContent.TwitterDescription
        $TwitterDescription | Should Be 'On this day, 9th January in 1728,  poet laureate Thomas Warton was born in Basingstoke. He wrote Written at Stonehenge.'
    }   
    

    It "returns twitter card image for a file which already has Twitter card data ($FileDescription)" {
        $TwitterImage = $HugoContent.TwitterImage
        $TwitterImage | Should Be 'https://salisburyandstonehenge.net/images/Thomaswarton.jpg'
    }   
    

    It "returns twitter card url for a file which already has Twitter card data ($FileDescription)" {
        $TwitterCardUrl = $HugoContent.TwitterUrl

        $TwitterCardUrl | Should Be 'http://salisburyandstonehenge.net/on-this-day/9th-january-1728-thomas-warton-written-at-stonehenge-writer-was-born'
       
    }




}

Describe "get-HugoContent for multiple file" {
    
    $HugoContent = get-HugoContent -f $TestData\10th-june-1668-samuel-pepys-visits-salisbury.md

    It "returns title" {
        $title = $HugoContent.title
        $title | Should Be '10th June 1668 - Samuel Pepys visits Salisbury'
    }
}

Describe "get-HugoValueArrayFromString" {
    It "returns an array of values from a comma seperated list of tags when there are many values" {
        $HugoValueArray = get-HugoValueArrayFromString -MultipleValueString '[ "pepys", "literary", "visitors"," old george mall", "high street" ]'
        $HugoValueArray.count | Should be 5
        $HugoValueArray[0] | Should be "pepys"
        $HugoValueArray[1] | Should be "literary"
        $HugoValueArray[2] | Should be "visitors"
        $HugoValueArray[3] | Should be "old george mall"
        $HugoValueArray[4] | Should be "high street"
        
    }
    It "returns an array of values from a dash seperated list of tags when there are many values" {
        $HugoValueArray = get-HugoValueArrayFromString -DElimiter '-' -MultipleValueString '- "roadname" - "onthisday" - "stonehengeseverywhere" -"unknown"'
        $HugoValueArray.count | Should be 4
        $HugoValueArray[0] | Should be "roadname"
        $HugoValueArray[1] | Should be "onthisday"
        $HugoValueArray[2] | Should be "stonehengeseverywhere"
        $HugoValueArray[3] | Should be "unknown"
        
    }
        It "returns one value from a comma seperated list of tags when there is only one value" {
        $HugoValueArray = get-HugoValueArrayFromString -MultipleValueString '[ "pepys", ]'
        $HugoValueArray | Should be "pepys"
        
    }
        It "returns one value when the string is just one word, with no comma seperation" {
        $HugoValueArray = get-HugoValueArrayFromString -MultipleValueString '[ "pepys" ]'
        $HugoValueArray | Should be "pepys"
        
    }
        It "returns one value when the string is just one word, with no comma seperation and no brackets" {
        $HugoValueArray = get-HugoValueArrayFromString -MultipleValueString ' "pepys" '
       $HugoValueArray | Should be "pepys"
        
    }
        It "should not throw an error when the string is blank" {
        {get-HugoValueArrayFromString -MultipleValueString '  '} | Should Not Throw
       
        
    }

        It "returns nothing when the string is blank" {
        $HugoValueArray = get-HugoValueArrayFromString -MultipleValueString '  '
        $HugoValueArray.count | Should be 0
        $HugoValueArray | Should benullOrEmpty
        
    }

}

Describe "get-HugoContent for multiple files" {
    
    
    
        

    It "returns title" {
        $HugoTitles = get-HugoContent -f $TestData\*.md | select title
        
        $ExpectedTitles = @("10th August 1901 - Miss Moberly meets Marie Antoinette",               
                            "10th June 1668 - Samuel Pepys visits Salisbury",                      
                            "15th June 1786 - Matcham meets 'the Dead Drummer', possibly",          
                            "1st May 472 - the 'Night of the Long Knives' at Amesbury",             
                            "3rd June 1977 - the Ramones visit Stonehenge. Johnny stays on the bus"
                             )
        $ExpectedTitles
        $Comparison = Compare-Object $HugoTitles.title $ExpectedTitles
    
        $Comparison.InputObject | Should Be "Elvis Presley visits Salisbury (this is a test)"
        $Comparison.SideIndicator | Should Be "<=" 
    
    }
}

Describe "get-HugoContent for a single file - body processing" {
    
    $HugoContent = get-HugoContent -f $TestData\10th-june-1668-samuel-pepys-visits-salisbury.md
    [string]$ExpectedBody = get-content -encoding default $TestData\Pepys-Body.txt
    [string]$body = $HugoContent.body

    It "returns the first 10 characters" {
        
        $BodyFirst = $Body.Substring(0,10)
        
        $ExpectedBodyFirst = $ExpectedBody.Substring(0,10)
        write-host "`$BodyFirst <$BodyFirst> `$ExpectedBodyFirst <$ExpectedBodyFirst>"
        $bodyFirst | Should Be $ExpectedBodyFirst
    }
    It "returns the first character" {
        
        [byte][char]$Body[0] | Should Be $([byte][char]$ExpectedBody[0])
    }
    It "returns about the same length" {
        
        $BodyLength = $Body.length
        $ExpectedBodyLength = $ExpectedBody.length
        $bodyLength | Should BeGreaterThan $($ExpectedBodyLength -30)
        $bodyLength | Should BeLessThan $($ExpectedBodyLength +30)

    }

}

Describe "set-HugoContent backs up an existing file" {
    It "creates a backup copy of the existing file" {
 
        $Now = get-date -uformat "%Y%m%d%H%M"
        
        $HugoParameters = @{
            HugoMarkdownFile = "/tmp/markdown_file.md"
            aliases = 'xx'
            body = 'xx'
            categories = 'xx'
            date = 'xx'
            description = 'xx'
            draft = 'xx'
            lastmod = 'xx'
            markup = 'xx'
            publishdate = 'xx'
            tags = "hippy","wiltshire","stonehenge"
            title = 'xx'
            unknownproperty = 'xx'
            url = 'xx'
            weight = 'xx'
            nobackup = $False
        }
        set-HugoContent @HugoParameters

        $(test-path "/tmp/old/markdown_file.md_$Now") | Should Be $true
    }
}

Describe "set-HugoContent" {
 
    $HugoFile = join-path "pesterdata" "elvis-visits-Salisbury.md"

    $HugoParameters = @{
        HugoMarkdownFile = "$HugoFile"
        aliases = '["/on-this-day/theking"]'
        body = 'This is a test post - sadly Elvis never got to visit Salisbury'
        categories = 'on-this-day'
        date = '2016-08-25'
        description = ''
        draft = 'No'
        lastmod = '2016-08-25'
        markup = 'md'
        publishdate = '2016-08-25'
        tags = "elvis","wiltshire","salisbury"
        title = 'Elvis Presley visits Salisbury (this is a test)'
        unknownproperty = 'xx'
        url = '/on-this-day/june/elvis-visits-salisbury'
        weight = '1'
        nobackup = $False
        }
        set-HugoContent @HugoParameters

    It  "creates a backup copy of the existing file"  {
        
        $Now = get-date -uformat "%Y%m%d%H%M"
        $BackupFile = join-path -path ./pesterdata -ChildPath old -AdditionalChildPath "elvis-visits-Salisbury.md_${Now}"
        write-host "$BackupFile"
        test-path $BackupFile | Should Be $true
    }
    It "creates a markdown file" {
        $(test-path "$HugoFile") | Should Be $true
    }


    It "creates a markdown file whtat works with Hugo (if Hugo is running!)" {
    <#
        $WebPage = invoke-webrequest http://localhost:1313/on-this-day/june/elvis-visits-salisbury/ 
        
        $WebPage.RawContentLength | Should Be 2229
    #>
    }

    It "populates the Hugo fields" -testcases @{Key = "title"; ExpectedValue = "Elvis Presley visits Salisbury (this is a test)" },
                                              @{Key = "title"; ExpectedValue = "Elvis Presley visits Salisbury (this is a test)" } -test {
        param ([string]$Key,
               [string]$ExpectedValue)
 
        # write-host "`$Key: <$Key>"
        # write-host "`$ExpectedValue: <$ExpectedValue>"
        $ReturnedString = select-string  -pattern "$key  *:" $HugoFile

        $($ReturnedString | measure-object).count | Should Be 1

        [string]$Line = $ReturnedString.line
        # write-host "`$Line: <$Line>"
        $value = $Line.split(":")[1]
        $Value = $Value.trim()
       
        $Value | Should Be $ExpectedValue

    }
<#
title           : Elvis Presley visits Salisbury (this is a test)
description     : 
lastmod         : 2016-08-25
date            : 2016-08-25
tags            : 
 - "elvis" 
 - "wiltshire" 
 - "salisbury"
categories      : 
 - "on-this-day"
aliases         : 
 - "on-this-day"
draft           : No
publishdate     : 2016-08-25
weight          : 1
markup          : md
url             : /on-this-day/june/elvis-visits-salisbury
---
This is a test post - sadly Elvis never got to visit Salisbury
#>
}


describe -Tag Twitter  Get-TwitterCardMetaData {
    
    $MdString = @"
---
title: "3rd June 1977 - the Ramones visit Stonehenge. Johnny stays on the bus"
description: ""
lastmod: "2016-06-07"
date: "2014-11-04"
tags: [  ]
categories:
 - "on-this-day"
aliases: ["/on-this-day/june/3rd-june-1977-the-ramones-visit-stonehenge-johnny-stays-on-the-bus"]
draft: No
publishdate: "2014-11-04"
weight: 603
markup: "md"
url: /on-this-day/june/3rd-june-1977-the-ramones-visit-stonehenge-johnny-stays-on-the-bus
---

<a href="/images/Joey-Ramone-visited-Stonehenge.jpg"><img src="/images/Joey-Ramone-visited-Stonehenge.jpg" alt="Joey Ramone - &#039;visited&#039; Stonehenge" width="320" height="455" class="alignright size-full wp-image-9702" /></a>On either the 3rd<a name="Source1" href="#Note1">[1]</a> or possibly the 4th June 1977, the Ramones visited Stonehenge.

Mickey Leigh, who was travelling with the band quotes Chris Frantz of the Talking Heads:
<blockquote>"The Talking Heads like to enjoy things and the Ramones loved to hate everything," Chris Frantz mused. "Or it _seemed_ like they loved to hate everything. Like when we went to Stonehenge and Johnny stayed in the van. He'd snarl, "I DON'T WANT TO STOP HERE. IT's JUST A BUNCH OF OLD ROCKS!"<a href="#FootNote2" name="Body2">[2]</a></blockquote>


David P. Szatmary quotes Dee Dee Ramone:
<blockquote> On a Talking Heads-planed side trip to Stonehenge during the tour, the Ramones refused to leave the bus. "It's really nothing to see", explained Dee Dee, "It's not like going to see a castle"<a href="#FootNote3" name="Body3">[3]</a></blockquote>

> Pic: By en:User:Dawkeye [<a href="http://www.gnu.org/copyleft/fdl.html">GFDL</a>, <a href="http://creativecommons.org/licenses/by-sa/3.0/">CC-BY-SA-3.0</a> or <a href="http://creativecommons.org/licenses/by-sa/2.5">CC-BY-SA-2.5</a>], <a href="http://commons.wikimedia.org/wiki/File%3AJoeyramone.jpg">via Wikimedia Commons</a>

### Footnotes

<a  href="#Source1" name="Note1">[1]</a> In 'On the Road with the Ramones', Monte A. Melnick says that the visit occurred

> 'On the '77 tour we had a day off and noticed Stonehenge was on the way'[URL <a href="http://books.google.co.uk/books?id=N7m8AwAAQBAJ&lpg=RA1-PR24&dq=ramones%20stonehenge&pg=RA1-PR25#v=onepage&q=ramones%20stonehenge&f=false">'On the Road with the Ramones', by By Monte A. Melnick, Frank Meyer</a>].

> This would have been when the Ramones were travelling back from Penzance to Canterbury - the free day being June 3rd [<a href="http://en.wikipedia.org/wiki/List_of_Ramones_concerts#1977">Wikipedia List Of Ramones Concerts</a>]
"@
    $RamonesFile = join-path "TestDrive:" -ChildPath "Ramones.md"
    set-content -path $RamonesFile -value $MdString

    $Splat =@{
        HugoMarkdownFile = $RamonesFile
        Card = "summary_large_image"
        Site = "http://salisburyandstonehenge.net"
        Creator = "monkey"
        DescriptionMaxLength = 240
        ImageUrlRoot = "http://salisburyandstonehenge.net"
        DefaultImage = "http://salisburyandstonehenge.net/images/Salisbury%20Cathedral%20across%20a%20flooded%20water%20meadow.jpeg"
        UrlRoot = "http://salisburyandstonehenge.net"
    }
    $TwitterCardMetaData = Get-TwitterCardMetaData @Splat
    [string]$Title = $TwitterCardMetaData.title
    [string]$Description = $TwitterCardMetaData.description
    [string]$ImageUrl = $TwitterCardMetaData.imageUrl
    [string]$URL = $TwitterCardMetaData.URL
        

    It "returns an error message if the file doesn't exist" {

        {Get-TwitterCardMetaData -HugoMarkDownFile $TestData/this_does_not_exist.md} | Should Throw
    }

    It "returns the correct value for title" {

        $Title | Should Be "3rd June 1977 - the Ramones visit Stonehenge. Johnny stays on the bus"
        
    }

    It "returns the correct value for description" {
        $Description | Should Be "On either the 3rd or possibly the 4th June 1977, the Ramones visited Stonehenge."
    }

    It "returns the correct value for the image" {
        $ImageUrl | Should Be "http://salisburyandstonehenge.net/images/Joey-Ramone-visited-Stonehenge.jpg"
    }

    
    It "returns the first image if there is more than one" {
        $ImageUrl | Should Be "http://salisburyandstonehenge.net/images/Joey-Ramone-visited-Stonehenge.jpg"
        
    }

    It "returns the default image if there is no image" {
        $Splat.HugoMarkdownFile = "./pesterdata/elvis-visits-Salisbury.md"
        $TwitterCardMetaData = Get-TwitterCardMetaData @Splat
        [string]$ImageUrl = $TwitterCardMetaData.imageUrl
    
        $ImageUrl | Should Be "http://salisburyandstonehenge.net/images/Salisbury%20Cathedral%20across%20a%20flooded%20water%20meadow.jpeg"

    }

    It "returns the correct value for URL" {

        $URL | Should Be "http://salisburyandstonehenge.net/on-this-day/june/3rd-june-1977-the-ramones-visit-stonehenge-johnny-stays-on-the-bus"
    }

}

Describe "get-imagesFromMarkdownStyleImageLines" {


    It "extracts the image from a line with nothing else on it" {

        $Image = get-imagesFromMarkdownStyleImageLines "![Dickens dream](/images/Dickens_dream.jpg)" 

        $Image | Should Be "/images/Dickens_dream.jpg"
    }
    It "extracts the image from a line other stuff on it" {

        $Image = get-imagesFromMarkdownStyleImageLines "![Dickens dream](/images/Dickens_dream.jpg)A very nice picture of Chuck D" 

        $Image | Should Be "/images/Dickens_dream.jpg"
    }
}

Describe -Tag Twitterx "Get-ExtractedTwitterCardText" {
    $SplatParams = @{
        Card = "summary_large_image"
        Site = "@salisbury_matt"
        Creator = "@salisbury_matt"
        DescriptionMaxLength = 240
        ImageUrlRoot = 'http://salisburyandstonehenge.net'
        DefaultImage = "http://salisburyandstonehenge.net/images/View%20of%20the%20spire%20from%20Salisbury%20Cathedral's%20cafe.JPG"
        UrlRoot = 'http://salisburyandstonehenge.net/on-this-day'
        ImagePath = '/home/matt/salisburyandstonehenge.net/static/images'
    }

    $HugoMarkdownFile = "./pesterdata/9th-january-1728-thomas-warton-written-at-stonehenge-writer-was-born.md"
    [string]$ExpectedExtractedTwitterCardText = @"

twitter:
    card: summary_large_image
    site: @salisbury_matt
    creator: @salisbury_matt
    title: 9th January 1728 - Thomas Warton, 'Written at Stonehenge' writer was born
    description: On this day in 1728 poet laureate Thomas Warton was born in Basingstoke. He wrote 'Written at Stonehenge'. I wrote about 'Written at Stonehenge' here:  * 'Written at Stonehenge' by Thomas Warton.
    image: http://salisburyandstonehenge.net/images/Thomaswarton.jpg
    url: http://salisburyandstonehenge.net/on-this-day/9th-january-1728-thomas-warton-written-at-stonehenge-writer-was-born
"@
    
    It "returns the correct text for a single file ($HugoMarkdownFile)" {


        $ExtractedTwitterCardText = Get-ExtractedTwitterCardText @SplatParams -HugoMarkdownFile $HugoMarkdownFile

        $ExtractedTwitterCardText | Should Be $ExpectedExtractedTwitterCardText

    }

}
Describe -Tag Twitter,Dickens "Get-TwitterCardMetaData for the Dickens post" {
    
    $TwitterCardMetaData = Get-TwitterCardMetaData -HugoMarkdownFile ./pesterdata/7th-February-1812-Charles-Dickens-birthday.md -UrlRoot "http://salisburyandstonehenge.net/on-this-day"
    [string]$Title = $TwitterCardMetaData.Title
    [string]$ImageUrl = $TwitterCardMetaData.ImageUrl
    [string]$Description = $TwitterCardMetaData.Description
    [string]$Url = $TwitterCardMetaData.Url
    
    It "returns the correct Title for the Dickens post" {
        $Title | Should Be '7th February 1812 - birth of Charles Dickens'
    }

    It "returns the correct ImageUrl for the Dickens post" {
        $ImageUrl | Should Be 'http://salisburyandstonehenge.net/images/Dickens_dream.jpg'
    }

    It "returns the correct Description for the Dickens post" {
        $ExpectedDescription = @"
A quick post to celebrate the anniversary of the writer's birth. Despite having had 200 years notice of the anniversary, I only just thought it might be worth cobbling together a piece on Dickens' Salisbury connections.
"@
        $Description | Should Be $ExpectedDescription
    }

    It "returns all the correct Url for the Dickens post" {
        $Url | Should Be 'http://salisburyandstonehenge.net/on-this-day/7th-February-1812-Charles-Dickens-birthday'
    }

}



describe -Tag Twitter  Get-DescriptionFromBodyText {

    $TestCases = @(
        @{
            TestTitle = "realistic test"
            
            BodyText = @"
On the 23rd March 1943 HMS Stonehenge was launched from the shipyard at Birkenhead. HMS Stonehenge was an S-class submarine. She completed two war patrols but was lost with all hands in February 1944.
            
Pic: By Stewart Bale Ltd, Liverpool
"@
            
            MaximumLength = 240
            
            Description = @"
On the 23rd March 1943 HMS Stonehenge was launched from the shipyard at Birkenhead. HMS Stonehenge was an S-class submarine. She completed two war patrols but was lost with all hands in February 1944.
"@
        }
        @{
            TestTitle = "simple test"
            BodyText = "Salisbury is a city. In Wiltshire."
            MaximumLength = 25
            Description = "Salisbury is a city."
        }
        @{
            TestTitle = "no full stops"
            BodyText = "Salisbury is a city in wiltshire"
            MaximumLength = 240
            Description = "Salisbury is a city in wiltshire"
        }
        
    )


    It "returns useful descriptions - <TestTitle>" -testcases $TestCases {
        Param (
            $TestTitle,
            $BodyText,
            $MaximumLength,
            $Description
        )
    
        $DescriptionFromBodyText = Get-DescriptionFromBodyText -BodyText $BodyText -MaximumLength $MaximumLength

        $DescriptionFromBodyText | Should Be $Description

        

    }

}

Describe -Tag Twitter -Name 'Get-BodyTextWithMarkupRemovedForASpecificCharacter' {

        $TestCases = @(
            @{
                TestTitle = "simple test"
                BodyText = "Salisbury(Wiltshire)"
                ExpectedResult = "Salisbury"
                StartMarkupString = "("
                EndMarkupString = ")"
            }
            @{
                TestTitle = "test with spaces"
                BodyText = "New Sarum (aka Salisbury)"
                ExpectedResult = "New Sarum "
                StartMarkupString = "("
                EndMarkupString = ")"
            }   
            @{
                TestTitle = "test with nested brackets"
                BodyText = "New Sarum (aka Salisbury (near Stonehenge))"
                ExpectedResult = "New Sarum "
                StartMarkupString = "("
                EndMarkupString = ")"
            }   
            @{
                TestTitle = "test with curly brackets"
                BodyText = "New Sarum {aka Salisbury {near Stonehenge}}"
                ExpectedResult = "New Sarum "
                StartMarkupString = "{"
                EndMarkupString = "}"
            }
            @{
                TestTitle = "test two sets of brackets"
                BodyText = "New Sarum (aka Salisbury) in Wiltshire(the Goddess' own county)"
                ExpectedResult = "New Sarum in Wiltshire"
                StartMarkupString = "("
                EndMarkupString = ")"
            }   
            @{
                TestTitle = "test and double spaces are removed"
                BodyText = "New Sarum (aka Salisbury) in Wiltshire (the Goddess' own county)"
                ExpectedResult = "New Sarum in Wiltshire "
                StartMarkupString = "("
                EndMarkupString = ")"
            }    
            @{
                TestTitle = "test with no brackets"
                BodyText = "New Sarum aka Salisbury near Stonehenge"
                ExpectedResult = "New Sarum aka Salisbury near Stonehenge"
                StartMarkupString = "{"
                EndMarkupString = "}"
            }   
                    
                     
        )


        It "strips out the contents of the brackets in a <TestTitle>" -TestCases $TestCases {
            param (
                    $TestTitle,
                    $BodyText,
                    $StartMarkupString,
                    $EndMarkupString,
                    $ExpectedResult)
            

            $Params = @{
                BodyText = $BodyText
                StartMarkupString = $StartMarkupString
                EndMarkupString = $EndMarkupString
            }

            [string]$StrippedString = Get-BodyTextWithMarkupRemovedForASpecificCharacter @Params

            $StrippedString | Should Be $ExpectedResult
        }
}
Describe -Tag Image -Name 'get-ImageDetails' {

    $SingleImage = get-ImageDetails -PostPath ./pesterdata/10th-august-1901-miss-moberly-meets-marie-antoinette.md -ImagePath ./pesterdata

    It 'returns a single image if there is only one' {
        $($SingleImage | Measure-Object).count | Should Be 1
    }

    It 'returns False for ImageExists if it doesnt exist' {

    }

    It 'returns true for ImageExists if it does exist' {
        $ImageExists = $SingleImage.ImageExists
        $ImageExists | Should Be $True
    }

    It 'returns the name' {

    }

    It 'returns the fullname' {
        
    }

    It 'returns an array of image records if there is more than one' {

    }

    It 'returns nothing if the post has no image' {

    }
}