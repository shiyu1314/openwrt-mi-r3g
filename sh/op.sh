#!/bin/bash


function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../
  cd .. && rm -rf $repodir
}

echo 'src-git xd https://github.com/shiyu1314/openwrt-packages' >>feeds.conf.default

git_sparse_clone $REPO_BRANCH https://github.com/immortalwrt/immortalwrt package/utils/mhz
git_sparse_clone $REPO_BRANCH https://github.com/immortalwrt/immortalwrt package/network/services/dnsmasq
git_sparse_clone $REPO_BRANCH https://github.com/immortalwrt/luci modules/luci-base
git_sparse_clone $REPO_BRANCH https://github.com/immortalwrt/luci modules/luci-mod-status
git_sparse_clone master https://github.com/kiddin9/openwrt-packages luci-app-syncdial

git clone -b master --depth 1 --single-branch https://github.com/jerrykuku/luci-theme-argon package/xd/luci-theme-argon

curl -sSL https://raw.githubusercontent.com/chenmozhijin/turboacc/luci/add_turboacc.sh -o add_turboacc.sh && bash add_turboacc.sh

./scripts/feeds update -a
rm -rf feeds/packages/net/v2ray-geodata
rm -rf feeds/packages/net/mosdns
rm -rf feeds/luci/applications/luci-app-dockerman
rm -rf feeds/luci/modules/luci-base
rm -rf feeds/luci/modules/luci-mod-status
rm -rf package/network/services/dnsmasq
cp -rf luci-app-syncdial package
cp -rf mhz package/utils/
cp -rf luci-base feeds/luci/modules
cp -rf luci-mod-status feeds/luci/modules/
cp -rf dnsmasq package/network/services/

./scripts/feeds update -a
./scripts/feeds install -a

sed -i "s/192.168.1.1/$OP_IP/" package/base-files/files/bin/config_generate
sed -i "s/hostname='.*'/hostname='$name'/g" ./package/base-files/files/bin/config_generate
sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config

sudo rm -rf package/base-files/files/etc/banner

sed -i "s/%D %V %C/%D $(TZ=UTC-8 date +%Y.%m.%d)/" package/base-files/files/etc/openwrt_release

sed -i "s/%R/by $OP_author/" package/base-files/files/etc/openwrt_release

date=$(date +"%Y-%m-%d")
echo "                                                    " >> package/base-files/files/etc/banner
echo "  _______                     ________        __" >> package/base-files/files/etc/banner
echo " |       |.-----.-----.-----.|  |  |  |.----.|  |_" >> package/base-files/files/etc/banner
echo " |   -   ||  _  |  -__|     ||  |  |  ||   _||   _|" >> package/base-files/files/etc/banner
echo " |_______||   __|_____|__|__||________||__|  |____|" >> package/base-files/files/etc/banner
echo "          |__|" >> package/base-files/files/etc/banner
echo " -----------------------------------------------------" >> package/base-files/files/etc/banner
echo "         %D ${date} by $OP_author                     " >> package/base-files/files/etc/banner
echo " -----------------------------------------------------" >> package/base-files/files/etc/banner
