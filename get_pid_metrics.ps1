
function get_performances( [String]$proc_id ) {
    
    # get the process name
    $ProcessName = (Get-Process -Id $proc_id).Name
    $ProcessName
    #Directory where the restult file will be stored.
    $outputDirectory = "YOUR_DIRECTORY" 
    #Set the Computer from which to collect counters. Leave blank for local computer.
    $computerName = "" 
    #Collection interval in seconds.
    $sampleInterval = 15
    #How many samples should be collected at the interval specified. Set to 0 for continuous collection.
    $maxSamples = 240 
 
    #Check to see if the output directory exists. If not, create it. 
     if (-not(Test-Path $outputDirectory))
            {
                Write-Host "Output directory does not exist. Directory will be created."
                $null = New-Item -Path $outputDirectory -ItemType "Directory"
                Write-Host "Output directory created."
            }
 
    #Strip the \ off the end of the directory if necessary. 
    if ($outputDirectory.EndsWith("\")) {$outputDirectory = $outputDirectory.Substring(0, $outputDirectory.Length - 1)}
 
    #Create the name of the output file in the format of "computer date time.csv".
    $outputFile = "$outputDirectory\$(if($computerName -eq ''){$env:COMPUTERNAME} else {$computerName}) $(Get-Date -Format "yyyy_MM_dd HH_mm_ss").csv"
    $outputFile_blg = "$outputDirectory\$(if($computerName -eq ''){$env:COMPUTERNAME} else {$computerName}) $(Get-Date -Format "yyyy_MM_dd HH_mm_ss").blg"
 
    #Write the parameters to the screen.
    Write-Host "
 
    Collecting counters...
    Press Ctrl+C to exit."
 
    #Specify the list of performance counters to collect.
    $counters =
        @(
           "\Process($ProcessName*)\"    
               
        )
 
    #Set the variables for the Get-Counter cmdlet.
    $variables = @{
        SampleInterval = $sampleInterval
        Counter = $counters
    }
 
    #Add the computer name if it was not blank.
    if ($computerName -ne "") {$variables.Add("ComputerName","$computerName")}
     
    #Either set the sample interval or specify to collect continuous.
    if ($maxSamples -eq 0) {$variables.Add("Continuous",1)}
    else {$variables.Add("MaxSamples","$maxSamples")}
     
    #Show the variables then execute the command while storing the results in a file.
    $variables
    #Get-Counter @variables | Export-Counter -FileFormat csv -Path $outputFile -Force
    Get-Counter @variables | Export-Counter -FileFormat blg -Path $outputFile_blg -Force
    # relog   -f csv -o $outputFile
    relog -q $outputFile_blg >> $outputFile
}
get_performances("THE PID OF PROCESS ")