# =========================================
# Dex Game Configs - Menu Launcher
# Mismo esquema visual que DexSuite CleanUp:
# #564A94 (purpura DexSuite) sobre fondo negro,
# marcos de 64 columnas y secciones separadas.
# =========================================

# ADMIN CHECK
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Start-Process PowerShell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$ErrorActionPreference = "SilentlyContinue"

$base = "https://raw.githubusercontent.com/SrDexterGF/Game_Configs/main"

# --- Colores --------------------------------------------------
# Secuencias VT 24-bit (Windows 10/11). DarkMagenta como fallback.
$esc    = [char]27
$style  = "$esc[38;2;86;74;148m$esc[48;2;0;0;0m"
$reset  = "$esc[0m"

function Apply-Style { Write-Host -NoNewline $style }

$Host.UI.RawUI.ForegroundColor = "DarkMagenta"
$Host.UI.RawUI.BackgroundColor = "Black"
Clear-Host
Apply-Style

# --- Helpers de marco -----------------------------------------
# Marcos de 64 columnas (1 espacio inicial + 1 borde + 62 contenido + 1 borde).
$BAR = " +==============================================================+"
$SUB = " +--------------------------------------------------------------+"
$EM  = " |                                                              |"

function BoxCenter([string]$text) {
    $w = 62
    if ($text.Length -ge $w) { return " |" + $text.Substring(0, $w) + "|" }
    $pad   = $w - $text.Length
    $left  = [Math]::Floor($pad / 2)
    $right = $pad - $left
    return " |" + (' ' * $left) + $text + (' ' * $right) + "|"
}

function BoxLine([string]$text) {
    $w = 62
    if ($text.Length -ge $w) { return " |" + $text.Substring(0, $w) + "|" }
    return " |" + $text.PadRight($w) + "|"
}

function Pause-Key {
    Write-Host "`n  Pulsa una tecla para volver al menu..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Run($path) {
    irm "$base/$path" | iex
    # Re-aplica color por si el script ejecutado reseteo el estilo.
    Apply-Style
}

function Menu {
    Clear-Host
    Apply-Style
    Write-Host $BAR
    Write-Host $EM
    Write-Host (BoxCenter "Dex Game Configs Toolkit")
    Write-Host (BoxCenter "Optimizacion para videojuegos")
    Write-Host (BoxCenter "by Sr. Dexter")
    Write-Host $EM
    Write-Host $SUB
    Write-Host $EM
    Write-Host (BoxLine "     [1]   PUBG")
    Write-Host (BoxLine "     [2]   Frag Punk")
    Write-Host (BoxLine "     [3]   Splitgate")
    Write-Host (BoxLine "     [4]   The Finals")
    Write-Host (BoxLine "     [5]   ARC Raiders")
    Write-Host (BoxLine "     [6]   Battlefield")
    Write-Host (BoxLine "     [7]   Delta Force")
    Write-Host (BoxLine "     [8]   Call of Duty")
    Write-Host (BoxLine "     [9]   Marvel Rivals")
    Write-Host (BoxLine "    [10]   Counter Strike 2")
    Write-Host (BoxLine "    [11]   Star Wars Battlefront")
    Write-Host $EM
    Write-Host $SUB
    Write-Host $EM
    Write-Host (BoxLine "     [0]   Salir")
    Write-Host $EM
    Write-Host $BAR
    Write-Host ""
}

function SubMenu([string]$title, [string[]]$items) {
    Clear-Host
    Apply-Style
    Write-Host $BAR
    Write-Host $EM
    Write-Host (BoxCenter $title)
    Write-Host $EM
    Write-Host $SUB
    Write-Host $EM
    foreach ($item in $items) {
        Write-Host (BoxLine $item)
    }
    Write-Host $EM
    Write-Host $SUB
    Write-Host $EM
    Write-Host (BoxLine "     [0]   Volver al menu principal")
    Write-Host $EM
    Write-Host $BAR
    Write-Host ""
}

while ($true) {

    Menu
    $c = Read-Host "  Tu eleccion"

    switch ($c) {

        "1" { Run "PUBG BATTLEGROUNDS/PUBG BATTLEGROUNDS.ps1"; Pause-Key }

        "2" { Run "Frag Punk/Frag Punk.ps1"; Pause-Key }

        "3" {
            SubMenu "Splitgate" @(
                "     [1]   Splitgate 1",
                "     [2]   Splitgate 2"
            )
            $g = Read-Host "  Tu eleccion"
            switch ($g) {
                "1" { Run "Splitgate/Splitgate 1.ps1"; Pause-Key }
                "2" { Run "Splitgate/Splitgate 2.ps1"; Pause-Key }
                "0" { }
            }
        }

        "4" { Run "The Finals/The Finals.ps1"; Pause-Key }

        "5" { Run "ARC Raiders/ARC Raiders.ps1"; Pause-Key }

        "6" {
            SubMenu "Battlefield" @(
                "     [1]   Bad Company 2  (2010)",
                "     [2]   BF3            (2011)",
                "     [3]   BF4            (2013)",
                "     [4]   Hardline       (2015)",
                "     [5]   BF1            (2016)",
                "     [6]   BFV            (2018)",
                "     [7]   BF2042         (2021)",
                "     [8]   BF6            (2025)"
            )
            $g = Read-Host "  Tu eleccion"
            switch ($g) {
                "1" { Run "Battlefield/Battlefield Bad Company 2.ps1"; Pause-Key }
                "2" { Run "Battlefield/Battlefield 3.ps1"; Pause-Key }
                "3" { Run "Battlefield/Battlefield 4.ps1"; Pause-Key }
                "4" { Run "Battlefield/Battlefield Hardline.ps1"; Pause-Key }
                "5" { Run "Battlefield/Battlefield 1.ps1"; Pause-Key }
                "6" { Run "Battlefield/Battlefield V.ps1"; Pause-Key }
                "7" { Run "Battlefield/Battlefield 2042.ps1"; Pause-Key }
                "8" { Run "Battlefield/Battlefield 6.ps1"; Pause-Key }
                "0" { }
            }
        }

        "7" { Run "Delta Force/Delta Force.ps1"; Pause-Key }

        "8" {
            SubMenu "Call of Duty" @(
                "     [1]   Black Ops 4           (2018)",
                "     [2]   Modern Warfare        (2019)",
                "     [3]   Black Ops Cold War    (2020)",
                "     [4]   Vanguard              (2021)",
                "     [5]   Modern Warfare 2      (2022)",
                "     [6]   Modern Warfare 3      (2023)",
                "     [7]   Black Ops 6 / Warzone (2024)",
                "     [8]   Black Ops 7           (2025)"
            )
            $g = Read-Host "  Tu eleccion"
            switch ($g) {
                "1" { Run "Call of Duty/Call of Duty Black Ops 4.ps1"; Pause-Key }
                "2" { Run "Call of Duty/Call of Duty Modern Warfare 2019.ps1"; Pause-Key }
                "3" { Run "Call of Duty/Call of Duty Black Ops Cold War.ps1"; Pause-Key }
                "4" { Run "Call of Duty/Call of Duty Vanguard.ps1"; Pause-Key }
                "5" { Run "Call of Duty/Call of Duty Modern Warfare 2 2022.ps1"; Pause-Key }
                "6" { Run "Call of Duty/Call of Duty Modern Warfare 3 2023.ps1"; Pause-Key }
                "7" { Run "Call of Duty/Call of Duty Black Ops 6.ps1"; Pause-Key }
                "8" { Run "Call of Duty/Call of Duty Black Ops 7.ps1"; Pause-Key }
                "0" { }
            }
        }

        "9"  { Run "Marvel Rivals/Marvel Rivals.ps1"; Pause-Key }

        "10" { Run "Counter Strike 2/Counter Strike 2.ps1"; Pause-Key }

        "11" {
            SubMenu "Star Wars Battlefront" @(
                "     [1]   Battlefront I (2015)",
                "     [2]   Battlefront II (2017)"
            )
            $g = Read-Host "  Tu eleccion"
            switch ($g) {
                "1" { Run "STAR WARS Battlefront/STAR WARS Battlefront I 2015.ps1"; Pause-Key }
                "2" { Run "STAR WARS Battlefront/STAR WARS Battlefront II 2017.ps1"; Pause-Key }
                "0" { }
            }
        }

        "0" {
            Write-Host $reset -NoNewline
            exit
        }
    }
}
