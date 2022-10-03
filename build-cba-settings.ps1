param ([switch]$verbose = $false, [switch]$publish = $false)
if($verbose -eq $true){$VerbosePreference = "Continue"}else{$VerbosePreference = "SilentlyContinue"}

$comment = '// 21st TFAR Channel Setting, Automatically Generated'
$str1 = 'force force TFAR_Teamspeak_Channel_Name = "TFR: '
$str2 = '";'
$addonBuilder = Join-Path (Get-ItemProperty "HKCU:\Software\Bohemia Interactive\Arma 3 Tools").path "AddonBuilder\AddonBuilder.exe"
$publisherCmd = Join-Path (Get-ItemProperty "HKCU:\Software\Bohemia Interactive\Arma 3 Tools").path "Publisher\PublisherCmd.exe"
$WorkshopIDs = @(
    "2870692543"#Server1
)
$i = 0
foreach($id in $WorkshopIDs)
{
    $i++
    if($id -eq "0"){continue;} #skip unpublished mods

    #remove the output folder if it exists
    if(Test-Path -Path ".\Output\@21st_cba_settings_$i") {
        Write-Verbose "Old Mod $i Found, Removing."
        Remove-Item -Recurse -Force -Confirm:$false ".\Output\@21st_cba_settings_$i"
        #if it exists and we fail to delete it, its in use, exit.
        if(Test-Path -Path ".\Output\@21st_cba_settings_$i")
        {
            Write-Error "Failed to delete old mod, in use?"
            Exit
        }
    }

    if(Test-Path ".\Settings\$i\cba_settings.sqf")
    {
        Write-Verbose "$i Custom Config"
        $settings = Get-Content ".\Settings\$i\cba_settings.sqf" -Raw
    }else{
        Write-Verbose "$i Default Config"
        $settings = Get-Content ".\Settings\Default\cba_settings.sqf" -Raw
    }

    #build settings file and write out.
    "$settings`n`n$comment`n$str1$i$str2" > ".\addons\cba_settings_userconfig\cba_settings.sqf"
    #create output folder
    New-Item -Path ".\Output\" -Name "@21st_cba_settings_$i" -ItemType "directory"
    #build addon
    & "$addonBuilder" "$(Get-Location)\addons\cba_settings_userconfig" "$(Get-Location)\Output\@21st_cba_settings_$i\addons\cba_settings_userconfig.pbo" -prefix="cba_settings_userconfig" -clear -include="include.txt"
    #move addon to correct place and clean up
    Rename-Item ".\Output\@21st_cba_settings_$i\addons\cba_settings_userconfig.pbo" "out"
    Move-Item ".\Output\@21st_cba_settings_$i\addons\out\cba_settings_userconfig.pbo" ".\Output\@21st_cba_settings_$i\addons\"
    Remove-Item ".\Output\@21st_cba_settings_$i\addons\out"   

    #Publish Addon
    if($publish -eq $true){
        & $publisherCmd update /id:$id /changenote:"See: https://github.com/21st-SAB/cba-settings" /path:"$(Get-Location)\Output\@21st_cba_settings_$i"
    }
}

#puts all the addons into a zip file
Compress-Archive -Path ".\Output\@*" -DestinationPath ".\21st-all-settings.zip" -Force
