# PowerShell script to update all imports to new structure
# This will fix all relative imports to use package imports

$ErrorActionPreference = "Continue"

# Define import mappings (old pattern -> new pattern)
$importMappings = @{
    # Core services
    "import 'auth_service.dart';" = "import 'package:cemas/core/services/auth_service.dart';"
    "import '../auth_service.dart';" = "import 'package:cemas/core/services/auth_service.dart';"
    
    # UMKM services
    "import 'seller_service.dart';" = "import 'package:cemas/features/umkm/services/seller_service.dart';"
    "import '../seller_service.dart';" = "import 'package:cemas/features/umkm/services/seller_service.dart';"
    
    # UMKM pages
    "import 'dashboard_toko_page.dart';" = "import 'package:cemas/features/umkm/pages/dashboard_toko_page.dart';"
    "import 'kelola_toko_page.dart';" = "import 'package:cemas/features/umkm/pages/kelola_toko_page.dart';"
    "import 'form_produk_page.dart';" = "import 'package:cemas/features/umkm/pages/form_produk_page.dart';"
    
    # UMKM registration
    "import 'registration_model.dart';" = "import 'package:cemas/features/umkm/models/registration_model.dart';"
    "import 'step_akun.dart';" = "import 'package:cemas/features/umkm/pages/registration/step_akun.dart';"
    "import 'step_pemilik.dart';" = "import 'package:cemas/features/umkm/pages/registration/step_pemilik.dart';"
    "import 'step_umkm.dart';" = "import 'package:cemas/features/umkm/pages/registration/step_umkm.dart';"
    "import 'step_kontak.dart';" = "import 'package:cemas/features/umkm/pages/registration/step_kontak.dart';"
    "import 'step_review.dart';" = "import 'package:cemas/features/umkm/pages/registration/step_review.dart';"
    "import 'umkm_features/daftar_umkm_main.dart';" = "import 'package:cemas/features/umkm/pages/registration/daftar_umkm_main.dart';"
    
    # User pages
    "import 'beranda_page.dart';" = "import 'package:cemas/features/user/pages/beranda_page.dart';"
    "import 'umkm_page.dart';" = "import 'package:cemas/features/user/pages/umkm_page.dart';"
    "import 'umkm_search_page.dart';" = "import 'package:cemas/features/user/pages/umkm_search_page.dart';"
    "import 'detail_toko_page.dart';" = "import 'package:cemas/features/user/pages/detail_toko_page.dart';"
    "import 'nilai_umkm_page.dart';" = "import 'package:cemas/features/user/pages/nilai_umkm_page.dart';"
    "import 'nilai_umkm_berhasil_page.dart';" = "import 'package:cemas/features/user/pages/nilai_umkm_berhasil_page.dart';"
    
    # User widgets
    "import 'umkm_card.dart';" = "import 'package:cemas/features/user/widgets/umkm_card.dart';"
    "import 'umkm_list_tile.dart';" = "import 'package:cemas/features/user/widgets/umkm_list_tile.dart';"
    "import 'umkm_search_results.dart';" = "import 'package:cemas/features/user/widgets/umkm_search_results.dart';"
    
    # Shared pages
    "import 'main_page.dart';" = "import 'package:cemas/shared/pages/main_page.dart';"
    "import 'login_page.dart';" = "import 'package:cemas/shared/pages/login_page.dart';"
    "import 'signup_page.dart';" = "import 'package:cemas/shared/pages/signup_page.dart';"
    "import 'akun_page.dart';" = "import 'package:cemas/shared/pages/akun_page.dart';"
    "import 'profile_page.dart';" = "import 'package:cemas/shared/pages/profile_page.dart';"
    "import 'notifikasi_page.dart';" = "import 'package:cemas/shared/pages/notifikasi_page.dart';"
    "import 'detail_notifikasi_page.dart';" = "import 'package:cemas/shared/pages/detail_notifikasi_page.dart';"
    "import 'tentang_kami.dart';" = "import 'package:cemas/shared/pages/tentang_kami.dart';"
}

# Get all Dart files
$dartFiles = Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse

Write-Host "Found $($dartFiles.Count) Dart files to process..."

$filesModified = 0

foreach ($file in $dartFiles) {
    $content = Get-Content $file.FullName -Raw
    $originalContent = $content
    $modified = $false
    
    # Apply each mapping
    foreach ($mapping in $importMappings.GetEnumerator()) {
        if ($content -match [regex]::Escape($mapping.Key)) {
            $content = $content -replace [regex]::Escape($mapping.Key), $mapping.Value
            $modified = $true
        }
    }
    
    # Save if modified
    if ($modified) {
        Set-Content -Path $file.FullName -Value $content -NoNewline
        $filesModified++
        Write-Host "Updated: $($file.FullName)"
    }
}

Write-Host "`nCompleted! Modified $filesModified files."
