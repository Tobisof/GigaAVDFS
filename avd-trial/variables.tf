variable "subscription_id" {
  description = "ID subskrypcji Azure, w której zostanie wdrożone środowisko AVD."
  type        = string
}

variable "tenant_id" {
  description = "ID dzierżawy (tenant) Entra ID."
  type        = string
}

variable "location" {
  description = "Region Azure, w którym powstaną zasoby (domyślnie West Europe)."
  type        = string
  default     = "westeurope"
}

variable "project_name" {
  description = "Prefiks wykorzystywany w nazwach zasobów."
  type        = string
  default     = "gigaavdfs"
}

variable "admin_username" {
  description = "Lokalny administrator systemu Windows na maszynach sesyjnych."
  type        = string
  default     = "localadmin"
}

variable "admin_password" {
  description = "Hasło konta lokalnego administratora (spełniające wymagania Windows)."
  type        = string
  sensitive   = true
}

variable "avd_users_group_object_id" {
  description = "Object ID grupy Entra ID posiadającej dostęp do AVD i udziału FSLogix."
  type        = string
}

variable "fslogix_share_quota_gb" {
  description = "Kwota (GB) udziału Azure Files przeznaczonego na profile FSLogix."
  type        = number
  default     = 100
}

variable "vm_size" {
  description = "Rozmiar maszyny sesyjnej AVD."
  type        = string
  default     = "Standard_D2as_v5"
}

variable "image_offer" {
  description = "Offer obrazu Windows (np. windows-11)."
  type        = string
  default     = "windows-11"
}

variable "image_publisher" {
  description = "Publisher obrazu Windows."
  type        = string
  default     = "microsoftwindowsdesktop"
}

variable "image_sku" {
  description = "SKU obrazu Windows multi-session (np. win11-23h2-avd). W razie braku w regionie można przełączyć na wariant Windows 10 multi-session."
  type        = string
  default     = "win11-23h2-avd"
}

variable "fslogix_download_url" {
  description = "URL do pakietu instalacyjnego FSLogix (MSI/ZIP). Domyślnie wskazuje na najnowszą wersję."
  type        = string
  default     = "https://aka.ms/fslogix-latest"
}

variable "avd_agent_url" {
  description = "URL do instalatora AVD Agent MSI."
  type        = string
  default     = "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWrmXv"
}

variable "avd_bootloader_url" {
  description = "URL do instalatora AVD Bootloader MSI."
  type        = string
  default     = "https://query.prod.cms.rt.microsoft.com/cms/api/am/binary/RWIz3Q"
}

variable "allowed_rdp_source_cidrs" {
  description = "Lista prefiksów CIDR, z których ruch RDP (3389) jest dozwolony. Zastąp domyślną wartość swoim publicznym adresem IP."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
