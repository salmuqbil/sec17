#Saleh Almuqbil - PowerShell Final - August 24th, 2017

function mainExam(){
    param(
        [Parameter(ParameterSetName='survey')]
        [string] $survey,
        [Parameter(ParameterSetName='hashing')]
        [string] $hashdir,
        $hashfile,
        [Parameter(ParameterSetName='menu')]
        [switch] $custom
    )
    $option =  $PSCmdlet.ParameterSetName
    if($option -eq "survey"){
        runSurvey
    }
    if ($option -eq "hashing"){
        runHashdir
    }
    if ($option -eq "menu"){
        runCustom
    }
    if(-not ($survey -or $hashdir -or $custom)){
        echo "None"
    }
}

<#
Usage: -survey	[outfile]

This function will get an output file in the argument
then, it will type the follwing in the output file:
- Computername
- Date/Time
- OS Version
- List of all processes, sorted by session
- List of all open sockets
#>
function runSurvey(){
    Write-Host -NoNewline "Survey is running ..."

    $computerName = (hostname)
    $currentDate = (date)
    Write-Host -NoNewline "..."
    $osVersion = (Get-CimInstance Win32_OperatingSystem | select version,osarchitecture)
    $proc = (Get-Process | Sort-Object sessionid)
    $openSockets = (netstat -ano)

    Write-Host -NoNewline "..."

    echo "Survey results: `n`n" > $survey
    echo "Computer Name: $computerName" >> $survey
    echo "Date: $currentDate" >> $survey

    Write-Host -NoNewline "..."
    echo "`n`n" >> $survey
    echo $osVersion >> $survey
    echo "`n`n" >> $survey
    echo $proc >> $survey
    echo "`n`n" >> $survey
    echo $openSockets >> $survey

    echo "... Done!"
}

<#
Usage: -hashdir <dir> -hashfile [outfile]

This function will tet contents of directory,
and generate and save a hash of each file in the directory

#>
function runHashdir(){

    If(!(test-path $hashdir)){
        echo "no such directory exists"
    }
    else{

        Write-Host -NoNewline "Hashing is running ..."

        $dirFiles = (Get-ChildItem $hashdir -Recurse)

        echo "File Hashes for $hashdir :" > $hashfile

        foreach ($file in $dirFiles) {

            Write-Host -NoNewline "."

            if($file -is [System.IO.DirectoryInfo]){
                continue
            }
            else{
                $filePath = ($file.fullname)
                $hashed = (Get-FileHash $filePath | Select -ExpandProperty hash)

                echo "" >> $hashfile
                echo "File: $filePath" >> $hashfile
                echo "Hash: $hashed" >> $hashfile
                echo "" >> $hashfile
            }
        }
        echo ".. Done!"
    }
}

<#
Usage -cutsom

This function will run SALEH COMMAND, where you can get more
information about the System, Services, Scheduled Tasks, .
#>
function runCustom(){
    echo "               __    __ __      __               "
    echo "          |  ||_ |  /  /  \|\/||_                "
    echo "          |/\||__|__\__\__/|  ||__               "
    echo "   __        __       __ __                  __  "
    echo "  (_  /\ |  |_ |__|  /  /  \|\/||\/| /\ |\ ||  \ "
    echo "  __)/--\|__|__|  |  \__\__/|  ||  |/--\| \||__/ "
    echo "                                                 "

    commandLoop

    echo "    ___   __    __  ____    ____  _  _  ____ "
    echo "   / __) /  \  /  \(    \  (  _ \( \/ )(  __)"
    echo "  ( (_ \(  O )(  O )) D (   ) _ ( )  /  ) _) "
    echo "   \___/ \__/  \__/(____/  (____/(__/  (____)"
}

#Main loop to run SALEH COMMAND, where it will take user input
#and based on it, it will run the required commands.
function commandLoop(){
    while(1){
        $userInput = Read-Host "Main Menu >> "
        if($userInput -cmatch "(q|quit)")
        {
            break
        }
        elseif ($userInput -eq "services"){
            getServices
        }
        elseif ($userInput -eq "scheduledTasks"){
            echo "in SCHTASKS"
            getscheduledTasks
        }
        elseif ($userInput -eq "BIOS"){
            getBIOS
        }
        elseif ($userInput -eq "showHidden"){
            getHidden
        }
        elseif ($userInput -eq "showLog"){
            getLogs
        }
        else{
            echo "q|quit : to exit the script"
            echo "services : to get the running services"
            echo "scheduledTasks : to get the scheduled tasks"
            echo "BIOS : to get BIOS information"
            echo "showHidden : to get hidden files in a directory"
            echo "showLog : to get the logs"
        }
    }
}

#This function will get the services running, and more information if requested.
function getServices(){
    $currentServices = (Get-WmiObject -Class Win32_Service)

    echo ($currentServices | fl Name, DisplayName)
    
    $userInput = Read-Host "type the name of the service to get more info, or [Enter] to go back to main menu"
    
    if($userInput -eq "")
    {
        echo "Back to Main Menu ..."
    }
    else{

        $curService = ($currentServices | Where-Object {$_.name -eq "$userInput"} | fl Name, DisplayName, Description, StartMode, State, Status, PathName, ProcessID, @{Label="Running as"; Expression={$_.StartName}})
    
        if($curService.length -eq 0){
            echo "there is no such service $curService"
        }
        else{
            echo $curService
            $procID = ($currentServices | Where-Object {$_.name -eq "$userInput"} | select -ExpandProperty processid)
            Get-Process -id $procID
            echo ""
            Get-Process -id $procID | foreach {$_.modules}
        }
    }
}

#This function will get the scheduled tasks and show more information if requested.
function getscheduledTasks(){
    
    $currentTasks = schtasks
    echo $currentTasks

    $userInput = Read-Host "type the TaskName to get more info, or [Enter] to go back to main menu"
    
    if($userInput -eq "")
    {
        echo "Back to Main Menu ..."
    }
    else{
        Get-ScheduledTask | Where-Object {$_.TaskName -eq "$userInput"} | fl -Property *
    }
}

#This function will show the BIOS
function getBIOS(){
    Get-WmiObject -Class win32_bios
}

#This function will show hidden files in a directory
function getHidden(){

    $userInput = Read-Host "Please input the directory"
    try{
        If(!(test-path $userInput)){
            echo "no such directory exists"
        }
        else{
            echo
            (Get-ChildItem $userInput -Force -Attributes h)
        }
    }catch{
        echo "something went wrong, please try again"
    }
}

#This function will get the logs of the system
function getLogs(){
    Get-eventlog -list
    
    $userInput = Read-Host "Please input the log name"
    try{
        Get-EventLog -LogName $userInput
    }
    catch {
        echo "something went wrong, please try again"
    }
}