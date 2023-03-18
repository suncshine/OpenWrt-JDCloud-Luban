#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

echo "-----------------Modify default IP"
sed -i 's/192.168.1.1/192.168.68.1/g' package/base-files/files/bin/config_generate
grep  192 -n3 package/base-files/files/bin/config_generate

echo '-----------------修改时区为东八区'
echo '-----------------修改主机名为 Luban'
sed -i "s/'UTC'/'CST-8'\n        set system.@system[-1].zonename='Asia\/Shanghai'/g" package/base-files/files/bin/config_generate
sed -i 's/OpenWrt/Luban/g' package/base-files/files/bin/config_generate
grep Luban -n5 package/base-files/files/bin/config_generate


# Delete default password
#echo '-----------------删除默认密码'
#sed -i '/CYXluq4wUazHjmCDBCqXF/d' package/lean/default-settings/files/zzz-default-settings

# 修改连接数
echo '--------修改连接数'
echo 'net.netfilter.nf_conntrack_max=165535' >> package/base-files/files/etc/sysctl.conf
cat package/base-files/files/etc/sysctl.conf

# Modify the version number一个自己的名字（AutoBuild $(TZ=UTC-8 date "+%Y.%m.%d") @ 这些都是后增加的）
#echo '--------------修改版本号显示'
#sed -i 's/OpenWrt /AutoBuild $(TZ=UTC-8 date "+%Y.%m.%d") @ OpenWrt /g' package/lean/default-settings/files/zzz-default-settings

#开启MU-MIMO
sed -i 's/mu_beamformer=0/mu_beamformer=1/g' package/kernel/mac80211/files/lib/wifi/mac80211.sh
# 修改默认wifi名称ssid
sed -i 's/ssid=OpenWrt/ssid=JDC_0601/g' package/kernel/mac80211/files/lib/wifi/mac80211.sh
echo '---开启MU-MIMO/修改默认wifi名称ssid'
grep -E 'ssid|mu_beam' -n10 package/kernel/mac80211/files/lib/wifi/mac80211.sh

# 更换清华源
echo '---更换清华源'
sed -i 's_downloads.openwrt.org_mirrors.tuna.tsinghua.edu.cn/openwrt_' /etc/opkg/distfeeds.conf
cat /etc/opkg/distfeeds.conf

echo "------修改u-boot的ramips"
sed -i 's/yuncore,ax820/jdcloud,luban/g' package/boot/uboot-envtools/files/ramips

grep jdcloud -n5 package/boot/uboot-envtools/files/ramips

echo '------载入 mt7621_jdcloud_luban.dts'
curl --retry 3 -s --globoff "https://gist.githubusercontent.com/pmyy-wt/1b832d23e74aa9f7d06549fd15e979e2/raw/a3e132b26e3f4b14f926232359b5e88b0a1035eb/mt7621_jdcloud_luban.dts" -o target/linux/ramips/dts/mt7621_jdcloud_luban.dts
ls -al target/linux/ramips/dts/mt7621_jdcloud_luban.dts

# fix2 + fix4.2
echo '--------修补 mt7621.mk'
sed -i '/Device\/adslr_g7/i\define Device\/jdcloud_luban\n  \$(Device\/dsa-migration)\n  \$(Device\/uimage-lzma-loader)\n  IMAGE_SIZE := 15808k\n  DEVICE_VENDOR := JDCloud\n  DEVICE_MODEL := luban\n  DEVICE_PACKAGES := kmod-fs-ext4 kmod-mt7915-firmware kmod-mt7915e kmod-sdhci-mt7620 uboot-envtools kmod-mmc kmod-mtk-hnat kmod-mtd-rw wpad-openssl\nendef\nTARGET_DEVICES += jdcloud_luban\n\n' target/linux/ramips/image/mt7621.mk
grep 'Device/jdcloud_luban' -n10 target/linux/ramips/image/mt7621.mk

# fix3 + fix5.2
echo '-------修补 02-network'
sed -i '/gehua,ghl-r-001/i\jdcloud,luban|\\' target/linux/ramips/mt7621/base-files/etc/board.d/02_network
grep ghl-r-001 -n3 target/linux/ramips/mt7621/base-files/etc/board.d/02_network

#失败的配置，备份
#sed -i -e '/hiwifi,hc5962|\\/i\jdcloud,luban|\\' -e '/ramips_setup_macs/,/}/{/ampedwireless,ally-00x19k/i\jdcloud,luban)\n\t\t[ "$PHYNBR" -eq 0 \] && echo $label_mac > /sys${DEVPATH}/macaddress\n\t\t\[ "$PHYNBR" -eq 1 \] && macaddr_add $label_mac 0x800000 > /sys${DEVPATH}/macaddress\n\t\t;;
#}' target/linux/ramips/mt7621/base-files/etc/board.d/02_network

#失败的配置，备份
#sed -i '/ampedwireless,ally-00x19k|\\/i\jdcloud,luban)\n\t\tucidef_add_switch "switch0" \\ \n\t\t"0:lan" "1:lan" "2:lan" "3:lan" "4:wan" "6u@eth0" "5u@eth1"\n\t\t;;' target/linux/ramips/mt7621/base-files/etc/board.d/02_network

#sed -i -e '/hiwifi,hc5962|\\/i\jdcloud,luban|\\' -e '/ramips_setup_macs/,/}/{/ampedwireless,ally-00x19k/i\jdcloud,luban)\n\t\techo "dc:d8:7c:50:fa:ae" > /sys/devices/platform/1e100000.ethernet/net/eth0/address\n\t\techo "dc:d8:7c:50:fa:af" > /sys/devices/platform/1e100000.ethernet/net/eth1/address\n\t\t;;
#}' target/linux/ramips/mt7621/base-files/etc/board.d/02_network

#cat target/linux/ramips/mt7621/base-files/etc/board.d/02_network

# fix5.1
#echo '修补 system.sh 以正常读写 MAC'
#sed -i 's#key"'\''=//p'\''#& \| head -n1#' package/base-files/files/lib/functions/system.sh

#借用lede的
#sed -i '/pcie: pcie@1e140000/i\hnat: hnat@1e100000 {\n\tcompatible = "mediatek,mtk-hnat_v1";\n\text-devices = "ra0", "rai0", "rax0",\n\t\t"apcli0", "apclii0","apclix0";\n\treg = <0x1e100000 0x3000>;\n\n\tresets = <&ethsys 0>;\n\treset-names = "mtketh";\n\n\tmtketh-wan = "wan";\n\tmtketh-ppd = "lan";\n\tmtketh-lan = "lan";\n\tmtketh-max-gmac = <1>;\n\tmtkdsa-wan-port = <4>;\n\t};\n\n'  ./target/linux/ramips/dts/mt7621.dtsi
#sed -i '/pcie: pcie@1e140000/i\gsw: gsw@1e110000 {\n\tcompatible = "mediatek,mt753x";\n\treg = <0x1e110000 0x8000>;\n\tinterrupt-parent = <&gic>;\n\tinterrupts = <GIC_SHARED 23 IRQ_TYPE_LEVEL_HIGH>;\n\n\tmediatek,mcm;\n\tmediatek,mdio = <&mdio>;\n\tmt7530,direct-phy-access;\n\n\tresets = <&rstctrl 2>;\n\treset-names = "mcm";\n\tstatus = "disabled";\n\n\tport@5 {\n\n\tcompatible = "mediatek,mt753x-port";\n\treg = <5>;\n\tphy-mode = "rgmii";\n\tfixed-link {\n\tspeed = <1000>;\n\tfull-duplex;\n\t};\n\t};\n\n\tport@6 {\n\tcompatible = "mediatek,mt753x-port";\n\treg = <6>;\n\tphy-mode = "rgmii";\n\n\tfixed-link {\n\tspeed = <1000>;\n\tfull-duplex;\n\t};\n\t};\n\t};\n\t'  ./target/linux/ramips/dts/mt7621.dtsi
#sed -i '/ethernet: ethernet@1e100000 {/i\ethsys: ethsys@1e000000 {\n\tcompatible = "mediatek,mt7621-ethsys",\n\t\t"syscon";\n\treg = <0x1e000000 0x1000>;\n\t#clock-cells = <1>;\n\t};\n\n'  ./target/linux/ramips/dts/mt7621.dtsi	

#echo '-----------------定义kernel MD5，与官网一致'
#echo '2974fbe1fa59be88f13eb8abeac8c10b' > ./.vermagic
#cat .vermagic

#sed -i 's/^\tgrep.*vermagic/\tcp -f \$(TOPDIR)\/\.vermagic \$(LINUX_DIR)\/\.vermagic/g' include/kernel-defaults.mk
#grep vermagic -n5 include/kernel-defaults.mk
