# Azure Virtual Desktop trial (Terraform)

Kompletny, minimalistyczny projekt Terraform wdrażający pojedyncze środowisko Azure Virtual Desktop w oparciu o Entra ID Join oraz profile FSLogix na Azure Files (AAD Kerberos). Kod jest zoptymalizowany pod darmowy 30-dniowy trial, ale może zostać rozwinięty do produkcji.

## Wymagania wstępne
- Terraform >= 1.5
- Azure CLI z uprawnieniami Owner/Contributor w docelowej subskrypcji
- Konto Entra ID z możliwością tworzenia zasobów AVD i przypisywania ról

## Kroki uruchomienia
1. Zaloguj się do Azure: `az login --tenant <tenant_id>` oraz `az account set --subscription <subscription_id>`.
2. Skopiuj `terraform.tfvars.example` do `terraform.tfvars` i uzupełnij:
   - `subscription_id`, `tenant_id`
   - `admin_password`
   - `avd_users_group_object_id` (Object ID grupy Entra ID, np. `grp-avd-users`)
   - `allowed_rdp_source_cidrs` ustaw na swój publiczny adres IP (np. `"X.X.X.X/32"`).
   - (opcjonalnie) zaktualizuj `fslogix_download_url`, `avd_agent_url`, `avd_bootloader_url` na konkretne pakiety MSI jeżeli używasz innych lokalizacji.
3. W katalogu `avd-trial` wykonaj standardowy cykl Terraform:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```
4. Po wdrożeniu dodaj użytkowników do grupy z `avd_users_group_object_id` i poproś ich o logowanie przez klienta AVD lub Remote Desktop korzystając z poświadczeń Entra ID.

## Po wdrożeniu
- Sprawdź output `fslogix_share_path` – to UNC udziału: `\\<storage_account>.file.core.windows.net\\profiles`.
- Podczas pierwszego logowania użytkownika FSLogix utworzy `\\<storage_account>.file.core.windows.net\\profiles\<user>.vhdx`.
- Rola **Virtual Desktop User** i **Storage File Data SMB Share Contributor** jest przypisywana tej samej grupie – propagacja może potrwać 15–30 minut.
- VM otrzymuje harmonogram auto-shutdown o 22:00 czasu CET, aby ograniczyć koszty (możesz zmienić w `vm.tf`).

## Trial vs produkcja
- Trial: 1 host `Standard_D2as_v5`, Storage Premium ZRS (zamień na LRS jeśli region nie wspiera ZRS), brak skalowania.
- Produkcja: zwiększ liczbę hostów/VMSS, dodaj Scaling Plans, rozważ Azure Monitor + automatyczne patchowanie i kopie zapasowe, dodaj kontrolę ruchu wychodzącego (Azure Firewall/Firewall Policy).

## Weryfikacja działania
1. Upewnij się, że grupa użytkowników ma przypisane role (Azure Portal → resource group → Access control).
2. Na kliencie AVD skonfiguruj Workspace (`https://rdweb.wvd.microsoft.com`).
3. Zaloguj się kontem Entra ID – VM powinna być Joined do Entra ID (rozszerzenie `AADLoginForWindows`).
4. Na koncie administracyjnym sprawdź w `C:\Users` czy brak lokalnych profili – FSLogix montuje VHDX z udziału SMB.
5. W Azure Files weryfikuj utworzone `*.vhdx` w udziale `profiles`.

## Troubleshooting (najczęstsze przypadki)
1. **RBAC propagation** – odczekaj 15–30 min po przypisaniu ról zanim użytkownik spróbuje logowania.
2. **Brak dostępu do udziału FSLogix** – upewnij się, że VM jest Entra ID joined oraz że użytkownik jest w grupie z rolą `Storage File Data SMB Share Contributor` na udziale.
3. **Kerberos AAD disabled** – sprawdź, czy Storage Account ma `AADKERB` oraz że subskrypcja jest zarejestrowana dla funkcji `Microsoft.Storage` (polecenie `az feature register`).
4. **AVD Agent/Bootloader stale w stanie Not registered** – zweryfikuj poprawność tokenu (`time_offset` generuje ważność 48h) i ewentualnie ponownie uruchom instalator.
5. **FSLogix nie tworzy VHDX** – sprawdź klucze rejestru w `HKLM\SOFTWARE\FSLogix\Profiles`, upewnij się że ścieżka UNC jest dostępna (test `Test-Path`).
6. **Port 3389 zablokowany** – zaktualizuj `allowed_rdp_source_cidrs` lub dodaj dodatkowe reguły NSG dla ruchu diagnostycznego.
7. **ZRS niedostępne** – zmień `account_replication_type` w `storage.tf` na `LRS` (w komentarzu) i zaktualizuj plan.
8. **Auto-shutdown zbyt wcześnie** – dostosuj `daily_recurrence_time` lub wyłącz harmonogram.
