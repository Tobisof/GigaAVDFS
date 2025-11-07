terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.70.0"
    }

    random = {
      source = "hashicorp/random"
    }

    time = {
      source  = "hashicorp/time"
      version = ">= 0.13.0"
    }
  }
}
