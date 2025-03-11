#!/bin/bash

rm -rf openwrt
rm -rf mtk-openwrt-feeds

git clone --branch openwrt-24.10 https://git.openwrt.org/openwrt/openwrt.git openwrt || true
cd openwrt; git checkout 56559278b78900f6cae5fda6b8d1bb9cda41e8bf; cd -;	#hostapd: add missing #ifdef to fix compile error when 802.11be support is disabled

git clone --branch master https://git01.mediatek.com/openwrt/feeds/mtk-openwrt-feeds || true
#cd mtk-openwrt-feeds; git checkout 0c7938bd11a6431517876310c3b78dfa59fd20c6; cd -;	#kernel-6.6][mt7988][eth][net: phy: mediatek: mtk-2p5ge: Change built-in 2.5Gphy firmware to internal version
cd mtk-openwrt-feeds; git checkout fd5a031d286bdf3fd67e1be0ce2f56c4196383e2; cd -;	#net: phy: mediatek: mtk-2p5ge: Add support for mt7987

# mtk autobuild rules modification - disable mtk gerrit
\cp -r my_files/rules mtk-openwrt-feeds/autobuild/unified

# wireless-regdb modification
#rm -rf openwrt/package/firmware/wireless-regdb/patches/*.*
#rm -rf mtk-openwrt-feeds/autobuild/unified/filogic/mac80211/24.10/files/package/firmware/wireless-regdb/patches/*.*
#\cp -r my_files/500-tx_power.patch mtk-openwrt-feeds/autobuild/unified/filogic/mac80211/24.10/files/package/firmware/wireless-regdb/patches
#\cp -r my_files/regdb.Makefile openwrt/package/firmware/wireless-regdb/Makefile

# jumbo frames support
#\cp -r my_files/750-mtk-eth-add-jumbo-frame-support-mt7998.patch openwrt/target/linux/mediatek/patches-6.6


#\cp -r my_files/733-11-wozi-net-phy-add-driver-for-built-in-2.5G-ethernet-PHY-on.patch openwrt/target/linux/mediatek/patches-6.6/733-11-net-phy-add-driver-for-built-in-2.5G-ethernet-PHY-on.patch
\cp -r my_files/3700-wozi-net-phy-add-driver-for-built-in-2.5G-ethernet-PHY-mk.patch mtk-openwrt-feeds/24.10/patches-base/

# tx_power patch
\cp -r my_files/99999_tx_power_check.patch mtk-openwrt-feeds/autobuild/unified/filogic/mac80211/24.10/files/package/kernel/mt76/patches/

# removing iperf issue
sed -i 's/CONFIG_PACKAGE_perf=y/# CONFIG_PACKAGE_perf is not set/' mtk-openwrt-feeds/autobuild/unified/filogic/mac80211/24.10/defconfig
sed -i 's/CONFIG_PACKAGE_perf=y/# CONFIG_PACKAGE_perf is not set/' mtk-openwrt-feeds/autobuild/autobuild_5.4_mac80211_release/mt7988_wifi7_mac80211_mlo/.config
sed -i 's/CONFIG_PACKAGE_perf=y/# CONFIG_PACKAGE_perf is not set/' mtk-openwrt-feeds/autobuild/autobuild_5.4_mac80211_release/mt7986_mac80211/.config

cd openwrt
bash ../mtk-openwrt-feeds/autobuild/unified/autobuild.sh filogic-mac80211-bpi-r4 log_file=make

exit 0

# thermal zone addition
\cp -r my_files/wozi-mt7988a.dtsi openwrt/target/linux/mediatek/files-6.6/arch/arm64/boot/dts/mediatek/mt7988a.dtsi

cd openwrt

# qmi modems extension
\cp -r ../my_files/luci-app-3ginfo-lite-main/sms-tool/ feeds/packages/utils/sms-tool
\cp -r ../my_files/luci-app-3ginfo-lite-main/luci-app-3ginfo-lite/ feeds/luci/applications
\cp -r ../my_files/luci-app-modemband-main/luci-app-modemband/ feeds/luci/applications
\cp -r ../my_files/luci-app-modemband-main/modemband/ feeds/packages/net/modemband
\cp -r ../my_files/luci-app-at-socat/ feeds/luci/applications

./scripts/feeds update -a
./scripts/feeds install -a

\cp -r ../configs/config.beta4.ext .config

make menuconfig
make -j$(nproc)


