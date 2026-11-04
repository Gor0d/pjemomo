# Diagnostico somente-leitura para PJe / token A3. Nao altera nada.
$out = Join-Path ([Environment]::GetFolderPath('Desktop')) 'diagnostico-pje.txt'
$r = @()
$r += "Data: $(Get-Date)"; $r += "PC: $env:COMPUTERNAME"
$r += (Get-CimInstance Win32_OperatingSystem | % { "Windows: $($_.Caption) $($_.Version) $($_.OSArchitecture)" })

$r += "`n== Programas relacionados =="
$keys='HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*','HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*','HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*'
$r += Get-ItemProperty $keys -ErrorAction SilentlyContinue | ? { $_.DisplayName -match 'pje|java|safenet|etoken|gemalto|idprime|token|certif|watchdata|safesign|bit4|oracle|chrome|firefox|edge' } |
  % { "$($_.DisplayName) | $($_.DisplayVersion) | $($_.Publisher) | $($_.InstallLocation)" }

$r += "`n== Leitores / tokens (PnP) =="
$r += Get-PnpDevice -ErrorAction SilentlyContinue | ? { $_.Class -match 'SmartCard' -or $_.FriendlyName -match 'token|etoken|safenet|smart ?card|idprime|watchdata' } | % { "$($_.Status) | $($_.Class) | $($_.FriendlyName)" }

$r += "`n== Servico Smart Card =="
$r += Get-Service SCardSvr -ErrorAction SilentlyContinue | % { "SCardSvr: $($_.Status) / $($_.StartType)" }

$r += "`n== Bibliotecas PKCS11 conhecidas =="
foreach ($f in 'eTPKCS11.dll','eToken.dll','aetpkss1.dll','IDPrimePKCS11.dll','dkck201.dll','cmP11.dll','asepkcs.dll','SignatureP11.dll','gclib.dll','WDPKCS.dll','ngp11v211.dll') {
  foreach ($d in "$env:SystemRoot\System32","$env:SystemRoot\SysWOW64") { if (Test-Path "$d\$f") { $r += "$d\$f" } }
}

$r += "`n== Certificados pessoais (nome, validade) =="
$r += Get-ChildItem Cert:\CurrentUser\My -ErrorAction SilentlyContinue | % { "$($_.Subject) | ate $($_.NotAfter) | emissor: $($_.Issuer)" }

$r += "`n== PJeOffice =="
$p = Get-Process | ? { $_.Name -match 'pje' }; $r += ($p | % { "Processo: $($_.Name) ($($_.Id))" })
foreach ($d in "$env:ProgramFiles\PJeOffice*","${env:ProgramFiles(x86)}\PJeOffice*","$env:LOCALAPPDATA\Programs\PJeOffice*","$env:USERPROFILE\.pjeoffice*","$env:USERPROFILE\.pjeoffice-pro*") {
  Get-ChildItem $d -ErrorAction SilentlyContinue | % { $r += "Pasta: $($_.FullName)" }
}
$r += Get-ChildItem "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup","$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Startup" -ErrorAction SilentlyContinue | ? { $_.Name -match 'pje' } | % { "Inicializacao: $($_.FullName)" }
$r += Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -ErrorAction SilentlyContinue | % { $_.PSObject.Properties | ? { $_.Name -match 'pje' } | % { "Run: $($_.Name) = $($_.Value)" } }

$r += "`n== Java no PATH =="
$r += (Get-Command java -ErrorAction SilentlyContinue | % { $_.Source })

$r | Out-File $out -Encoding utf8
Write-Host "Pronto. Arquivo gerado: $out"
