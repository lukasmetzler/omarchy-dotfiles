# System Optimization Log: Lenovo T14 Gen 5 (AMD)

**OS:** Omarchy (Arch-based)

**Bootloader:** Limine (Unified Kernel Images - UKI)

## 1. Applied Changes

### ACPI Standby Fix

* **Parameter:** `acpi.ec_no_wakeup=1`
* **Reason:** Prevents "phantom wakeup events" from the Embedded Controller. This fixes the common issue where the laptop immediately wakes up after being put into sleep/suspend mode.

### AMD Performance Optimization

* **Parameter:** `amd_pstate=active`
* **Reason:** Enables the modern AMD P-State "Active" mode (EPP). It allows the CPU to manage its own power states and frequencies much faster than the generic driver, resulting in better "snappiness" and improved power efficiency under load.

---

## 2. Configuration File

The changes were applied to the Omarchy-specific Limine configuration template.

**Location:** `/etc/default/limine`

### Current Config State:

```bash
TARGET_OS_NAME="Omarchy"

ESP_PATH="/boot"

KERNEL_CMDLINE[default]="cryptdevice=PARTUUID=e91846a8-7088-4151-823c-86160a3827d8:root root=/dev/mapper/root zswap.enabled=0 rootflags=subvol=@ rw rootfstype=btrfs"
# Added optimizations below:
KERNEL_CMDLINE[default]+="quiet splash acpi.ec_no_wakeup=1 amd_pstate=active"

ENABLE_UKI=yes
CUSTOM_UKI_NAME="omarchy"

ENABLE_LIMINE_FALLBACK=yes

# Find and add other bootloaders
FIND_BOOTLOADERS=yes

BOOT_ORDER="*, *fallback, Snapshots"

MAX_SNAPSHOT_ENTRIES=5

SNAPSHOT_FORMAT_CHOICE=5

```

---

## 3. Deployment Process

Since the system uses **Unified Kernel Images (UKI)**, the text configuration must be baked into the kernel binary.

1. **Edit File:** Modified `/etc/default/limine`.
2. **Rebuild Image:** Executed the initcpio generator to apply changes to the bootable EFI file:
```bash
sudo mkinitcpio -P

```


3. **Verification:** Verified the active parameters after reboot using:
```bash
cat /proc/cmdline

```



---

## 4. Hardware Verification

To ensure the AMD performance driver is working correctly, run:

* **Check Driver Status:** `cat /sys/devices/system/cpu/amd_pstate/status` (Should return `active`)
* **Check Scaling:** `cpupower frequency-info` (Should show `amd-pstate-epp`)
