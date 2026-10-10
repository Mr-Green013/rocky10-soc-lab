#
# ค่าที่ต้องกำหนดเอง: admin_source_cidrs และ admin_ssh_public_key_path
# ค่าอื่นมี default ตรงกับเอกสารหลักสูตร (IP plan 192.168.10.0/24, domain lab.internal)
#

variable "subscription_id" {
  description = "Azure subscription ID (null = ใช้ ARM_SUBSCRIPTION_ID หรือ subscription ปัจจุบันของ az CLI)"
  type        = string
  default     = null
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "southeastasia"
}

variable "prefix" {
  description = "คำนำหน้าชื่อ resource"
  type        = string
  default     = "soclab"

  validation {
    condition     = can(regex("^[a-z][a-z0-9]{2,11}$", var.prefix))
    error_message = "prefix ต้องเป็นตัวพิมพ์เล็กหรือตัวเลข 3-12 ตัว ขึ้นต้นด้วยตัวอักษร"
  }
}

variable "admin_username" {
  description = "ผู้ใช้ผู้ดูแลระบบบนทุกเครื่อง (เอกสารหลักสูตรใช้ aod)"
  type        = string
  default     = "aod"
}

variable "admin_ssh_public_key_path" {
  description = "path ของ SSH public key (ed25519 หรือ RSA >= 2048 bit)"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "admin_source_cidrs" {
  description = "Public IP ของผู้ดูแลที่อนุญาตให้ SSH เข้า admin-01 เช่น [\"203.0.113.10/32\"]"
  type        = list(string)

  validation {
    condition = length(var.admin_source_cidrs) > 0 && alltrue([
      for c in var.admin_source_cidrs : can(cidrhost(c, 0)) && !contains(["0.0.0.0/0", "*"], c)
    ])
    error_message = "ต้องระบุอย่างน้อย 1 CIDR ที่ถูกต้อง และห้ามใช้ 0.0.0.0/0"
  }
}

variable "vnet_cidr" {
  description = "Address space ของ VNet"
  type        = string
  default     = "192.168.0.0/16"
}

variable "lab_subnet_cidr" {
  description = "Subnet ของ lab (ต้องตรงกับ IP plan ในเอกสาร)"
  type        = string
  default     = "192.168.10.0/24"
}

variable "domain" {
  description = "DNS domain ของ lab"
  type        = string
  default     = "lab.internal"
}

variable "guest_timezone" {
  description = "Timezone ใน Linux (Lab 6)"
  type        = string
  default     = "Asia/Bangkok"
}

variable "use_ipa_dns" {
  description = "false = ใช้ Azure DNS (ก่อนติดตั้ง FreeIPA), true = ให้ VNet แจก ipa-01 เป็น DNS (หลัง Lab 11)"
  type        = bool
  default     = false
}

variable "package_upgrade" {
  description = "ให้ cloud-init รัน dnf upgrade ตอนสร้างเครื่องครั้งแรก"
  type        = bool
  default     = true
}

variable "vm_sizes" {
  description = "Override ขนาด VM รายเครื่อง เช่น { graylog-01 = \"Standard_D4as_v5\" }"
  type        = map(string)
  default     = {}
}

variable "os_disk_type" {
  description = "ชนิด OS disk"
  type        = string
  default     = "StandardSSD_LRS"

  validation {
    condition     = contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS"], var.os_disk_type)
    error_message = "ใช้ได้เฉพาะ Standard_LRS, StandardSSD_LRS หรือ Premium_LRS"
  }
}

#
# Image ของ Rocky Linux 10.1
#   source = "marketplace" ใช้ publisher/offer/sku (ตรวจชื่อจริงด้วย scripts/find-rocky-image.sh)
#   source = "image_id"    ใช้ image ID เช่น Community Gallery หรือ Azure Compute Gallery ของตัวเอง
#
variable "image" {
  description = "แหล่ง image ของ Rocky Linux"
  type = object({
    source        = string
    publisher     = optional(string, "resf")
    offer         = optional(string, "rockylinux-x86_64")
    sku           = optional(string, "10-base")
    version       = optional(string, "latest")
    plan_required = optional(bool, true)
    image_id      = optional(string)
  })
  default = {
    source = "marketplace"
  }

  validation {
    condition     = contains(["marketplace", "image_id"], var.image.source)
    error_message = "image.source ต้องเป็น marketplace หรือ image_id"
  }

  validation {
    condition     = var.image.source != "image_id" || try(length(var.image.image_id) > 0, false)
    error_message = "เมื่อ image.source = image_id ต้องกำหนด image.image_id"
  }
}

variable "accept_marketplace_terms" {
  description = "ให้ Terraform ยอมรับ terms ของ marketplace image (ทำครั้งเดียวต่อ subscription; ถ้ายอมรับด้วย az CLI แล้วให้ตั้ง false)"
  type        = bool
  default     = false
}

variable "auto_shutdown" {
  description = "ปิด VM อัตโนมัติทุกวัน (deallocate) เพื่อลดค่าใช้จ่าย"
  type = object({
    enabled  = optional(bool, true)
    time     = optional(string, "2200")
    timezone = optional(string, "SE Asia Standard Time")
    email    = optional(string)
  })
  default = {}

  validation {
    condition     = can(regex("^([01][0-9]|2[0-3])[0-5][0-9]$", var.auto_shutdown.time))
    error_message = "auto_shutdown.time ต้องอยู่ในรูป HHmm เช่น 2200"
  }
}

variable "tags" {
  description = "Tag เพิ่มเติม"
  type        = map(string)
  default     = {}
}
