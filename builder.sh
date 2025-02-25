#!/bin/bash

rm -rf openwrt
rm -rf mtk-openwrt-feeds

git clone --branch openwrt-24.10 https://git.openwrt.org/openwrt/openwrt.git openwrt || true
cd openwrt; git checkout 315facfce6dc13d6ec1993db1e16532cadcfcaaa; cd -;	#kernel: receive all bridged multicast packets if IFF_ALLMULTI is set


#cd openwrt; git checkout 68bf4844a1cbc9f404f6e93b70a2657e74f1dce9; cd -;	#realtek: debounce reset key for Zyxel GS1900
#cd openwrt; git checkout b7b6ae742440c41882d897e9798753dd3c122b5e; cd -;	#mt76: update to Git HEAD (2025-02-14)
#cd openwrt; git checkout 6ba1f831c7a20288eb0bf16767fc5a26f30cc8eb; cd -;	#mt76: update to Git HEAD (2025-01-04)
#cd openwrt; git checkout ea80aa938fc56a14b2fccecec41457aeee9e1647; cd -;	#wifi-scripts: add macaddr_base wifi-device option


git clone https://git01.mediatek.com/openwrt/feeds/mtk-openwrt-feeds || true
cd mtk-openwrt-feeds; git checkout b344dd022b2fbed57b6587c32d60009f9f51901d; cd -;	#Fix release build by adding wed patch

	
#cd mtk-openwrt-feeds; git checkout 42df09d4cf568c795e71427668fae0eea4f112c5; cd -;	#Update Filogic 880 Release Readme.
#cd mtk-openwrt-feeds; git checkout 90b73df21979a8d994b2b8fafa66d831faa53ebf; cd -;	#Add rootdisk in mt7988a-rfb-spim-nor.dtso
#cd mtk-openwrt-feeds; git checkout dae994e131612657ade07a8c0941d4299177e4ab; cd -;	#Fix build error because of wifi-script package
#cd mtk-openwrt-feeds; git checkout 47fd8068e3bcd23bb606c711ed50149b266f09af; cd -;	#Fix build fail due to wed3.1 support
#cd mtk-openwrt-feeds; git checkout 17c0b6a8ee48ef59e13527b713ebb2da6852440a; cd -;	#Update the backport base from OpenWrt one. (backports-6.12.6)


# mtk autobuild rules modification - disable mtk gerrit
\cp -r my_files/rules mtk-openwrt-feeds/autobuild/unified
PACKAGE_perf=y/# CONFIG_PACKAGE_perf is not set/' mtk-openwrt-feeds/autobuild/autobuild_5.4_mac80211_release/mt7986_mac80211/.config

cd openwrt
bash ../mtk-openwrt-feeds/autobuild/unified/autobuild.sh filogic-mac80211-bpi-r4 log_file=make

# thermal zone addition
#\cp -r my_files/w-mt7988a.dtsi openwrt/target/linux/mediatek/files-6.6/arch/arm64/boot/dts/mediatek/mt7988a.dtsi

\cp -r ../configs/config.basic .config

make -j$(nproc)


