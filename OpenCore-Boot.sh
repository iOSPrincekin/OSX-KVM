#!/usr/bin/env bash

# Special thanks to:
# https://github.com/Leoyzen/KVM-Opencore
# https://github.com/thenickdude/KVM-Opencore/
# https://github.com/qemu/qemu/blob/master/docs/usb2.txt
#
# qemu-img create -f qcow2 mac_hdd_ng.img 128G
#
# echo 1 > /sys/module/kvm/parameters/ignore_msrs (this is required)

############################################################################
# NOTE: Tweak the "MY_OPTIONS" line in case you are having booting problems!
############################################################################

MY_OPTIONS="+ssse3,+sse4.2,+popcnt,+avx,+aes,+xsave,+xsaveopt,check"

MAKE_DMG=$1


if [[ $MAKE_DMG == 1 ]];then
    DMG_SRC_DIR=BaseSystem
    DMG_NAME=BaseSystem1
    DMG_FILE=${DMG_NAME}.dmg
    
    echo "rm -rf ${DMG_FILE}"
    rm -rf ${DMG_FILE}
    
    echo "hdiutil create -size 2.1g -srcfolder ${DMG_SRC_DIR} -fs HFS+ -volname "BaseSystem1" -format UDRW   ${DMG_FILE}"
    hdiutil create -size 2.1g -srcfolder ${DMG_SRC_DIR} -fs HFS+ -volname "BaseSystem1" -format UDRW   ${DMG_FILE}
    
    
    echo "hdiutil detach /Volumes/${DMG_NAME}"
    hdiutil detach /Volumes/${DMG_NAME}
    
    echo "hdiutil attach ${DMG_FILE}"
    hdiutil attach ${DMG_FILE}
    
    echo "bless --folder /Volumes/${DMG_NAME}/System/Library/CoreServices --file /Volumes/${DMG_NAME}/System/Library/CoreServices/boot.efi"
    bless --folder /Volumes/${DMG_NAME}/System/Library/CoreServices --file /Volumes/${DMG_NAME}/System/Library/CoreServices/boot.efi
    
    echo "hdiutil detach /Volumes/${DMG_NAME}"
    hdiutil detach /Volumes/${DMG_NAME}
    
    echo "rm -rf BaseSystem_tmp.dmg"
    rm -rf BaseSystem_tmp.dmg
    
    echo "hdiutil convert -format UDZO ${DMG_FILE} -o BaseSystem_tmp.dmg"
    hdiutil convert -format UDZO ${DMG_FILE} -o BaseSystem_tmp.dmg
    
    echo "rm -rf ${DMG_FILE}"
    rm -rf ${DMG_FILE}
    
    echo "mv BaseSystem_tmp.dmg ${DMG_FILE}"
    mv BaseSystem_tmp.dmg ${DMG_FILE}
    
    echo "dmg2img -i ${DMG_FILE} BaseSystem.img"
    dmg2img -i ${DMG_FILE} BaseSystem.img
    
    
    qemu-system-x86_64 -accel hvf -m 4096 -cpu Penryn,kvm=on,vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on,+ssse3,+sse4.2,+popcnt,+avx,+aes,+xsave,+xsaveopt,check -machine q35 -usb -device usb-kbd -device usb-tablet -smp 4,cores=2,sockets=1 -device usb-ehci,id=ehci -device nec-usb-xhci,id=xhci -global nec-usb-xhci.msi=off -device isa-applesmc,osk='ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc' -drive if=pflash,format=raw,readonly=on,file=././OVMF_CODE.fd -smbios type=2 -device ich9-intel-hda -device hda-duplex -device ich9-ahci,id=sata -drive file=./OpenCore/OpenCore-master.iso,if=none,id=OpenCoreBoot,format=raw, -device ide-hd,bus=sata.2,drive=OpenCoreBoot -device ide-hd,bus=sata.3,drive=InstallMedia -drive id=InstallMedia,if=none,file=./BaseSystem.img,format=raw -drive id=MacHDD,if=none,file=./mac_hdd_ng.img,format=qcow2 -device ide-hd,bus=sata.4,drive=MacHDD -netdev user,id=net0 -serial stdio -device vmware-svga -debugcon file:debug.log -global isa-debugcon.iobase=0x402
    
    exit
    
elif [[ $MAKE_DMG == 2 ]];then
    DMG_SRC_DIR=/Volumes/macOS\ Base\ System/
    DMG_NAME=BaseSystem1
    DMG_FILE=${DMG_NAME}.dmg
    
    echo "rm -rf ${DMG_FILE}"
    rm -rf ${DMG_FILE}
    
    echo "hdiutil create -size 2.1g -srcfolder \"${DMG_SRC_DIR}\" -fs HFS+ -volname "BaseSystem1" -format UDRW   ${DMG_FILE}"
    hdiutil create -size 2.1g -srcfolder /Volumes/macOS\ Base\ System/ -fs HFS+ -volname "BaseSystem1" -format UDRW   ${DMG_FILE}
    
    echo "hdiutil detach /Volumes/${DMG_NAME}"
    hdiutil detach /Volumes/${DMG_NAME}
    
    echo "hdiutil attach ${DMG_FILE}"
    hdiutil attach ${DMG_FILE}
    
    echo "bless --folder /Volumes/${DMG_NAME}/System/Library/CoreServices --file /Volumes/${DMG_NAME}/System/Library/CoreServices/boot.efi"
    bless --folder /Volumes/${DMG_NAME}/System/Library/CoreServices --file /Volumes/${DMG_NAME}/System/Library/CoreServices/boot.efi
    
    echo "hdiutil detach /Volumes/${DMG_NAME}"
    hdiutil detach /Volumes/${DMG_NAME}
    exit;
    echo "rm -rf BaseSystem_tmp.dmg"
    rm -rf BaseSystem_tmp.dmg
    
    echo "hdiutil convert -format UDZO ${DMG_FILE} -o BaseSystem_tmp.dmg"
    hdiutil convert -format UDZO ${DMG_FILE} -o BaseSystem_tmp.dmg
    
    echo "rm -rf ${DMG_FILE}"
    rm -rf ${DMG_FILE}
    
    echo "mv BaseSystem_tmp.dmg ${DMG_FILE}"
    mv BaseSystem_tmp.dmg ${DMG_FILE}
    
    echo "dmg2img -i ${DMG_FILE} BaseSystem.img"
    dmg2img -i ${DMG_FILE} BaseSystem.img
    
    
    qemu-system-x86_64 -accel hvf -m 4096 -cpu Penryn,kvm=on,vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on,+ssse3,+sse4.2,+popcnt,+avx,+aes,+xsave,+xsaveopt,check -machine q35 -usb -device usb-kbd -device usb-tablet -smp 4,cores=2,sockets=1 -device usb-ehci,id=ehci -device nec-usb-xhci,id=xhci -global nec-usb-xhci.msi=off -device isa-applesmc,osk='ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc' -drive if=pflash,format=raw,readonly=on,file=././OVMF_CODE.fd -smbios type=2 -device ich9-intel-hda -device hda-duplex -device ich9-ahci,id=sata -drive file=./OpenCore/OpenCore-master.iso,if=none,id=OpenCoreBoot,format=raw, -device ide-hd,bus=sata.2,drive=OpenCoreBoot -device ide-hd,bus=sata.3,drive=InstallMedia -drive id=InstallMedia,if=none,file=./BaseSystem.img,format=raw -drive id=MacHDD,if=none,file=./mac_hdd_ng.img,format=qcow2 -device ide-hd,bus=sata.4,drive=MacHDD -netdev user,id=net0 -serial stdio -device vmware-svga -debugcon file:debug.log -global isa-debugcon.iobase=0x402
    
    exit
    
elif [[ $MAKE_DMG == 3 ]];then

    DMG_NAME=BaseSystem100
    DMG_FILE=${DMG_NAME}.dmg
    MOUNT_NAME=BaseSystem1
    
    
    echo "hdiutil detach /Volumes/${MOUNT_NAME}"
    hdiutil detach /Volumes/${MOUNT_NAME}
    
    echo "rm -rf ${DMG_FILE}"
    rm -rf ${DMG_FILE}
    
    echo "cp BaseSystem3.dmg ${DMG_FILE}"
    cp BaseSystem3.dmg ${DMG_FILE}
    
    echo "hdiutil attach ${DMG_FILE}"
    hdiutil attach ${DMG_FILE}
    
    echo "bless --folder /Volumes/${MOUNT_NAME}/System/Library/CoreServices --file /Volumes/${MOUNT_NAME}/System/Library/CoreServices/boot.efi"
    bless --folder /Volumes/${MOUNT_NAME}/System/Library/CoreServices --file /Volumes/${MOUNT_NAME}/System/Library/CoreServices/boot.efi
    
    echo "hdiutil detach /Volumes/${MOUNT_NAME}"
    hdiutil detach /Volumes/${MOUNT_NAME}
    
    echo "rm -rf BaseSystem_tmp.dmg"
    rm -rf BaseSystem_tmp.dmg
    
    echo "hdiutil convert -format UDZO ${DMG_FILE} -o BaseSystem_tmp.dmg"
    hdiutil convert -format UDZO ${DMG_FILE} -o BaseSystem_tmp.dmg
    
    
    echo "mv BaseSystem_tmp.dmg ${DMG_FILE}"
    mv BaseSystem_tmp.dmg ${DMG_FILE}
    
    echo "dmg2img -i ${DMG_FILE} BaseSystem.img"
    dmg2img -i ${DMG_FILE} BaseSystem.img
    
    
    qemu-system-x86_64 -accel hvf -m 4096 -cpu Penryn,kvm=on,vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on,+ssse3,+sse4.2,+popcnt,+avx,+aes,+xsave,+xsaveopt,check -machine q35 -usb -device usb-kbd -device usb-tablet -smp 4,cores=2,sockets=1 -device usb-ehci,id=ehci -device nec-usb-xhci,id=xhci -global nec-usb-xhci.msi=off -device isa-applesmc,osk='ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc' -drive if=pflash,format=raw,readonly=on,file=././OVMF_CODE.fd -smbios type=2 -device ich9-intel-hda -device hda-duplex -device ich9-ahci,id=sata -drive file=./OpenCore/OpenCore-master.iso,if=none,id=OpenCoreBoot,format=raw, -device ide-hd,bus=sata.2,drive=OpenCoreBoot -device ide-hd,bus=sata.3,drive=InstallMedia -drive id=InstallMedia,if=none,file=./BaseSystem.img,format=raw -drive id=MacHDD,if=none,file=./mac_hdd_ng.img,format=qcow2 -device ide-hd,bus=sata.4,drive=MacHDD -netdev user,id=net0 -serial stdio -device vmware-svga -debugcon file:debug.log -global isa-debugcon.iobase=0x402
    
    exit
fi

# This script works for Big Sur, Catalina, Mojave, and High Sierra. Tested with
# macOS 10.15.6, macOS 10.14.6, and macOS 10.13.6.

ALLOCATED_RAM="4096" # MiB
CPU_SOCKETS="1"
CPU_CORES="2"
CPU_THREADS="4"

REPO_PATH="."
OVMF_DIR="."

# shellcheck disable=SC2054
QEMU_ARGS="-s -S -m $ALLOCATED_RAM -cpu Penryn,kvm=on,vendor=GenuineIntel,+invtsc,vmware-cpuid-freq=on,$MY_OPTIONS -machine q35 -usb -device usb-kbd -device usb-tablet -smp $CPU_THREADS,cores=$CPU_CORES,sockets=$CPU_SOCKETS -device usb-ehci,id=ehci -device nec-usb-xhci,id=xhci -global nec-usb-xhci.msi=off -device isa-applesmc,osk='ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc' -drive if=pflash,format=raw,readonly=on,file=$REPO_PATH/$OVMF_DIR/OVMF_CODE.fd -smbios type=2 -device ich9-intel-hda -device hda-duplex -device ich9-ahci,id=sata -drive file=$REPO_PATH/OpenCore/OpenCore-master.iso,if=none,id=OpenCoreBoot,format=raw, -device ide-hd,bus=sata.2,drive=OpenCoreBoot -device ide-hd,bus=sata.3,drive=InstallMedia -drive id=InstallMedia,if=none,file=$REPO_PATH/BaseSystem.img,format=raw -drive id=MacHDD,if=none,file=$REPO_PATH/mac_hdd_ng.img,format=qcow2 -device ide-hd,bus=sata.4,drive=MacHDD -netdev user,id=net0,hostfwd=tcp::2222-:22 -serial stdio -device vmware-svga -debugcon file:debug.log -global isa-debugcon.iobase=0x402"

echo "qemu-system-x86_64 ${QEMU_ARGS}"

# 路径
BASEDIR=$(dirname "$0")
cd ${BASEDIR}
BASEDIR=`pwd`

ROOT_DIR=${BASEDIR}/

KVM_Opencore_Dir=/Users/lee/Desktop/Computer_Systems/UEFI/KVM-Opencore/

KVM_Opencore_EFI_Dir=${KVM_Opencore_Dir}/EFI/

KVM_Opencore_BOOT_Dir=${KVM_Opencore_EFI_Dir}/BOOT/

KVM_Opencore_OC_Dir=${KVM_Opencore_EFI_Dir}/OC/

BOOTx64_efi=${KVM_Opencore_BOOT_Dir}/BOOTx64.efi

OpenCore_efi=${KVM_Opencore_OC_Dir}/OpenCore.efi

Build_dir=/Users/lee/Desktop/Computer_Systems/UEFI/KVM-Opencore/src/OpenCorePkg/UDK/Build/

SecMain_dll=${Build_dir}/OvmfX64/DEBUG_XCODE5/X64/OvmfPkg/Sec/SecMain/DEBUG/SecMain.dll
## 二次加载地址为 0x0007FECA000
PeiCore_dll=${Build_dir}/OvmfX64/DEBUG_XCODE5/X64/MdeModulePkg/Core/Pei/PeiMain/DEBUG/PeiCore.dll

PcdPeim_dll=${Build_dir}/OvmfX64/DEBUG_XCODE5/X64/MdeModulePkg/Universal/PCD/Pei/Pcd/DEBUG/PcdPeim.dll

ReportStatusCodeRouterPei_dll=${Build_dir}/OvmfX64/DEBUG_XCODE5/X64/MdeModulePkg/Universal/ReportStatusCodeRouter/Pei/ReportStatusCodeRouterPei/DEBUG/ReportStatusCodeRouterPei.dll

StatusCodeHandlerPei_dll=${Build_dir}/OvmfX64/DEBUG_XCODE5/X64/MdeModulePkg/Universal/StatusCodeHandler/Pei/StatusCodeHandlerPei/DEBUG/StatusCodeHandlerPei.dll

PlatformPei_dll=${Build_dir}/OvmfX64/DEBUG_XCODE5/X64/OvmfPkg/PlatformPei/PlatformPei/DEBUG/PlatformPei.dll

DxeIpl_dll=${Build_dir}/OvmfX64/DEBUG_XCODE5/X64/MdeModulePkg/Core/DxeIplPeim/DxeIpl/DEBUG/DxeIpl.dll

S3Resume2Pei_dll=${Build_dir}/OvmfX64/DEBUG_XCODE5/X64/UefiCpuPkg/Universal/Acpi/S3Resume2Pei/S3Resume2Pei/DEBUG/S3Resume2Pei.dll

CpuMpPei_dll=${Build_dir}/OvmfX64/DEBUG_XCODE5/X64/UefiCpuPkg/CpuMpPei/CpuMpPei/DEBUG/CpuMpPei.dll

DxeCore_dll=${Build_dir}/OvmfX64/DEBUG_XCODE5/X64/MdeModulePkg/Core/Dxe/DxeMain/DEBUG/DxeCore.dll

Bootstrap_dll=${Build_dir}/OpenCorePkg/DEBUG_XCODE5/X64/OpenCorePkg/Application/Bootstrap/Bootstrap/DEBUG/Bootstrap.dll

BdsDxe_dll=${Build_dir}/OvmfX64/DEBUG_XCODE5/X64/MdeModulePkg/Universal/BdsDxe/BdsDxe/DEBUG/BdsDxe.dll

QemuVideoDxe_dll=${Build_dir}/OvmfX64/DEBUG_XCODE5/X64/OvmfPkg/QemuVideoDxe/QemuVideoDxe/DEBUG/QemuVideoDxe.dll

osascript -e "tell application \"Terminal\" to quit"
osascript -e "tell application \"Terminal\" to do script \"cd ${ROOT_DIR}\\n lldb ${Bootstrap_dll} \\n\
  target modules add ${SecMain_dll} \\n target modules load --file ${SecMain_dll} --slide 0x00fffc7000 \\n\
  target modules add ${PeiCore_dll} \\n target modules load --file ${PeiCore_dll} --slide 0x0000821000 \\n\
  target modules add ${PcdPeim_dll} \\n target modules load --file ${PcdPeim_dll} --slide 0x0000833000 \\n\
  target modules add ${ReportStatusCodeRouterPei_dll} \\n target modules load --file ${ReportStatusCodeRouterPei_dll} --slide 0x000083b000 \\n\
  target modules add ${StatusCodeHandlerPei_dll} \\n target modules load --file ${StatusCodeHandlerPei_dll} --slide 0x0000841000 \\n\
  target modules add ${PlatformPei_dll} \\n target modules load --file ${PlatformPei_dll} --slide 0x0000847000 \\n\
  target modules add ${DxeIpl_dll} \\n target modules load --file ${DxeIpl_dll} --slide 0x0007FEBC000 \\n\
  target modules add ${S3Resume2Pei_dll} \\n target modules load --file ${S3Resume2Pei_dll} --slide 0x0000860000 \\n\
  target modules add ${CpuMpPei_dll} \\n target modules load --file ${CpuMpPei_dll} --slide 0x0000869000 \\n\
  target modules add ${DxeCore_dll} \\n target modules load --file ${DxeCore_dll} --slide 0x0007FE3C000 \\n\
  target modules add ${Bootstrap_dll} \\n\
  target modules add ${BdsDxe_dll} \\n target modules load --file ${BdsDxe_dll} --slide 0x0007EE1D000 \\n\
  target modules add ${QemuVideoDxe_dll} \\n target modules load --file ${QemuVideoDxe_dll} --slide 0x0007EC08000 \\n\
  target modules add ${OpenCore_dll} \\n\
  b _ModuleEntryPoint \\n gdb-remote localhost:1234 \\n \"" \
-e "tell application \"Terminal\" to activate" \
-e "tell application \"System Events\" to tell process \"Terminal\" to keystroke \"t\" using command down" \
-e "tell application \"Terminal\" to set background color of window 1 to {0,0,0,1}" \
-e "tell application \"Terminal\" to do script \"cd ${ROOT_DIR} \\n sleep 0.3\\n qemu-system-x86_64 ${QEMU_ARGS} \\n \\n \" in window 1"

