$packageName = 'haxedevelop'
$installerType = 'EXE'
$32BitUrl  = 'http://www.haxedevelop.org/releases/4.7.0/FlashDevelop-4.7.0.exe'
$silentArgs = '/S'
$validExitCodes = @(0)

Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$32BitUrl" -validExitCodes $validExitCodes