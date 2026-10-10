terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.40"
    }
  }
}

provider "azurerm" {
  features {
    virtual_machine {
      # ลบ OS disk พร้อม VM ตอน destroy เพื่อไม่ให้มี disk ค้างคิดเงิน
      delete_os_disk_on_deletion = true
    }
  }

  # null = ใช้ ARM_SUBSCRIPTION_ID หรือ subscription ปัจจุบันของ az CLI
  subscription_id = var.subscription_id
}
