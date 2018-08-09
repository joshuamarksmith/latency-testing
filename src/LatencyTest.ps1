#########################################################
# Powershell Latency Test Script
# @author joshuamarksmith
#
# Usage: Supply an optional number of tests
#	     .\LatencyTest.ps1 10 -- runs 10 tests
#
# Returns: a CSV file containing raw data and a console
# 	       output of the average, min, and msx latency
#########################################################

$dest = YOUR_URL_HERE
$defaultIterations = 5
$currentTime = Get-Date -Format -yyyy-MM-dd-HH-mm-ss
$stopwatch = [System.Diagnostics.Stopwatch]::new()
$tempProg = $progressPreference
$times = [System.Collections.ArrayList]::new()

<#
# Bypass SSL errors
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = `
	New-Object TrustAllCertsPolicy
#>

# Set number of tests to user supplied variable or to default
if ($args.Count -eq 0) {
	$warning = "No parameter supplied, e.g. LatencyTest.ps1 " +
			   "10 -- defaulting to 5."
	Write-Warning $warning
	$iterations = $defaultIterations
} else { $iterations = $($args[0]) }

# Create a container for the results
$result = @{
	PSTypeName = 'LatencyResult'
	ComputerName = $env:COMPUTERNAME
	Destination = $dest
}

# Run the requests
Write-Host "Running $iterations tests..."
$progressPreference = 'SilentlyContinue' # no progress bar
for ($i = 0; $i -lt $iterations; $i++) {
	$stopwatch.Start()
	Invoke-WebRequest -Uri $dest -UseBasicParsing > null
	$stopwatch.Stop()
	
	$times.Add($stopwatch.ElapsedMilliseconds) > null
	
	$stopwatch.Reset()
}
$progressPreference = $tempProg

foreach($time in $times) {
	$time, " at " | Add-Content -Path "result$currentTime.csv" -NoNewLine
	Get-Date -Format HH:mm:ss | Add-Content -Path "result$currentTime.csv"
}

# Add data to results
$result.Average_ms = ($times | Measure-Object -Average).Average
$result.Minimum_ms = ($times | Measure-Object -Minimum).Minimum
$result.Maximum_ms = ($times | Measure-Object -Maximum).Maximum

# Add results and print
$finalResult = [PSCustomObject]$result
Write-Output $finalResult
Write-Host "Results written to result$currentTime.csv"
