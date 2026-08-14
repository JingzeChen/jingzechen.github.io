param(
    [Parameter(Mandatory = $true)]
    [string]$SourceDirectory,

    [Parameter(Mandatory = $true)]
    [string]$OutputDirectory,

    [string]$Pattern = "*.pptx",

    [int]$Width = 1024,

    [int]$Height = 768,

    [switch]$Force
)

$ErrorActionPreference = "Stop"
$source = (Resolve-Path $SourceDirectory).Path
New-Item -ItemType Directory -Path $OutputDirectory -Force | Out-Null
$output = (Resolve-Path $OutputDirectory).Path
$presentations = Get-ChildItem -Path $source -Filter $Pattern -File | Sort-Object Name

if ($presentations.Count -eq 0) {
    throw "No PowerPoint files matched '$Pattern' in '$source'."
}

$powerPoint = $null
$renderedDecks = 0
$renderedSlides = 0

try {
    $powerPoint = New-Object -ComObject PowerPoint.Application

    foreach ($sourceFile in $presentations) {
        $deckOutput = Join-Path $output $sourceFile.BaseName
        New-Item -ItemType Directory -Path $deckOutput -Force | Out-Null
        $presentation = $null

        try {
            $presentation = $powerPoint.Presentations.Open($sourceFile.FullName, $true, $true, $false)
            $expectedSlides = $presentation.Slides.Count
            $existingSlides = @(Get-ChildItem -Path $deckOutput -Filter "slide-*.jpg" -File).Count

            if (-not $Force -and $existingSlides -eq $expectedSlides) {
                Write-Output "SKIP $($sourceFile.Name) ($expectedSlides slides)"
                continue
            }

            Get-ChildItem -Path $deckOutput -Filter "slide-*.jpg" -File | Remove-Item -Force
            for ($index = 1; $index -le $expectedSlides; $index += 1) {
                $slidePath = Join-Path $deckOutput ("slide-{0:D3}.jpg" -f $index)
                $presentation.Slides.Item($index).Export($slidePath, "JPG", $Width, $Height)
            }

            $renderedDecks += 1
            $renderedSlides += $expectedSlides
            Write-Output "DONE $($sourceFile.Name) ($expectedSlides slides)"
        }
        finally {
            if ($null -ne $presentation) {
                $presentation.Close()
                [void][Runtime.InteropServices.Marshal]::ReleaseComObject($presentation)
            }
        }
    }
}
finally {
    if ($null -ne $powerPoint) {
        $powerPoint.Quit()
        [void][Runtime.InteropServices.Marshal]::ReleaseComObject($powerPoint)
    }
    [GC]::Collect()
    [GC]::WaitForPendingFinalizers()
}

Write-Output "Rendered $renderedSlides slides from $renderedDecks decks."