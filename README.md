### Note

This `README.md` documents the process of creating a `Virtual Hackintosh`
system.

Note: All blobs and resources included in this repository are re-derivable (all
instructions are included!).

:green_heart: Looking for **commercial** support with this stuff? I am [available
over email](mailto:dhiru.kholia@gmail.com?subject=[GitHub]%20OSX-KVM%20Commercial%20Support%20Request&body=Hi%20-%20We%20are%20interested%20in%20purchasing%20commercial%20support%20options%20for%20your%20project.) for a chat for **commercial support options only**. Note: Project sponsors get access to the `Private OSX-KVM` repository, and direct support.

Struggling with `Content Caching` stuff? We can help.

Working with `Proxmox` and macOS? See [Nick's blog for sure](https://www.nicksherlock.com/).

Yes, we support offline macOS installations now - see [this document](./run_offline.md) 🎉


### Contributing Back

This project can always use your help, time and attention. I am looking for
help (pull-requests!) with the following work items:

* Documentation around running macOS on popular cloud providers (Hetzner, GCP,
  AWS). See the `Is This Legal?` section and associated references.

* Document (share) how you use this project to build + test open-source
  projects / get your stuff done.

* Document how to use this project for XNU kernel debugging and development.

* Document the process to launch a bunch of headless macOS VMs (build farm).

* Document usage of [munki](https://github.com/munki/munki) to deploy software
  to such a `build farm`.

* Enable VNC + SSH support out of the box or more easily.

* Robustness improvements are always welcome!

* (Not so) crazy idea - automate the macOS installation via OpenCV.


### Requirements

* A modern Linux distribution. E.g. Ubuntu 22.04 LTS 64-bit or later.

* QEMU >= 6.2.0

* A CPU with Intel VT-x / AMD SVM support is required (`grep -e vmx -e svm /proc/cpuinfo`)

* A CPU with SSE4.1 support is required for >= macOS Sierra

* A CPU with AVX2 support is required for >= macOS Mojave

Note: Older AMD CPU(s) are known to be problematic but modern AMD Ryzen
processors work just fine.


### Installation Preparation

* Install QEMU and other packages.

  ```
  sudo apt-get install qemu uml-utilities virt-manager git \
      wget libguestfs-tools p7zip-full make dmg2img tesseract-ocr \
      tesseract-ocr-eng genisoimage -y
  ```

  This step may need to be adapted for your Linux distribution.

* Clone this repository on your QEMU system. Files from this repository are
  used in the following steps.

  ```
  cd ~

  git clone --depth 1 --recursive https://github.com/kholia/OSX-KVM.git

  cd OSX-KVM
  ```

  Repository updates can be pulled via the following command:

  ```
  git pull --rebase
  ```

  This repository uses rebase based workflows heavily.

* KVM may need the following tweak on the host machine to work.

  ```
  sudo modprobe kvm; echo 1 | sudo tee /sys/module/kvm/parameters/ignore_msrs
  ```

  To make this change permanent, you may use the following command.

  ```
  sudo cp kvm.conf /etc/modprobe.d/kvm.conf  # for intel boxes only

  sudo cp kvm_amd.conf /etc/modprobe.d/kvm.conf  # for amd boxes only
  ```

* Add user to the `kvm` and `libvirt` groups (might be needed).

  ```
  sudo usermod -aG kvm $(whoami)
  sudo usermod -aG libvirt $(whoami)
  sudo usermod -aG input $(whoami)
  ```

  Note: Re-login after executing this command.

* Fetch macOS installer.

  ```
  ./fetch-macOS-v2.py
  ```

  You can choose your desired macOS version here. After executing this step,
  you should have the `BaseSystem.dmg` file in the current folder.

  ATTENTION: Let `>= Big Sur` setup sit at the `Country Selection` screen, and
  other similar places for a while if things are being slow. The initial macOS
  setup wizard will eventually succeed.

  Sample run:

  ```
  $ ./fetch-macOS-v2.py
  1. High Sierra (10.13)
  2. Mojave (10.14)
  3. Catalina (10.15)
  4. Big Sur (11.7)
  5. Monterey (12.6)
  6. Ventura (13) - RECOMMENDED
  7. Sonoma (14)

  Choose a product to download (1-6): 6
  ```

  Note: Modern NVIDIA GPUs are supported on HighSierra but not on later
  versions of macOS.

* Convert the downloaded `BaseSystem.dmg` file into the `BaseSystem.img` file.

  ```
  dmg2img -i BaseSystem.dmg BaseSystem.img
  ```

* Create a virtual HDD image where macOS will be installed. If you change the
  name of the disk image from `mac_hdd_ng.img` to something else, the boot scripts
  will need to be updated to point to the new image name.

  ```
  qemu-img create -f qcow2 mac_hdd_ng.img 256G
  ```

  NOTE: Create this HDD image file on a fast SSD/NVMe disk for best results.

* Now you are ready to install macOS 🚀


### Installation

- CLI method (primary). Just run the `OpenCore-Boot.sh` script to start the
  installation process.

  ```
  ./OpenCore-Boot.sh
  ```

  Note: This same script works for all recent macOS versions.

- Use the `Disk Utility` tool within the macOS installer to partition, and
  format the virtual disk attached to the macOS VM.

- Go ahead, and install macOS 🙌

- TIP: Using a non-APFS filesystem is recommended.

- (OPTIONAL) Use this macOS VM disk with libvirt (virt-manager / virsh stuff).

  - Edit `macOS-libvirt-Catalina.xml` file and change the various file paths (search
    for `CHANGEME` strings in that file). The following command should do the
    trick usually.

    ```
    sed "s/CHANGEME/$USER/g" macOS-libvirt-Catalina.xml > macOS.xml

    virt-xml-validate macOS.xml
    ```

  - Create a VM by running the following command.

    ```bash
    virsh --connect qemu:///system define macOS.xml
    ```

  - If needed, grant necessary permissions to libvirt-qemu user,

    ```
    sudo setfacl -m u:libvirt-qemu:rx /home/$USER
    sudo setfacl -R -m u:libvirt-qemu:rx /home/$USER/OSX-KVM
    ```

  - Launch `virt-manager` and start the `macOS` virtual machine.


### Headless macOS

- Use the provided [boot-macOS-headless.sh](./boot-macOS-headless.sh) script.

  ```
  ./boot-macOS-headless.sh
  ```


### Setting Expectations Right

Nice job on setting up a `Virtual Hackintosh` system! Such a system can be used
for a variety of purposes (e.g. software builds, testing, reversing work), and
it may be all you need, along with some tweaks documented in this repository.

However, such a system lacks graphical acceleration, a reliable sound sub-system,
USB 3 functionality and other similar things. To enable these things, take a
look at our [notes](notes.md). We would like to resume our testing and
documentation work around this area. Please [reach out to us](mailto:dhiru.kholia@gmail.com?subject=[GitHub]%20OSX-KVM%20Funding%20Support)
if you are able to fund this area of work.

It is possible to have 'beyond-native-apple-hw' performance but it does require
work, patience, and a bit of luck (perhaps?).


### Post-Installation

* See [networking notes](networking-qemu-kvm-howto.txt) on how to setup networking in your VM, outbound and also inbound for remote access to your VM via SSH, VNC, etc.

* To passthrough GPUs and other devices, see [these notes](notes.md#gpu-passthrough-notes).

* Need a different resolution? Check out the [notes](notes.md#change-resolution-in-opencore) included in this repository.

* Trouble with iMessage? Check out the [notes](notes.md#trouble-with-imessage) included in this repository.

* Highly recommended macOS tweaks - https://github.com/sickcodes/osx-optimizer


### Is This Legal?

The "secret" Apple OSK string is widely available on the Internet. It is also included in a public court document [available here](http://www.rcfp.org/sites/default/files/docs/20120105_202426_apple_sealing.pdf). I am not a lawyer but it seems that Apple's attempt(s) to get the OSK string treated as a trade secret did not work out. Due to these reasons, the OSK string is freely included in this repository.

Please review the ['Legality of Hackintoshing' documentation bits from Dortania's OpenCore Install Guide](https://dortania.github.io/OpenCore-Install-Guide/why-oc.html#legality-of-hackintoshing).

Gabriel Somlo also has [some thoughts](http://www.contrib.andrew.cmu.edu/~somlo/OSXKVM/) on the legal aspects involved in running macOS under QEMU/KVM.

You may also find [this 'Announcing Amazon EC2 Mac instances for macOS' article](https://aws.amazon.com/about-aws/whats-new/2020/11/announcing-amazon-ec2-mac-instances-for-macos/
) interesting.

Note: It is your responsibility to understand, and accept (or not accept) the
Apple EULA.

Note: This is not legal advice, so please make the proper assessments yourself
and discuss with your lawyers if you have any concerns (Text credit: Dortania)


### Motivation

My aim is to enable macOS based educational tasks, builds + testing, kernel
debugging, reversing, and macOS security research in an easy, reproducible
manner without getting 'invested' in Apple's closed ecosystem (too heavily).

These `Virtual Hackintosh` systems are not intended to replace the genuine
physical macOS systems.

Personally speaking, this repository has been a way for me to 'exit' the Apple
ecosystem. It has helped me to test and compare the interoperability of `Canon
CanoScan LiDE 120` scanner, and `Brother HL-2250DN` laser printer. And these
devices now work decently enough on modern versions of Ubuntu (Yay for free
software). Also, a long time back, I had to completely wipe my (then) brand new
`MacBook Pro (Retina, 15-inch, Late 2013)` and install Xubuntu on it - as the
`OS X` kernel kept crashing on it!

Backstory: I was a (poor) student in Canada in a previous life and Apple made [my work on cracking Apple Keychains](https://github.com/openwall/john/blob/bleeding-jumbo/src/keychain_fmt_plug.c) a lot harder than it needed to be. This is how I got interested in Hackintosh systems.



# 自定义开发

## 1.生成自己的固件文件夹 BaseSystem


1.使用 fetch-macOS-v2.py -v 下载 dmg
fetch-macOS-v2.py -v


2.将 /Volumes/macOS Base System 内容复制到 BaseSystem 文件夹


hdiutil attach BaseSystem.dmg

cd /Volumes/

sudo cp -aRLH macOS\ Base\ System /Users/lee/Desktop/Computer_Systems/Macos/OSX-KVM

cd /Users/lee/Desktop/Computer_Systems/Macos/OSX-KVM

sudo rm -rf BaseSystem

sudo mv macOS\ Base\ System BaseSystem


## 2.使用 ./OpenCore-Boot.sh 1 命令 将 BaseSystem 文件夹内容生成 dmg


./OpenCore-Boot.sh 1


the command logs:



rm -rf BaseSystem1.dmg
hdiutil create -size 2.1g -srcfolder BaseSystem -fs HFS+ -volname BaseSystem1 -format UDRW   BaseSystem1.dmg
/Users/lee/Desktop/Computer_Systems/Macos/OSX-KVM/BaseSystem: Authentication error
..............................................................
created: /Users/lee/Desktop/Computer_Systems/Macos/OSX-KVM/BaseSystem1.dmg
hdiutil detach /Volumes/BaseSystem1
hdiutil: detach failed - No such file or directory
hdiutil attach BaseSystem1.dmg
/dev/disk4          	GUID_partition_scheme
/dev/disk4s1        	EFI
/dev/disk4s2        	Apple_HFS                      	/Volumes/BaseSystem1
bless --folder /Volumes/BaseSystem1/System/Library/CoreServices --file /Volumes/BaseSystem1/System/Library/CoreServices/boot.efi
hdiutil detach /Volumes/BaseSystem1
"disk4" ejected.
rm -rf BaseSystem_tmp.dmg
hdiutil convert -format UDZO BaseSystem1.dmg -o BaseSystem_tmp.dmg
Preparing imaging engine…
Reading Protective Master Boot Record (MBR : 0)…
   (CRC32 $58370188: Protective Master Boot Record (MBR : 0))
Reading GPT Header (Primary GPT Header : 1)…
   (CRC32 $02D26567: GPT Header (Primary GPT Header : 1))
Reading GPT Partition Data (Primary GPT Table : 2)…
   (CRC32 $0AD3C4C4: GPT Partition Data (Primary GPT Table : 2))
Reading  (Apple_Free : 3)…
   (CRC32 $00000000:  (Apple_Free : 3))
Reading EFI System Partition (C12A7328-F81F-11D2-BA4B-00A0C93EC93B : 4)…
......
   (CRC32 $B54B659C: EFI System Partition (C12A7328-F81F-11D2-BA4B-00A0C93EC93B : 4))
Reading disk image (Apple_HFS : 5)…
.............................................................
   (CRC32 $160A8AD4: disk image (Apple_HFS : 5))
Reading  (Apple_Free : 6)…
.................................................................
   (CRC32 $00000000:  (Apple_Free : 6))
Reading GPT Partition Data (Backup GPT Table : 7)…
.................................................................
   (CRC32 $0AD3C4C4: GPT Partition Data (Backup GPT Table : 7))
Reading GPT Header (Backup GPT Header : 8)…
.................................................................
   (CRC32 $2241E421: GPT Header (Backup GPT Header : 8))
Adding resources…
.................................................................
Elapsed Time: 31.848s
File size: 718319927 bytes, Checksum: CRC32 $059DAA0F
Sectors processed: 4404019, 3946156 compressed
Speed: 60.5MB/s
Savings: 68.1%
created: /Users/lee/Desktop/Computer_Systems/Macos/OSX-KVM/BaseSystem_tmp.dmg
rm -rf BaseSystem1.dmg
mv BaseSystem_tmp.dmg BaseSystem1.dmg
dmg2img -i BaseSystem1.dmg BaseSystem.img

dmg2img v1.6.7 (c) vu1tur (to@vu1tur.eu.org)

BaseSystem1.dmg --> BaseSystem.img


decompressing:
opening partition 0 ...             100.00%  ok
opening partition 1 ...             100.00%  ok
opening partition 2 ...             100.00%  ok
opening partition 3 ...             100.00%  ok
opening partition 4 ...             100.00%  ok
opening partition 5 ...             100.00%  ok
opening partition 6 ...             100.00%  ok
opening partition 7 ...             100.00%  ok
opening partition 8 ...             100.00%  ok

Archive successfully decompressed as BaseSystem.img
qemu-system-x86_64: warning: host doesn't support requested feature: CPUID.80000007H:EDX.invtsc [bit 8]
qemu-system-x86_64: warning: host doesn't support requested feature: CPUID.80000007H:EDX.invtsc [bit 8]
qemu-system-x86_64: warning: host doesn't support requested feature: CPUID.80000007H:EDX.invtsc [bit 8]
qemu-system-x86_64: warning: host doesn't support requested feature: CPUID.80000007H:EDX.invtsc [bit 8]
audio: Could not create a backend for voice `adc'
qemu-system-x86_64: warning: netdev net0 has no peer
BdsDxe: loading Boot0001 "UEFI QEMU HARDDISK QM00017 " from PciRoot(0x0)/Pci(0x4,0x0)/Sata(0x2,0xFFFF,0x0)
BdsDxe: starting Boot0001 "UEFI QEMU HARDDISK QM00017 " from PciRoot(0x0)/Pci(0x4,0x0)/Sata(0x2,0xFFFF,0x0)
BS: Starting OpenCore application...
BS: Booter path - \EFI\BOOT\BOOTX64.EFI
OCFS: Trying to locate filesystem on 7E3C8E98 7E763C98
OCFS: Filesystem DP - \EFI\BOOT\BOOTX64.EFI
BS: Trying to load OpenCore image...
BS: Relative path - EFI
BS: Startup path - EFI\OpenCore.efi (0)
BS: Fallback to absolute path - EFI\OC\OpenCore.efi
BS: Read OpenCore image of 839680 bytes
OCM: Loaded image at 7D838E98 handle
OCM: Loaded image has DeviceHandle 7E3C8E98 FilePath 7D838F18 ours DevicePath 7D839618
OC: Starting OpenCore...
OC: Booter path - EFI\OC\OpenCore.efi
OCFS: Trying to locate filesystem on 7E3C8E98 7D838F18
OCFS: Filesystem DP - EFI\OC\OpenCore.efi
OC: Absolute booter path - EFI\OC\OpenCore.efi
OC: Storage root EFI\OC\OpenCore.efi
OCST: Missing vault data, ignoring...
OC: OcMiscEarlyInit...
OC: Loaded configuration of 43485 bytes
OC: Got 32 drivers
OC: Watchdog status is 1
#[EB|LOG:EXITBS:END] _
#[EB.BST.FBS|-]
#[EB|B:BOOT]
#[EB|LOG:HANDOFF TO XNU] _
======== End of efiboot serial output. ========


## 3. 通过 gAppleBootPolicyPredefinedPaths 添加 #define APPLE_BOOTER_DEFAULT_FILE_NAME  L"\\System\\Library\\CoreServices\\boot.efi" 作为启动项

```
    //
    // No entries, or only entry pre-created from boot entry protocol,
    // so process this directory with Apple Bless.
    //
    if (IsDefaultEntryProtocolPartition || IsListEmpty (&FileSystem->BootEntries)) {
      AddBootEntryFromBless (
        BootContext,
        FileSystem,
        gAppleBootPolicyPredefinedPaths,
        gAppleBootPolicyNumPredefinedPaths,
        FALSE,
        FALSE
        );
    }
```




## 4.查看硬盘信息

```
 hdiutil imageinfo BaseSystem.dmg
```

```
diskutil info /Volumes/BaseSystem1/
```

```
 dmg2img -l -v /Users/lee/Desktop/Computer_Systems/Macos/OSX-KVM/BaseSystem.dmg
```


## 5.使用LLDB  分析 OVMF_CODE.fd 在qemu中运行的第一行代码

```
003ffff0  0f 20 c0 a8 01 74 05 e9  2c ff ff ff e9 11 ff 90  |. ...t..,.......|
```
对应源码是

/Users/lee/Desktop/Computer_Systems/UEFI/KVM-Opencore/src/OpenCorePkg/UDK/OvmfPkg/ResetVector/Ia16/ResetVectorVtf0.asm

```

%ifdef ARCH_IA32
    nop
    nop
    jmp     EarlyBspInitReal16

%else

    mov     eax, cr0
    test    al, 1
    jz      .Real
BITS 32
    jmp     Main32
BITS 16
.Real:
    jmp     EarlyBspInitReal16

%endif


```

启动流程1： 0xfffffff0 -> EarlyBspInitReal16 -> Main16-> EarlyInit16、TransitionFromReal16To32BitFlat -> jumpTo32BitAndLandHere-> 
    mov     eax, SEC_DEFAULT_CR4
    mov     cr4, eax

启动流程2： 0xfffffff0 -> Main32 -> InitTdx-> ReloadFlat32


### 1.从 0xfffffffc 跳转到 0xffffff10


```

(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x000000000000fffc
->  0xfffc: addb   %al, (%rax)
    0xfffe: addb   %al, (%rax)
    0x10000: addb   %al, (%rax)
    0x10002: addb   %al, (%rax)
Target 0: (Bootstrap.dll) stopped.
(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x000000000000ff10
->  0xff10: addb   %al, (%rax)
    0xff12: addb   %al, (%rax)
    0xff14: addb   %al, (%rax)
    0xff16: addb   %al, (%rax)
Target 0: (Bootstrap.dll) stopped.
(lldb)  

```

对应地址hex
```
003fff10  bf 42 50 eb 05 66 89 c4  eb 02 eb f9 e9 71 ff c6  |.BP..f.......q..|

```

源代码是

```

BITS    16

;
; @param[out] DI    'BP' to indicate boot-strap processor
;
EarlyBspInitReal16:
    mov     di, 'BP'
    jmp     short Main16

```
### 2.从 0xffffff13 跳转到 0xffffff1a
```

(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x000000000000ff13
->  0xff13: addb   %al, (%rax)
    0xff15: addb   %al, (%rax)
    0xff17: addb   %al, (%rax)
    0xff19: addb   %al, (%rax)
Target 0: (Bootstrap.dll) stopped.
(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x000000000000ff1a
->  0xff1a: addb   %al, (%rax)
    0xff1c: addb   %al, (%rax)
    0xff1e: addb   %al, (%rax)
    0xff20: addb   %al, (%rax)
Target 0: (Bootstrap.dll) stopped.
(lldb)  
```

对应地址hex

```

003fff10  bf 42 50 eb 05 66 89 c4  eb 02 eb f9 e9 71 ff c6  |.BP..f.......q..|

```

汇编是

16 位

```
0xffffff10:  BF 42 50    mov di, 0x5042
0xffffff13:  EB 05       jmp 0xa
0xffffff15:  66 89 C4    mov esp, eax
0xffffff18:  EB 02       jmp 0xc
0xffffff1a:  EB F9       jmp 5
0xffffff1c:  E9 71 FF    jmp 0xff80

```

对应源码是

```

EarlyBspInitReal16:
    mov     di, 'BP'
    jmp     short Main16

```

### 3.从 0xffffff1a 到 0xffffff15
```

(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x000000000000ff1a
->  0xff1a: addb   %al, (%rax)
    0xff1c: addb   %al, (%rax)
    0xff1e: addb   %al, (%rax)
    0xff20: addb   %al, (%rax)
Target 0: (Bootstrap.dll) stopped.
(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x000000000000ff15
->  0xff15: addb   %al, (%rax)
    0xff17: addb   %al, (%rax)
    0xff19: addb   %al, (%rax)
    0xff1b: addb   %al, (%rax)
Target 0: (Bootstrap.dll) stopped.

```


对应地址hex

```

003fff10  bf 42 50 eb 05 66 89 c4  eb 02 eb f9 e9 71 ff c6  |.BP..f.......q..|

```

汇编是

16 位

```
0xffffff10:  BF 42 50    mov di, 0x5042
0xffffff13:  EB 05       jmp 0xa
0xffffff15:  66 89 C4    mov esp, eax
0xffffff18:  EB 02       jmp 0xc
0xffffff1a:  EB F9       jmp 5
0xffffff1c:  E9 71 FF    jmp 0xff80

```

对应源码是

```
Main16:
    OneTimeCall EarlyInit16

```


```
;
; Modified:  EAX
;
; @param[in]  EAX   Initial value of the EAX register (BIST: Built-in Self Test)
; @param[out] ESP   Initial value of the EAX register (BIST: Built-in Self Test)
;
EarlyInit16:
    ;
    ; ESP -  Initial value of the EAX register (BIST: Built-in Self Test)
    ;
    mov     esp, eax

    debugInitialize

    OneTimeCallRet EarlyInit16

```

### 4.从 0xffffff18 到 0xffffff1c
```

(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x000000000000ff18
->  0xff18: addb   %al, (%rax)
    0xff1a: addb   %al, (%rax)
    0xff1c: addb   %al, (%rax)
    0xff1e: addb   %al, (%rax)
Target 0: (Bootstrap.dll) stopped.
(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x000000000000ff1c
->  0xff1c: addb   %al, (%rax)
    0xff1e: addb   %al, (%rax)
    0xff20: addb   %al, (%rax)
    0xff22: addb   %al, (%rax)
Target 0: (Bootstrap.dll) stopped.
(lldb) 

```

对应地址hex

```

003fff10  bf 42 50 eb 05 66 89 c4  eb 02 eb f9 e9 71 ff c6  |.BP..f.......q..|

```

汇编是

16 位

```
0xffffff10:  BF 42 50    mov di, 0x5042
0xffffff13:  EB 05       jmp 0xa
0xffffff15:  66 89 C4    mov esp, eax
0xffffff18:  EB 02       jmp 0xc
0xffffff1a:  EB F9       jmp 5
0xffffff1c:  E9 71 FF    jmp 0xff80

```

对应源码是

```
    OneTimeCallRet EarlyInit16

```

```
Main16:
    OneTimeCall EarlyInit16

    ;
    ; Transition the processor from 16-bit real mode to 32-bit flat mode
    ;
    OneTimeCall TransitionFromReal16To32BitFlat

```

### 5.从 0xffffff1c 到 0xfffffe90
```
(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x000000000000ff1c
->  0xff1c: addb   %al, (%rax)
    0xff1e: addb   %al, (%rax)
    0xff20: addb   %al, (%rax)
    0xff22: addb   %al, (%rax)
Target 0: (Bootstrap.dll) stopped.
(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x000000000000fe90
->  0xfe90: addb   %al, (%rax)
    0xfe92: addb   %al, (%rax)
    0xfe94: addb   %al, (%rax)
    0xfe96: addb   %al, (%rax)
Target 0: (Bootstrap.dll) stopped.

```


对应地址hex

```

003fff10  bf 42 50 eb 05 66 89 c4  eb 02 eb f9 e9 71 ff c6  |.BP..f.......q..|

```

汇编是

16 位

```
0xffffff10:  BF 42 50    mov di, 0x5042
0xffffff13:  EB 05       jmp 0xa
0xffffff15:  66 89 C4    mov esp, eax
0xffffff18:  EB 02       jmp 0xc
0xffffff1a:  EB F9       jmp 5
0xffffff1c:  E9 71 FF    jmp 0xff80

```

对应源码是

```
    OneTimeCall TransitionFromReal16To32BitFlat
```


```

TransitionFromReal16To32BitFlat:

    debugShowPostCode POSTCODE_16BIT_MODE

    cli

    mov     bx, 0xf000
    mov     ds, bx

    mov     bx, ADDR16_OF(gdtr)

o32 lgdt    [cs:bx]

    mov     eax, SEC_DEFAULT_CR0
    mov     cr0, eax

    jmp     LINEAR_CODE_SEL:dword ADDR_OF(jumpTo32BitAndLandHere)
BITS    32
jumpTo32BitAndLandHere:

```

### 6.从 0xfffffea7 跳到 0xfffffeaf
```
(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x000000000000fea7
->  0xfea7: addb   %al, (%rax)
    0xfea9: addb   %al, (%rax)
    0xfeab: addb   %al, (%rax)
    0xfead: addb   %al, (%rax)
Target 0: (Bootstrap.dll) stopped.
(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffffeaf
->  0xfffffeaf: movl   $0x640, %eax              ; imm = 0x640 
    0xfffffeb4: movq   %rax, %cr4
    0xfffffeb7: movw   $0x18, %ax
    0xfffffebb: movl   %eax, %ds
Target 0: (Bootstrap.dll) stopped.
(lldb)  

```


对应地址hex

16位
```

003ffea0  23 00 00 00 0f 22 c0 66  ea af fe ff ff 10 00 b8  |#....".f........|

```

32位
```
003ffea0  --------------------------------------------- b8  |#....".f........|

003ffeb0  40 06 00 00 0f 22 e0 66  b8 18 00 8e d8 8e c0 8e  |@....".f........|

```
汇编是

16 位
```
0x0000000000000000:  23 00                      and  ax, word ptr [bx + si]
0x0000000000000002:  00 00                      add  byte ptr [bx + si], al
0x0000000000000004:  0F 22 C0                   mov  cr0, eax
0x0000000000000007:  66 EA AF FE FF FF 10 00    ljmp 0x10:0xfffffeaf

```

32 位

```
0x0000000000000000:  B8 40 06 00 00    mov eax, 0x640
0x0000000000000005:  0F 22 E0          mov cr4, eax
0x0000000000000008:  66 B8 18 00       mov ax, 0x18
0x000000000000000c:  8E D8             mov ds, eax
0x000000000000000e:  8E C0             mov es, eax
```

对应源码是

```
    jmp     LINEAR_CODE_SEL:dword ADDR_OF(jumpTo32BitAndLandHere)

```

```
BITS    32
jumpTo32BitAndLandHere:

    mov     eax, SEC_DEFAULT_CR4
    mov     cr4, eax

    debugShowPostCode POSTCODE_32BIT_MODE

    mov     ax, LINEAR_SEL
    mov     ds, ax
    mov     es, ax
    mov     fs, ax
    mov     gs, ax
    mov     ss, ax

    OneTimeCallRet TransitionFromReal16To32BitFlat


```

### 7.从 0xfffffec5 跳转到 0xffffff1f

```

(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffffec5
->  0xfffffec5: jmp    0xffffff1f
    0xfffffec7: nop    
Target 0: (Bootstrap.dll) stopped.
(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000ffffff1f
->  0xffffff1f: movb   $0x0, 0x80b000(%rip)
    0xffffff26: jmp    0xffffff2d
    0xffffff28: jmp    0xfffffa64
    0xffffff2d: jmp    0xfffff4f0
Target 0: (Bootstrap.dll) stopped.

```

对应地址hex

```
003ffeb0  --------------------------------------------- 8e  |@....".f........|
003ffec0  e0 8e e8 8e d0 eb 58 90  3f 00 d0 fe ff ff 90 90  |......X.?.......|
```


```
003fff10  bf 42 50 eb 05 66 89 c4  eb 02 eb f9 e9 71 ff c6  |.BP..f.......q..|

```

汇编是

32 位
```
0xfffffebf:  8E E0    mov fs, eax
0xfffffec1:  8E E8    mov gs, eax
0xfffffec3:  8E D0    mov ss, eax
0xfffffec5:  EB 58    jmp 0x60
0xfffffec7:  90       nop 

```



16 位

```
0xffffff10:  BF 42 50    mov di, 0x5042
0xffffff13:  EB 05       jmp 0xa
0xffffff15:  66 89 C4    mov esp, eax
0xffffff18:  EB 02       jmp 0xc
0xffffff1a:  EB F9       jmp 5
0xffffff1c:  E9 71 FF    jmp 0xff80

```


源代码是

```

BITS    16

;
; @param[out] DI    'BP' to indicate boot-strap processor
;
EarlyBspInitReal16:
    mov     di, 'BP'
    jmp     short Main16

```

```

EarlyBspInitReal16:
    mov     di, 'BP'
    jmp     short Main16

```


```

BITS    16

;
; Modified:  EBX, ECX, EDX, EBP
;
; @param[in,out]  RAX/EAX  Initial value of the EAX register
;                          (BIST: Built-in Self Test)
; @param[in,out]  DI       'BP': boot-strap processor, or
;                          'AP': application processor
; @param[out]     RBP/EBP  Address of Boot Firmware Volume (BFV)
; @param[out]     DS       Selector allowing flat access to all addresses
; @param[out]     ES       Selector allowing flat access to all addresses
; @param[out]     FS       Selector allowing flat access to all addresses
; @param[out]     GS       Selector allowing flat access to all addresses
; @param[out]     SS       Selector allowing flat access to all addresses
;
; @return         None  This routine jumps to SEC and does not return
;
Main16:
    OneTimeCall EarlyInit16

    ;
    ; Transition the processor from 16-bit real mode to 32-bit flat mode
    ;
    OneTimeCall TransitionFromReal16To32BitFlat

BITS    32

    ; Clear the WorkArea header. The SEV probe routines will populate the
    ; work area when detected.
    mov     byte[WORK_AREA_GUEST_TYPE], 0

%ifdef ARCH_X64

    jmp SearchBfv

;
; Entry point of Main32
;
Main32:
    OneTimeCall InitTdx

SearchBfv:

```

### 7.从 0xffffff26 跳转到 0xffffff2d


```
(lldb) si
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000ffffff26
->  0xffffff26: jmp    0xffffff2d
    0xffffff28: jmp    0xfffffa64
    0xffffff2d: jmp    0xfffff4f0
    0xffffff32: jmp    0xfffff567
Target 0: (Bootstrap.dll) stopped.
(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000ffffff2d
->  0xffffff2d: jmp    0xfffff4f0
    0xffffff32: jmp    0xfffff567
    0xffffff37: jmp    0xfffff710
    0xffffff3c: movl   $0xffffffff, %eax         ; imm = 0xFFFFFFFF 
Target 0: (Bootstrap.dll) stopped.

```

即 jmp SearchBfv

对应源代码是

```
%ifdef ARCH_X64

    jmp SearchBfv

;
; Entry point of Main32
;
Main32:
    OneTimeCall InitTdx

SearchBfv:

%endif

    ;
    ; Search for the Boot Firmware Volume (BFV)
    ;
    OneTimeCall Flat32SearchForBfvBase

```

### 8.从0xffffff2d跳到 0xfffff4f0

```
(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000ffffff2d
->  0xffffff2d: jmp    0xfffff4f0
    0xffffff32: jmp    0xfffff567
    0xffffff37: jmp    0xfffff710
    0xffffff3c: movl   $0xffffffff, %eax         ; imm = 0xFFFFFFFF 
Target 0: (Bootstrap.dll) stopped.
(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffff4f0
->  0xfffff4f0: xorl   %eax, %eax
    0xfffff4f2: subl   $0x1000, %eax             ; imm = 0x1000 
    0xfffff4f7: cmpl   $0xff000000, %eax         ; imm = 0xFF000000 
    0xfffff4fc: jb     0xfffff557
Target 0: (Bootstrap.dll) stopped.


```

对应源代码是

```

    OneTimeCall Flat32SearchForBfvBase


```

/Users/lee/Desktop/Computer_Systems/UEFI/KVM-Opencore/src/OpenCorePkg/UDK/UefiCpuPkg/ResetVector/Vtf0/Ia32/SearchForBfvBase.asm

```

BITS    32

;
; Modified:  EAX, EBX
; Preserved: EDI, ESP
;
; @param[out]  EBP  Address of Boot Firmware Volume (BFV)
;
Flat32SearchForBfvBase:

    xor     eax, eax
searchingForBfvHeaderLoop:
    ;
    ; We check for a firmware volume at every 4KB address in the top 16MB
    ; just below 4GB.  (Addresses at 0xffHHH000 where H is any hex digit.)
    ;
    sub     eax, 0x1000
    cmp     eax, 0xff000000
    jb      searchedForBfvHeaderButNotFound

    ;
    ; Check FFS3 GUID
    ;
    cmp     dword [eax + 0x10], FFS3_GUID_DWORD0
    jne     searchingForFfs2Guid
    cmp     dword [eax + 0x14], FFS3_GUID_DWORD1
    jne     searchingForFfs2Guid
    cmp     dword [eax + 0x18], FFS3_GUID_DWORD2
    jne     searchingForFfs2Guid
    cmp     dword [eax + 0x1c], FFS3_GUID_DWORD3
    jne     searchingForFfs2Guid
    jmp     checkingFvLength

```

```
003ff500  10 7a c0 73 54 75 1d 81  78 14 cb 3d ca 4d 75 14  |.z.sTu..x..=.Mu.|
003ff510  81 78 18 bd 6f 1e 96 75  0b 81 78 1c 89 e7 34 9a  |.x..o..u..x...4.|
```

### 9. 从 0xfffff546 跳转到 0xfffff548
```

(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffff53f
->  0xfffff53f: cmpl   $0xd32dc385, 0x1c(%rax)   ; imm = 0xD32DC385 
    0xfffff546: jne    0xfffff4f2
    0xfffff548: cmpl   $0x0, 0x24(%rax)
    0xfffff54c: jne    0xfffff4f2
Target 0: (Bootstrap.dll) stopped.
(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffff546
->  0xfffff546: jne    0xfffff4f2
    0xfffff548: cmpl   $0x0, 0x24(%rax)
    0xfffff54c: jne    0xfffff4f2
    0xfffff54e: movl   %eax, %ebx
Target 0: (Bootstrap.dll) stopped.
(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffff548
->  0xfffff548: cmpl   $0x0, 0x24(%rax)
    0xfffff54c: jne    0xfffff4f2
    0xfffff54e: movl   %eax, %ebx
    0xfffff550: addl   0x20(%rax), %ebx
Target 0: (Bootstrap.dll) stopped.


```

对应源代码是  checkingFvLength:
 

```

searchingForFfs2Guid:
    ;
    ; Check FFS2 GUID
    ;
    cmp     dword [eax + 0x10], FFS2_GUID_DWORD0
    jne     searchingForBfvHeaderLoop
    cmp     dword [eax + 0x14], FFS2_GUID_DWORD1
    jne     searchingForBfvHeaderLoop
    cmp     dword [eax + 0x18], FFS2_GUID_DWORD2
    jne     searchingForBfvHeaderLoop
    cmp     dword [eax + 0x1c], FFS2_GUID_DWORD3
    jne     searchingForBfvHeaderLoop

checkingFvLength:
    ;
    ; Check FV Length
    ;
    cmp     dword [eax + 0x24], 0
    jne     searchingForBfvHeaderLoop
    mov     ebx, eax
    add     ebx, dword [eax + 0x20]
    jnz     searchingForBfvHeaderLoop

    jmp     searchedForBfvHeaderAndItWasFound


```

```
003cc000  00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00  |................|
003cc010  78 e5 8c 8c 3d 8a 1c 4f  99 35 89 61 85 c3 2d d3  |x...=..O.5.a..-.|
003cc020  00 40 03 00 00 00 00 00  5f 46 56 48 ff fe 04 00  |.@......_FVH....|
```

### 10.从0xfffff562 跳到 0xffffff32,返回到     OneTimeCall Flat32SearchForSecEntryPoint 的下一条指令

```
(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffff560
->  0xfffff560: movl   %eax, %ebp
    0xfffff562: jmp    0xffffff32
    0xfffff567: xorl   %ebx, %ebx
    0xfffff569: movl   %ebx, %esi
Target 0: (Bootstrap.dll) stopped.
(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffff562
->  0xfffff562: jmp    0xffffff32
    0xfffff567: xorl   %ebx, %ebx
    0xfffff569: movl   %ebx, %esi
    0xfffff56b: movl   %ebp, %eax
Target 0: (Bootstrap.dll) stopped.
(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000ffffff32
->  0xffffff32: jmp    0xfffff567
    0xffffff37: jmp    0xfffff710
    0xffffff3c: movl   $0xffffffff, %eax         ; imm = 0xFFFFFFFF 
    0xffffff41: andq   %rax, %rsi
Target 0: (Bootstrap.dll) stopped.
(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffff567
->  0xfffff567: xorl   %ebx, %ebx
    0xfffff569: movl   %ebx, %esi
    0xfffff56b: movl   %ebp, %eax
    0xfffff56d: movw   0x30(%rbp), %bx
Target 0: (Bootstrap.dll) stopped.

```

```
(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000ffffff2d
->  0xffffff2d: jmp    0xfffff4f0
    0xffffff32: jmp    0xfffff567
    0xffffff37: jmp    0xfffff710
    0xffffff3c: movl   $0xffffffff, %eax         ; imm = 0xFFFFFFFF 
Target 0: (Bootstrap.dll) stopped.
(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffff4f0
->  0xfffff4f0: xorl   %eax, %eax
    0xfffff4f2: subl   $0x1000, %eax             ; imm = 0x1000 
    0xfffff4f7: cmpl   $0xff000000, %eax         ; imm = 0xFF000000 
    0xfffff4fc: jb     0xfffff557
Target 0: (Bootstrap.dll) stopped.


```

对应源代码是

```

    OneTimeCall Flat32SearchForBfvBase


```

```

BITS    32

%define EFI_FV_FILETYPE_SECURITY_CORE         0x03

;
; Modified:  EAX, EBX, ECX, EDX
; Preserved: EDI, EBP, ESP
;
; @param[in]   EBP  Address of Boot Firmware Volume (BFV)
; @param[out]  ESI  SEC Core Entry Point Address
;
Flat32SearchForSecEntryPoint:

    ;
    ; Initialize EBP and ESI to 0
    ;
    xor     ebx, ebx
    mov     esi, ebx

    ;
    ; Pass over the BFV header
    ;
    mov     eax, ebp
    mov     bx, [ebp + 0x30]
    add     eax, ebx
    jc      secEntryPointWasNotFound

    jmp     searchingForFfsFileHeaderLoop

```


### 11.从 0xfffff4fe 跳转到  0xfffff524

```

(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffff4fe
->  0xfffff4fe: cmpl   $0x5473c07a, 0x10(%rax)   ; imm = 0x5473C07A 
    0xfffff505: jne    0xfffff524
    0xfffff507: cmpl   $0x4dca3dcb, 0x14(%rax)   ; imm = 0x4DCA3DCB 
    0xfffff50e: jne    0xfffff524
Target 0: (Bootstrap.dll) stopped.
(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffff505
->  0xfffff505: jne    0xfffff524
    0xfffff507: cmpl   $0x4dca3dcb, 0x14(%rax)   ; imm = 0x4DCA3DCB 
    0xfffff50e: jne    0xfffff524
    0xfffff510: cmpl   $0x961e6fbd, 0x18(%rax)   ; imm = 0x961E6FBD 
Target 0: (Bootstrap.dll) stopped.
(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffff524
->  0xfffff524: cmpl   $0x8c8ce578, 0x10(%rax)   ; imm = 0x8C8CE578 
    0xfffff52b: jne    0xfffff4f2
    0xfffff52d: cmpl   $0x4f1c8a3d, 0x14(%rax)   ; imm = 0x4F1C8A3D 
    0xfffff534: jne    0xfffff4f2
Target 0: (Bootstrap.dll) stopped.
(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffff52b
->  0xfffff52b: jne    0xfffff4f2
    0xfffff52d: cmpl   $0x4f1c8a3d, 0x14(%rax)   ; imm = 0x4F1C8A3D 
    0xfffff534: jne    0xfffff4f2
    0xfffff536: cmpl   $0x61893599, 0x18(%rax)   ; imm = 0x61893599 
Target 0: (Bootstrap.dll) stopped.
(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffff52d
->  0xfffff52d: cmpl   $0x4f1c8a3d, 0x14(%rax)   ; imm = 0x4F1C8A3D 
    0xfffff534: jne    0xfffff4f2
    0xfffff536: cmpl   $0x61893599, 0x18(%rax)   ; imm = 0x61893599 
    0xfffff53d: jne    0xfffff4f2
Target 0: (Bootstrap.dll) stopped.
```

对应源代码是 jne     searchingForFfs2Guid


```
    cmp     dword [eax + 0x10], FFS3_GUID_DWORD0
    jne     searchingForFfs2Guid

```

```

searchingForBfvHeaderLoop:
    ;
    ; We check for a firmware volume at every 4KB address in the top 16MB
    ; just below 4GB.  (Addresses at 0xffHHH000 where H is any hex digit.)
    ;
    sub     eax, 0x1000
    cmp     eax, 0xff000000
    jb      searchedForBfvHeaderButNotFound

    ;
    ; Check FFS3 GUID
    ;
    cmp     dword [eax + 0x10], FFS3_GUID_DWORD0
    jne     searchingForFfs2Guid
    cmp     dword [eax + 0x14], FFS3_GUID_DWORD1
    jne     searchingForFfs2Guid
    cmp     dword [eax + 0x18], FFS3_GUID_DWORD2
    jne     searchingForFfs2Guid
    cmp     dword [eax + 0x1c], FFS3_GUID_DWORD3
    jne     searchingForFfs2Guid
    jmp     checkingFvLength

searchingForFfs2Guid:
    ;
    ; Check FFS2 GUID
    ;
    cmp     dword [eax + 0x10], FFS2_GUID_DWORD0
    jne     searchingForBfvHeaderLoop
    cmp     dword [eax + 0x14], FFS2_GUID_DWORD1
    jne     searchingForBfvHeaderLoop
    cmp     dword [eax + 0x18], FFS2_GUID_DWORD2
    jne     searchingForBfvHeaderLoop
    cmp     dword [eax + 0x1c], FFS2_GUID_DWORD3
    jne     searchingForBfvHeaderLoop


```

### 12.在 Flat32SearchForSecEntryPoint 方法中循环几次后，在 0xfffcc08a 找到了  readyToTryFfsFileAtEcx

```
(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffff5a0
->  0xfffff5a0: cmpb   $0x3, 0x12(%rax)
    0xfffff5a4: jne    0xfffff5ac
    0xfffff5a6: jmp    0xfffff5bf
    0xfffff5a8: testl  %eax, %eax
Target 0: (Bootstrap.dll) stopped.
(lldb) p/x $rax
(unsigned long) 0x00000000fffcc078
(lldb) si
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffff5a4
->  0xfffff5a4: jne    0xfffff5ac
    0xfffff5a6: jmp    0xfffff5bf
    0xfffff5a8: testl  %eax, %eax
    0xfffff5aa: jne    0xfffff5b2
Target 0: (Bootstrap.dll) stopped.
(lldb) si
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffff5a6
->  0xfffff5a6: jmp    0xfffff5bf
    0xfffff5a8: testl  %eax, %eax
    0xfffff5aa: jne    0xfffff5b2
    0xfffff5ac: movl   %ecx, %eax
Target 0: (Bootstrap.dll) stopped.

```

对应源码是

```

jumpSinceWeFoundTheLastFfsFile:

    ;
    ; There seems to be a valid file at eax
    ;
    cmp     byte [eax + 0x12], EFI_FV_FILETYPE_SECURITY_CORE ; Check File Type
    jne     readyToTryFfsFileAtEcx

fileTypeIsSecCore:
    OneTimeCall GetEntryPointOfFfsFile
    test    eax, eax
    jnz     doneSeachingForSecEntryPoint

readyToTryFfsFileAtEcx:
    ;
    ; Try the next FFS file at ECX
    ;
    mov     eax, ecx
    jmp     searchingForFfsFileHeaderLoop


```

### 13.从 0xfffff5a6 跳转到 0xfffff5bf

```

(lldb) si
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffff5a4
->  0xfffff5a4: jne    0xfffff5ac
    0xfffff5a6: jmp    0xfffff5bf
    0xfffff5a8: testl  %eax, %eax
    0xfffff5aa: jne    0xfffff5b2
Target 0: (Bootstrap.dll) stopped.
(lldb) si
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffff5a6
->  0xfffff5a6: jmp    0xfffff5bf
    0xfffff5a8: testl  %eax, %eax
    0xfffff5aa: jne    0xfffff5b2
    0xfffff5ac: movl   %ecx, %eax
Target 0: (Bootstrap.dll) stopped.
(lldb) p/x 0x00000000fffcc078 + 12
(unsigned int) 0xfffcc084
(lldb) p/x 0x00000000fffcc078 + 0x12
(unsigned int) 0xfffcc08a
(lldb) si
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffff5bf
->  0xfffff5bf: testl  %eax, %eax
    0xfffff5c1: je     0xfffff622
    0xfffff5c3: addl   $0x18, %eax
    0xfffff5c6: cmpl   %ecx, %eax
Target 0: (Bootstrap.dll) stopped.

```

对应源码是     OneTimeCall GetEntryPointOfFfsFile

```

jumpSinceWeFoundTheLastFfsFile:

    ;
    ; There seems to be a valid file at eax
    ;
    cmp     byte [eax + 0x12], EFI_FV_FILETYPE_SECURITY_CORE ; Check File Type
    jne     readyToTryFfsFileAtEcx

fileTypeIsSecCore:
    OneTimeCall GetEntryPointOfFfsFile
    test    eax, eax
    jnz     doneSeachingForSecEntryPoint

```

### 14.从 0xfffff5f3 跳转到 0xfffff5f5

```

(lldb) si
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffff5ee
->  0xfffff5ee: cmpw   $0x5a4d, (%rax)           ; imm = 0x5A4D 
    0xfffff5f3: jne    0xfffff622
    0xfffff5f5: movzwl 0x3c(%rax), %ebx
    0xfffff5f9: addl   %eax, %ebx
Target 0: (Bootstrap.dll) stopped.
(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffff5f3
->  0xfffff5f3: jne    0xfffff622
    0xfffff5f5: movzwl 0x3c(%rax), %ebx
    0xfffff5f9: addl   %eax, %ebx
    0xfffff5fb: cmpl   $0x4550, (%rbx)           ; imm = 0x4550 
Target 0: (Bootstrap.dll) stopped.
(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffff5f5
->  0xfffff5f5: movzwl 0x3c(%rax), %ebx
    0xfffff5f9: addl   %eax, %ebx
    0xfffff5fb: cmpl   $0x4550, (%rbx)           ; imm = 0x4550 
    0xfffff601: jne    0xfffff622
Target 0: (Bootstrap.dll) stopped.


```

对应源代码是  getEntryPointOfFfsFileFoundPeFile
其中 getEntryPointOfFfsFileFoundPe32Section 方法对应的内容在编译时应该被处理了，删除了部分内容


```


getEntryPointOfFfsFileFoundPe32Section:
    add     eax, 4       ; EAX = Start of PE or UE image

    cmp     word [eax], 'MZ'
    je      getEntryPointOfFfsFileFoundPeFile

    cmp     word [eax], 'UE'
    jne     getEntryPointOfFfsFileErrorReturn
    
    ; *EntryPoint = (VOID *)((UINTN)UeData + UeHdr.EntryPointAddress)
    mov     ebx, dword [eax + 0x4]
    add     eax, ebx
    jmp     getEntryPointOfFfsFileReturn

getEntryPointOfFfsFileFoundPeFile:
    movzx   ebx, word [eax + 0x3c]
    add     ebx, eax

    ; if (Hdr.Pe32->Signature == EFI_IMAGE_NT_SIGNATURE)
    cmp     dword [ebx], `PE\x00\x00`
    jne     getEntryPointOfFfsFileErrorReturn

    ; *EntryPoint = (VOID *)((UINTN)Pe32Data +
    ;   (UINTN)(Hdr.Pe32->OptionalHeader.AddressOfEntryPoint & 0x0ffffffff));
    add     eax, [ebx + 0x4 + 0x14 + 0x10]
    jmp     getEntryPointOfFfsFileReturn


```


### 15.从 0xfffff627 跳转到  0xfffff5a8

```

(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffff606
->  0xfffff606: jmp    0xfffff627
    0xfffff608: addl   $0x4, %eax
    0xfffff60b: movl   %eax, %ebx
    0xfffff60d: cmpw   $0x5a56, (%rbx)           ; imm = 0x5A56 
Target 0: (Bootstrap.dll) stopped.
(lldb) si
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffff627
->  0xfffff627: jmp    0xfffff5a8
    0xfffff62c: nop    
    0xfffff62d: nop    
    0xfffff62e: nop    
Target 0: (Bootstrap.dll) stopped.
(lldb) si
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffff5a8
->  0xfffff5a8: testl  %eax, %eax
    0xfffff5aa: jne    0xfffff5b2
    0xfffff5ac: movl   %ecx, %eax
    0xfffff5ae: jmp    0xfffff57a
Target 0: (Bootstrap.dll) stopped.
(lldb)  


```

对应源码是     返回到GetEntryPointOfFfsFile 调用的地方 OneTimeCallRet GetEntryPointOfFfsFile


```

getEntryPointOfFfsFileFoundPeFile:
    movzx   ebx, word [eax + 0x3c]
    add     ebx, eax

    ; if (Hdr.Pe32->Signature == EFI_IMAGE_NT_SIGNATURE)
    cmp     dword [ebx], `PE\x00\x00`
    jne     getEntryPointOfFfsFileErrorReturn

    ; *EntryPoint = (VOID *)((UINTN)Pe32Data +
    ;   (UINTN)(Hdr.Pe32->OptionalHeader.AddressOfEntryPoint & 0x0ffffffff));
    add     eax, [ebx + 0x4 + 0x14 + 0x10]
    jmp     getEntryPointOfFfsFileReturn

getEntryPointOfFfsFileErrorReturn:
    mov     eax, 0

getEntryPointOfFfsFileReturn:
    OneTimeCallRet GetEntryPointOfFfsFile


```

 返回到GetEntryPointOfFfsFile 调用的地方 

```
fileTypeIsSecCore:
    OneTimeCall GetEntryPointOfFfsFile
    test    eax, eax
    jnz     doneSeachingForSecEntryPoint

```


### 16. 从 0xfffff5aa->0xfffff5b2->0xfffff5b6->0xfffff5ba->0xffffff37

```

(lldb) si
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffff5a8
->  0xfffff5a8: testl  %eax, %eax
    0xfffff5aa: jne    0xfffff5b2
    0xfffff5ac: movl   %ecx, %eax
    0xfffff5ae: jmp    0xfffff57a
Target 0: (Bootstrap.dll) stopped.
(lldb) si
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffff5aa
->  0xfffff5aa: jne    0xfffff5b2
    0xfffff5ac: movl   %ecx, %eax
    0xfffff5ae: jmp    0xfffff57a
    0xfffff5b0: xorl   %eax, %eax
Target 0: (Bootstrap.dll) stopped.
(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffff5b2
->  0xfffff5b2: movl   %eax, %esi
    0xfffff5b4: testl  %esi, %esi
    0xfffff5b6: jne    0xfffff5ba
    0xfffff5b8: je     0xfffff5b8
Target 0: (Bootstrap.dll) stopped.
(lldb) p/x $eax
(unsigned int) 0xfffcdfd1
(lldb) si
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffff5b4
->  0xfffff5b4: testl  %esi, %esi
    0xfffff5b6: jne    0xfffff5ba
    0xfffff5b8: je     0xfffff5b8
    0xfffff5ba: jmp    0xffffff37
Target 0: (Bootstrap.dll) stopped.
(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffff5b6
->  0xfffff5b6: jne    0xfffff5ba
    0xfffff5b8: je     0xfffff5b8
    0xfffff5ba: jmp    0xffffff37
    0xfffff5bf: testl  %eax, %eax
Target 0: (Bootstrap.dll) stopped.
(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffff5ba
->  0xfffff5ba: jmp    0xffffff37
    0xfffff5bf: testl  %eax, %eax
    0xfffff5c1: je     0xfffff622
    0xfffff5c3: addl   $0x18, %eax
Target 0: (Bootstrap.dll) stopped.
(lldb) si
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000ffffff37
->  0xffffff37: jmp    0xfffff710
    0xffffff3c: movl   $0xffffffff, %eax         ; imm = 0xFFFFFFFF 
    0xffffff41: andq   %rax, %rsi
    0xffffff44: andq   %rax, %rbp
Target 0: (Bootstrap.dll) stopped.
```




对应源码是 jnz     doneSeachingForSecEntryPoint ->     jnz     secCoreEntryPointWasFound ->   OneTimeCallRet Flat32SearchForSecEntryPoint
->    OneTimeCall Transition32FlatTo64Flat


```

fileTypeIsSecCore:
    OneTimeCall GetEntryPointOfFfsFile
    test    eax, eax
    jnz     doneSeachingForSecEntryPoint

readyToTryFfsFileAtEcx:
    ;
    ; Try the next FFS file at ECX
    ;
    mov     eax, ecx
    jmp     searchingForFfsFileHeaderLoop

secEntryPointWasNotFound:
    xor     eax, eax

doneSeachingForSecEntryPoint:
    mov     esi, eax

    test    esi, esi
    jnz     secCoreEntryPointWasFound

secCoreEntryPointWasNotFound:
    ;
    ; Hang if the SEC entry point was not found
    ;
    debugShowPostCode POSTCODE_SEC_NOT_FOUND
    jz      $

secCoreEntryPointWasFound:
    debugShowPostCode POSTCODE_SEC_FOUND

    OneTimeCallRet Flat32SearchForSecEntryPoint
```

```

BITS    32

    ;
    ; Search for the Boot Firmware Volume (BFV)
    ;
    OneTimeCall Flat32SearchForBfvBase

    ;
    ; EBP - Start of BFV
    ;

    ;
    ; Search for the SEC entry point
    ;
    OneTimeCall Flat32SearchForSecEntryPoint

    ;
    ; ESI - SEC Core entry point
    ; EBP - Start of BFV
    ;

%ifdef ARCH_IA32

    ;
    ; Restore initial EAX value into the EAX register
    ;
    mov     eax, esp

    ;
    ; Jump to the 32-bit SEC entry point
    ;
    jmp     esi

%else

    ;
    ; Transition the processor from 32-bit flat mode to 64-bit flat mode
    ;
    OneTimeCall Transition32FlatTo64Flat

```

### 17. 0xffffff37-> 0xfffff710->0xfffff79e->0xfffffa6d

```

(lldb) si
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000ffffff37
->  0xffffff37: jmp    0xfffff710
    0xffffff3c: movl   $0xffffffff, %eax         ; imm = 0xFFFFFFFF 
    0xffffff41: andq   %rax, %rsi
    0xffffff44: andq   %rax, %rbp
Target 0: (Bootstrap.dll) stopped.
(lldb) si
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffff710
->  0xfffff710: jmp    0xfffff79e
    0xfffff715: movq   %cr4, %rax
    0xfffff718: btsl   $0x5, %eax
    0xfffff71c: movq   %rax, %cr4
Target 0: (Bootstrap.dll) stopped.
(lldb) si
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffff79e
->  0xfffff79e: jmp    0xfffffa6d
    0xfffff7a3: cmpl   $0x1, %eax
    0xfffff7a6: je     0xfffff907
    0xfffff7ac: cmpl   $0x2, %eax
Target 0: (Bootstrap.dll) stopped.
(lldb) si
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffffa6d
->  0xfffffa6d: xorl   %eax, %eax
    0xfffffa6f: cmpb   $0x2, 0x80b000(%rip)
    0xfffffa76: jne    0xfffffa80
    0xfffffa78: xorl   %edx, %edx
Target 0: (Bootstrap.dll) stopped.
(lldb)  


```


对应源码是 Transition32FlatTo64Flat->SetCr3ForPageTables64->CheckTdxFeaturesBeforeBuildPagetables

```

    ;
    ; Transition the processor from 32-bit flat mode to 64-bit flat mode
    ;
    OneTimeCall Transition32FlatTo64Flat
```

```
Transition32FlatTo64Flat:

    OneTimeCall SetCr3ForPageTables64

    mov     eax, cr4
    bts     eax, 5                      ; enable PAE
    mov     cr4, eax

    mov     ecx, 0xc0000080
    rdmsr
    bts     eax, 8                      ; set LME
    wrmsr

    mov     eax, cr0
    bts     eax, 31                     ; set PG
    mov     cr0, eax                    ; enable paging

    jmp     LINEAR_CODE64_SEL:ADDR_OF(jumpTo64BitAndLandHere)

```



```
SetCr3ForPageTables64:
    ; Check the TDX features.
    ; If it is TDX APs, then jump to SetCr3 directly.
    ; In TD guest the initialization is done by BSP, including building
    ; the page tables. APs will spin on until byte[TDX_WORK_AREA_PGTBL_READY]
    ; is set.
    OneTimeCall   CheckTdxFeaturesBeforeBuildPagetables
    cmp       eax, TDX_BSP
    je        ClearOvmfPageTables
    cmp       eax, TDX_AP
    je        SetCr3

    ; Check whether the SEV is active and populate the SevEsWorkArea
    OneTimeCall   CheckSevFeatures

    ; If SEV is enabled, the C-bit position is always above 31.
    ; The mask will be saved in the EDX and applied during the
    ; the page table build below.
    OneTimeCall   GetSevCBitMaskAbove31
```

```

CheckTdxFeaturesBeforeBuildPagetables:
    xor     eax, eax
    cmp     byte[WORK_AREA_GUEST_TYPE], VM_GUEST_TDX
    jne     NotTdx

    xor     edx, edx
    mov     al, byte[TDX_WORK_AREA_PGTBL_READY]
    inc     eax


```


### 18.0xfffffa6d->0xfffffa80->0xfffff7a3


```

(lldb) si
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffffa6d
->  0xfffffa6d: xorl   %eax, %eax
    0xfffffa6f: cmpb   $0x2, 0x80b000(%rip)
    0xfffffa76: jne    0xfffffa80
    0xfffffa78: xorl   %edx, %edx
Target 0: (Bootstrap.dll) stopped.
(lldb) si
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffffa6f
->  0xfffffa6f: cmpb   $0x2, 0x80b000(%rip)
    0xfffffa76: jne    0xfffffa80
    0xfffffa78: xorl   %edx, %edx
    0xfffffa7a: movabsb -0x2e116bfff7f4ffc, %al
Target 0: (Bootstrap.dll) stopped.
(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffffa76
->  0xfffffa76: jne    0xfffffa80
    0xfffffa78: xorl   %edx, %edx
    0xfffffa7a: movabsb -0x2e116bfff7f4ffc, %al
Target 0: (Bootstrap.dll) stopped.
(lldb) si
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffffa80
->  0xfffffa80: jmp    0xfffff7a3
    0xfffffa85: movb   $0x1, 0x80b004(%rip)
    0xfffffa8c: jmp    0xfffff9a4
    0xfffffa91: xorl   %eax, %eax
Target 0: (Bootstrap.dll) stopped.
(lldb) si
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffff7a3
->  0xfffff7a3: cmpl   $0x1, %eax
    0xfffff7a6: je     0xfffff907
    0xfffff7ac: cmpl   $0x2, %eax
    0xfffff7af: je     0xfffff9a6
Target 0: (Bootstrap.dll) stopped.
(lldb)  

```

对应源码是     OneTimeCallRet CheckTdxFeaturesBeforeBuildPagetables ->     cmp       eax, TDX_BSP

```
CheckTdxFeaturesBeforeBuildPagetables:
    xor     eax, eax
    cmp     byte[WORK_AREA_GUEST_TYPE], VM_GUEST_TDX
    jne     NotTdx

    xor     edx, edx
    mov     al, byte[TDX_WORK_AREA_PGTBL_READY]
    inc     eax

NotTdx:
    OneTimeCallRet CheckTdxFeaturesBeforeBuildPagetables


```

```

SetCr3ForPageTables64:
    ; Check the TDX features.
    ; If it is TDX APs, then jump to SetCr3 directly.
    ; In TD guest the initialization is done by BSP, including building
    ; the page tables. APs will spin on until byte[TDX_WORK_AREA_PGTBL_READY]
    ; is set.
    OneTimeCall   CheckTdxFeaturesBeforeBuildPagetables
    cmp       eax, TDX_BSP
    je        ClearOvmfPageTables
    cmp       eax, TDX_AP
    je        SetCr3


```

### 19. 0xfffff7b5->0xfffffb9a

```
(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffff7ac
->  0xfffff7ac: cmpl   $0x2, %eax
    0xfffff7af: je     0xfffff9a6
    0xfffff7b5: jmp    0xfffffb9a
    0xfffff7ba: cmpb   $0x1, 0x80b000(%rip)
Target 0: (Bootstrap.dll) stopped.
(lldb) si
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffff7af
->  0xfffff7af: je     0xfffff9a6
    0xfffff7b5: jmp    0xfffffb9a
    0xfffff7ba: cmpb   $0x1, 0x80b000(%rip)
    0xfffff7c1: je     0xfffff864
Target 0: (Bootstrap.dll) stopped.
(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffff7b5
->  0xfffff7b5: jmp    0xfffffb9a
    0xfffff7ba: cmpb   $0x1, 0x80b000(%rip)
    0xfffff7c1: je     0xfffff864
    0xfffff7c7: movl   $0x1800, %ecx             ; imm = 0x1800 
Target 0: (Bootstrap.dll) stopped.
(lldb) si
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffffb9a
->  0xfffffb9a: movl   $0x19, %ecx
    0xfffffb9f: movl   $0x80b004, %eax           ; imm = 0x80B004 
    0xfffffba4: movb   $0x0, (%rax)
    0xfffffba7: loop   0xfffffba4
Target 0: (Bootstrap.dll) stopped.

* thread #1, stop reason = breakpoint 2.1
    frame #0: 0x00000000fffffbb4
->  0xfffffbb4: lidtq  %cs:(%rax)
    0xfffffbb8: movl   $0x80000000, %eax         ; imm = 0x80000000 
    0xfffffbbd: cpuid  
    0xfffffbbf: cmpl   $0x8000001f, %eax         ; imm = 0x8000001F 
Target 0: (Bootstrap.dll) stopped.
(lldb) p/x $rax
(unsigned long) 0x00000000fffffd76

```

对应源码是     OneTimeCall   CheckSevFeatures


```
SetCr3ForPageTables64:
    ; Check the TDX features.
    ; If it is TDX APs, then jump to SetCr3 directly.
    ; In TD guest the initialization is done by BSP, including building
    ; the page tables. APs will spin on until byte[TDX_WORK_AREA_PGTBL_READY]
    ; is set.
    OneTimeCall   CheckTdxFeaturesBeforeBuildPagetables
    cmp       eax, TDX_BSP
    je        ClearOvmfPageTables
    cmp       eax, TDX_AP
    je        SetCr3

    ; Check whether the SEV is active and populate the SevEsWorkArea
    OneTimeCall   CheckSevFeatures

    ; If SEV is enabled, the C-bit position is always above 31.
    ; The mask will be saved in the EDX and applied during the
    ; the page table build below.
    OneTimeCall   GetSevCBitMaskAbove31
```

```

CheckSevFeatures:
    ;
    ; Clear the workarea, if SEV is enabled then later part of routine
    ; will populate the workarea fields.
    ;
    mov    ecx, SEV_ES_WORK_AREA_SIZE
    mov    eax, SEV_ES_WORK_AREA
ClearSevEsWorkArea:
    mov    byte [eax], 0
    inc    eax
    loop   ClearSevEsWorkArea

    ;
    ; Set up exception handlers to check for SEV-ES
    ;   Load temporary RAM stack based on PCDs (see SevEsIdtVmmComm for
    ;   stack usage)
    ;   Establish exception handlers
    ;
    mov       esp, SEV_ES_VC_TOP_OF_STACK
    mov       eax, ADDR_OF(Idtr)
    lidt      [cs:eax]

    ; Check if we have a valid (0x8000_001F) CPUID leaf
    ;   CPUID raises a #VC exception if running as an SEV-ES guest
    mov       eax, 0x80000000
    cpuid

    ; This check should fail on Intel or Non SEV AMD CPUs. In future if
    ; Intel CPUs supports this CPUID leaf then we are guranteed to have exact
    ; same bit definition.
    cmp       eax, 0x8000001f
    jl        NoSev

    ; Check for SEV memory encryption feature:
    ; CPUID  Fn8000_001F[EAX] - Bit 1
    ;   CPUID raises a #VC exception if running as an SEV-ES guest
    mov       eax, 0x8000001f
    cpuid
    bt        eax, 1
    jnc       NoSev

    ; Check if SEV memory encryption is enabled
    ;  MSR_0xC0010131 - Bit 0 (SEV enabled)
    mov       ecx, SEV_STATUS_MSR
    rdmsr
    bt        eax, 0
    jnc       NoSev

    ; Set the work area header to indicate that the SEV is enabled
    mov     byte[WORK_AREA_GUEST_TYPE], 1

    ; Save the SevStatus MSR value in the workarea
    mov     [SEV_ES_WORK_AREA_STATUS_MSR], eax
    mov     [SEV_ES_WORK_AREA_STATUS_MSR + 4], edx

    ; Check if SEV-ES is enabled
    ;  MSR_0xC0010131 - Bit 1 (SEV-ES enabled)
    mov       ecx, SEV_STATUS_MSR
    rdmsr
    bt        eax, 1
    jnc       GetSevEncBit

```

```
    mov       eax, ADDR_OF(Idtr)
    lidt      [cs:eax]
```
    对应中断描述符的位置是 

```
Process 1 resuming
Process 1 stopped
* thread #1, stop reason = breakpoint 2.1
    frame #0: 0x00000000fffffbb4
->  0xfffffbb4: lidtq  %cs:(%rax)
    0xfffffbb8: movl   $0x80000000, %eax         ; imm = 0x80000000 
    0xfffffbbd: cpuid  
    0xfffffbbf: cmpl   $0x8000001f, %eax         ; imm = 0x8000001F 
Target 0: (Bootstrap.dll) stopped.
(lldb) p/x $rax
(unsigned long) 0x00000000fffffd76
(lldb) x/100 0x00000000fffffd76
0xfffffd76: 0xfd9000ff 0x0000ffff 0x00000000 0x90909090
0xfffffd86: 0x90909090 0x90909090 0x00009090 0x8e000010
0xfffffd96: 0x00000000 0x8e000010 0x00000000 0x8e000010
0xfffffda6: 0x00000000 0x8e000010 0x00000000 0x8e000010
0xfffffdb6: 0x00000000 0x8e000010 0x00000000 0x8e000010
0xfffffdc6: 0x00000000 0x8e000010 0x00000000 0x8e000010
```


专业术语

SEV and SEV-ES

https://www.amd.com/en/developer/sev.html

### 20.0xfffffc43
```

(lldb) si
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffffc33
->  0xfffffc33: pushq  %rax
    0xfffffc34: movl   $0xfffffd7c, %eax         ; imm = 0xFFFFFD7C 
    0xfffffc39: lidtq  %cs:(%rax)
    0xfffffc3d: popq   %rax
Target 0: (Bootstrap.dll) stopped.
(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffffc34
->  0xfffffc34: movl   $0xfffffd7c, %eax         ; imm = 0xFFFFFD7C 
    0xfffffc39: lidtq  %cs:(%rax)
    0xfffffc3d: popq   %rax
    0xfffffc3e: movl   $0x0, %esp
Target 0: (Bootstrap.dll) stopped.
(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffffc39
->  0xfffffc39: lidtq  %cs:(%rax)
    0xfffffc3d: popq   %rax
    0xfffffc3e: movl   $0x0, %esp
    0xfffffc43: jmp    0xfffff7ba
Target 0: (Bootstrap.dll) stopped.
(lldb) si
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffffc3d
->  0xfffffc3d: popq   %rax
    0xfffffc3e: movl   $0x0, %esp
    0xfffffc43: jmp    0xfffff7ba
    0xfffffc48: movl   $0x1, %eax
Target 0: (Bootstrap.dll) stopped.
(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffffc3e
->  0xfffffc3e: movl   $0x0, %esp
    0xfffffc43: jmp    0xfffff7ba
    0xfffffc48: movl   $0x1, %eax
    0xfffffc4d: shll   $0x10, %eax
Target 0: (Bootstrap.dll) stopped.
(lldb)  
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffffc43
->  0xfffffc43: jmp    0xfffff7ba
    0xfffffc48: movl   $0x1, %eax
    0xfffffc4d: shll   $0x10, %eax
    0xfffffc50: orl    $0x1100, %eax             ; imm = 0x1100 
Target 0: (Bootstrap.dll) stopped.
(lldb) si
Process 1 stopped
* thread #1, stop reason = instruction step into
    frame #0: 0x00000000fffff7ba
->  0xfffff7ba: cmpb   $0x1, 0x80b000(%rip)
    0xfffff7c1: je     0xfffff864
    0xfffff7c7: movl   $0x1800, %ecx             ; imm = 0x1800 
    0xfffff7cc: xorl   %eax, %eax
Target 0: (Bootstrap.dll) stopped.

```


对应源码是     OneTimeCallRet CheckSevFeatures


```

SevExit:
    ;
    ; Clear exception handlers and stack
    ;
    push      eax
    mov       eax, ADDR_OF(IdtrClear)
    lidt      [cs:eax]
    pop       eax
    mov       esp, 0

    OneTimeCallRet CheckSevFeatures

```

```

SetCr3ForPageTables64:
    ; Check the TDX features.
    ; If it is TDX APs, then jump to SetCr3 directly.
    ; In TD guest the initialization is done by BSP, including building
    ; the page tables. APs will spin on until byte[TDX_WORK_AREA_PGTBL_READY]
    ; is set.
    OneTimeCall   CheckTdxFeaturesBeforeBuildPagetables
    cmp       eax, TDX_BSP
    je        ClearOvmfPageTables
    cmp       eax, TDX_AP
    je        SetCr3

    ; Check whether the SEV is active and populate the SevEsWorkArea
    OneTimeCall   CheckSevFeatures

    ; If SEV is enabled, the C-bit position is always above 31.
    ; The mask will be saved in the EDX and applied during the
    ; the page table build below.
    OneTimeCall   GetSevCBitMaskAbove31

```

## 6.使用GDB  分析 OVMF_CODE.fd 在qemu中运行的第一行代码


## 7.开机第一条指令的分析

https://blog.51cto.com/u_16099264/8344097

```
而一种比较特殊的情况是在80386 CPU复位的时候，隐藏寄存器中的段基址被初始化为FFFF0000h,直接和EIP(FFF0h)相加则得到了第一条指令地址0xFFFFFFF0

```


```
 开机时CPU进入实模式，8086以及80286的寻址方式为段寄存器左移4位+偏移地址（IP中的值）。第一条指令为FFFF0h,位于1M字节的往下第16个字节的地方。而到了80386，段寄存器由一个段选择子、基地址、长度和访问属性构成（80286就有了，不过是一个过渡阶段，还是以386为主，资料记载比较多），无论是在实模式还是在保护模式下，访问物理内存的方法都是段寄存器中隐藏部分的段基址与EIP相加得到的地址。
        80386 CPU在保护模式下由段选择子在段描述符表中取出基地址，然后放到CS寄存器中隐藏部分的段基址中，再和EIP偏移地址相加得到（下次直接从隐藏寄存器中取出相加即可，提高速度）。在实模式下，则是由16位的段选择子左移4位写入到副本寄存器中基地址，再由此基址和IP相加得到，后续程序只需要使用Jmp IP指令，CPU直接从副本寄存器中的基地址取出与IP作相加运算即可，无需在使用CS左移4位的方式，来提供速度。
        而一种比较特殊的情况是在80386 CPU复位的时候，隐藏寄存器中的段基址被初始化为FFFF0000h,直接和EIP(FFF0h)相加则得到了第一条指令地址0xFFFFFFF0。实模式下，本来只能访问1M的物理空间，而现在却到了4G-16字节处，显然超出了实模式的1M寻址范围限制，其内部电路强行把FFFF0000写入到了隐藏寄存器中的段基址，当代码第一次尝试修改CS寄存器后，CPU的寻址范围才会被限制在1M以内。


```


### 传统BIOS的启动


《操作系统真象还原》 P56

```
按理说，既然让 CPU 去执行 0xFFFF0 处的内容(目前还不知道其是指令，还是数据)，此内容应该是指 令才行，否则这地址处的内容若是数据，而不是指令，CPU 硬是把它当成指令来译码的话，一定会弄巧成拙 铸成大错。现在咱们又有了新的推断，物理地址 0xFFFF0 处应该是指令，继续探索。
继续看第二个框框，里面有条指令jmp far f000:e05b，这是条跳转指令，也就是证明了在内存物理 地址 0xFFFF0 处的内容是一条跳转指令，我们的判断是正确的。那 CPU 的执行流是跳到哪里了呢?段基 址 0xf000 左移 4 位+0xe05b，即跳向了 0xfe05b 处，这是 BIOS 代码真正开始的地方。
第三个框框 cs:f000，其意义是 cs 寄存器的值是 f000，与我们刚刚所说的加电时强制将 cs 置为 f000 是吻合的，正确。
接下来 BIOS 便马不停蹄地检测内存、显卡等外设信息，当检测通过，并初始化好硬件后，开始在内 存中 0x000~0x3FF 处建立数据结构，中断向量表 IVT 并填写中断例程。
  好了，终于到了接力的时刻，这是这场接力赛的第一棒，它将交给谁呢?咱们下回再说。

2.2.3 为什么是 0x7c00
```

# 问题汇总

## 1.使用 /Users/lee/Desktop/Computer_Systems/UEFI/KVM-Opencore/src/OpenCorePkg/UDK/Build/OvmfX64/DEBUG_XCODE5/FV/OVMF_CODE.fd 代替  /Users/lee/Desktop/Computer_Systems/UEFI/edk2/Build/OvmfX64/DEBUG_XCODE5/FV/OVMF.fd，  但是会报错 256:452 00:436 OCB: LoadImage failed - Volume Corrupt

使用：Please enable FixupAppleEfiImages quirk in your config.plist  解决了

https://github.com/acidanthera/bugtracker/issues/2389