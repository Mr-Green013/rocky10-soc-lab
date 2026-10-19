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
      # EN: Delete the OS disk with the VM on destroy, so no leftover disk keeps costing money
      # ลบ OS disk พร้อม VM ตอน destroy เพื่อไม่ให้มี disk ค้างคิดเงิน
      delete_os_disk_on_deletion = true
    }
  }

  # EN: null = use ARM_SUBSCRIPTION_ID or the current az CLI subscription
  # null = ใช้ ARM_SUBSCRIPTION_ID หรือ subscription ปัจจุบันของ az CLI
  subscription_id = var.subscription_id
}
