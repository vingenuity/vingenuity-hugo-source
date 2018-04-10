# deploy-to-github.ps1
#
# Handles building and deployment of a Hugo website to GitHub Pages
#
# (c) Vincent Kocks
param([string]$site_theme, [string]$commit_message)


# ****** ArrayList Helpers ******
function Add-ToArrayList
{
    param([System.Collections.ArrayList]$array_list, $object_to_add)
    
    # Redirecting the return value to $null here prevents the index numbers from being logged into the output stream. (See: https://stackoverflow.com/questions/28034605/arraylist-prints-numbers)
    $array_list.Add($object_to_add)  > $null
}

function Remove-FromArrayList
{
    param([System.Collections.ArrayList]$array_list, $object_to_remove)
    
    # Redirecting the return value to $null here prevents the index numbers from being logged into the output stream. (See: https://stackoverflow.com/questions/28034605/arraylist-prints-numbers)
    $array_list.Remove($object_to_remove)  > $null
}


# ****** Main Functionality ******
Write-Host "Deploying updates to GitHub..."

[System.Collections.ArrayList]$site_generation_args = @()
if($site_theme)
{
    Add-ToArrayList $site_generation_args "-t"
    Add-ToArrayList $site_generation_args $site_theme
}

& ./hugo.exe $site_generation_args


$commit_msg = $commit_message
if(!$commit_msg)
{
    $commit_msg = "Publishing latest site as of $((Get-Date).ToString())"
}
Write-Host $commit_msg

Set-Location "public"
& git pull origin master
& git add "."
& git commit -m $commit_msg
& git push origin HEAD:master
Set-Location ".."