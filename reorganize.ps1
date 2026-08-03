# Set Root Project Path (Current Directory)
$projectRoot = Get-Location

Write-Host "Starting project reorganization at: $projectRoot" -ForegroundColor Cyan

# 1. Create Target Directory Structure
$directories = @(
    "entities\asteroid",
    "entities\player",
    "entities\selector",
    "entities\target",
    "entities\trail_line",
    "entities\grid_world",
    "entities\grid_overlay",
    "entities\tile_map_layer",
    "core",
    "systems\level_generator",
    "levels\demo_level"
)

foreach ($dir in $directories) {
    $fullPath = Join-Path $projectRoot $dir
    if (-not (Test-Path $fullPath)) {
        New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
        Write-Host "Created directory: $dir" -ForegroundColor Green
    }
}

# Helper function to move files safely if they exist
function Move-ProjectFile {
    param (
        [string]$SourceRelPath,
        [string]$TargetRelDir
    )
    $sourcePath = Join-Path $projectRoot $SourceRelPath
    $targetDir = Join-Path $projectRoot $TargetRelDir

    if (Test-Path $sourcePath) {
        Move-Item -Path $sourcePath -Destination $targetDir -Force
        # Move matching .uid file if present
        $uidPath = "$sourcePath.uid"
        if (Test-Path $uidPath) {
            Move-Item -Path $uidPath -Destination $targetDir -Force
        }
        Write-Host "Moved: $SourceRelPath -> $TargetRelDir" -ForegroundColor Yellow
    }
}

# 2. Move Entity Scenes & Scripts (Grouped Together)
Move-ProjectFile "scenes\entities\asteroid.tscn" "entities\asteroid"
Move-ProjectFile "scripts\entities\asteroid.gd" "entities\asteroid"

Move-ProjectFile "scenes\player.tscn" "entities\player"
Move-ProjectFile "scripts\entities\player.gd" "entities\player"

Move-ProjectFile "scenes\entities\selector.tscn" "entities\selector"
Move-ProjectFile "scripts\entities\selector.gd" "entities\selector"

Move-ProjectFile "scenes\entities\target.tscn" "entities\target"
Move-ProjectFile "scripts\entities\target.gd" "entities\target"

Move-ProjectFile "scenes\entities\trail_line.tscn" "entities\trail_line"
Move-ProjectFile "scripts\entities\trail_line.gd" "entities\trail_line"

Move-ProjectFile "scenes\grid_world.tscn" "entities\grid_world"
Move-ProjectFile "scripts\grid_world.gd" "entities\grid_world"

Move-ProjectFile "scripts\entities\grid_overlay.gd" "entities\grid_overlay"
Move-ProjectFile "scripts\entities\tile_map_layer.gd" "entities\tile_map_layer"

# 3. Move Core / Base Scripts
Move-ProjectFile "scripts\classes\base_camera.gd" "core"
Move-ProjectFile "scripts\classes\base_level.gd" "core"
Move-ProjectFile "scripts\classes\grid_object.gd" "core"
Move-ProjectFile "scripts\base_level_inputs.gd" "core"
Move-ProjectFile "scripts\debug.gd" "core"

# 4. Move Systems / Algorithms
Move-ProjectFile "scripts\level_generator\grid_scanner.gd" "systems\level_generator"
Move-ProjectFile "scripts\level_generator\level_generator.gd" "systems\level_generator"
Move-ProjectFile "scripts\level_generator\network_analyzer.gd" "systems\level_generator"
Move-ProjectFile "scripts\level_generator\network_cleaner.gd" "systems\level_generator"

# 5. Move Levels & Level Documents
Move-ProjectFile "scenes\levels\demo_level.tscn" "levels\demo_level"
Move-ProjectFile "scripts\demo_level.gd" "levels\demo_level"
Move-ProjectFile "scenes\levels\level_plans.md" "levels"

# 6. Cleanup empty source folders if applicable
$oldFolders = @("scenes\entities", "scenes\levels", "scenes", "scripts\classes", "scripts\entities", "scripts\level_generator", "scripts")
foreach ($folder in $oldFolders) {
    $fullPath = Join-Path $projectRoot $folder
    if ((Test-Path $fullPath) -and (Get-ChildItem $fullPath).Count -eq 0) {
        Remove-Item -Path $fullPath -Force
        Write-Host "Removed empty directory: $folder" -ForegroundColor DarkGray
    }
}

Write-Host "`nReorganization completed successfully!" -ForegroundColor Cyan