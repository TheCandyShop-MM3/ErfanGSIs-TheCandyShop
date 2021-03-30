#!/bin/bash

systempath=$1
romdir=$2
thispath=`cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd`

## System edits
# Copy system files
rsync -ra $thispath/system/ $systempath
# Remove libdolphin.so
rm -rf $1/lib64/libdolphin.so
# Drop caf permissions
rm -rf $1/etc/permissions/qti_permissions.xml
rm -rf $1/etc/permissions/com.qti.dpmframework.xml
# Drop qcom location
rm -rf $1/priv-app/com.qualcomm.location
# Remove Default GmsCore
rm -rf $1/product/priv-app/GmsCore

## SELinux
# Append file_context
cat $thispath/file_contexts >> $1/etc/selinux/plat_file_contexts
# enable logcat
sed -i "s/u:object_r:logcat_exec:s0/u:object_r:logd_exec:s0/g" $1/etc/selinux/plat_file_contexts
# cleanup plat_property
plat_property=$1/etc/selinux/plat_property_contexts
sed -i "/ro.opengles.version/d" $plat_property
sed -i "/sys.usb.configfs/d" $plat_property
sed -i "/sys.usb.controller/d" $plat_property
sed -i "/sys.usb.config/d" $plat_property
sed -i "/ro.build.fingerprint/d" $plat_property

# Warning for system ext
if [ -d "$1/system_ext/" ]; then
   echo "" >> $1/system_ext/build.prop
   echo "#################################" >> $1/system_ext/build.prop
   echo "# GSI made by: TheCandyShop.    #" >> $1/system_ext/build.prop
   echo "#                               #" >> $1/system_ext/build.prop
   echo "#################################" >> $1/system_ext/build.prop
fi

# Warning for Product
if [ -d "$1/product/" ]; then
   echo "" >> $1/product/build.prop
   echo "#################################" >> $1/product/build.prop
   echo "# GSI made by: TheCandyShop.    #" >> $1/product/build.prop
   echo "#                               #" >> $1/product/build.prop
   echo "#################################" >> $1/product/build.prop
fi

## Props
# Append props
cat $thispath/build.prop >> $1/build.prop
# Disable Actionable props
sed -i "/ro.actionable_compatible_property.enabled/d" $1/etc/prop.default
# disable any setupwizard mode
sed -i "/ro.setupwizard.mode/d" $1/etc/prop.default
sed -i "/ro.setupwizard.mode/d" $1/build.prop
sed -i "/ro.setupwizard.mode/d" $1/product/build.prop
echo "ro.setupwizard.mode=OPTIONAL" >> $1/etc/prop.default
echo "ro.setupwizard.mode=OPTIONAL" >> $1/product/build.prop
# Some adding in build.prop
sed -i "/sys.use_fifo_ui/d" $1/build.prop
sed -i "/debug.sf.latch_unsignaled/d" $1/build.prop
echo "sys.use_fifo_ui=1" >> $1/build.prop
echo "debug.sf.latch_unsignaled=1" >> $1/build.prop
# Dalvik fix
echo "# Dalvik fix" >> $1/build.prop
sed -i "/ro.sys.fw.dex2oat_thread_count/d" $1/build.prop
sed -i "/dalvik.vm.boot-dex2oat-threads/d" $1/build.prop
sed -i "/dalvik.vm.dex2oat-threads/d" $1/build.prop
sed -i "/dalvik.vm.image-dex2oat-threads/d" $1/build.prop
sed -i "/dalvik.vm.dex2oat-filter/d" $1/build.prop
sed -i "/dalvik.vm.heapgrowthlimit/d" $1/build.prop
sed -i "/dalvik.vm.heapstartsize/d" $1/build.prop
sed -i "/dalvik.vm.heapsize/d" $1/build.prop
sed -i "/dalvik.vm.heaptargetutilization/d" $1/build.prop
sed -i "/dalvik.vm.heapminfree/d" $1/build.prop
sed -i "/dalvik.vm.heapmaxfree/d" $1/build.prop
echo "ro.sys.fw.dex2oat_thread_count=4" >> $1/build.prop
echo "dalvik.vm.boot-dex2oat-threads=8" >> $1/build.prop
echo "dalvik.vm.dex2oat-threads=4" >> $1/build.prop
echo "dalvik.vm.image-dex2oat-threads=4" >> $1/build.prop
echo "dalvik.vm.dex2oat-filter=speed" >> $1/build.prop
echo "dalvik.vm.heapgrowthlimit=256m" >> $1/build.prop
echo "dalvik.vm.heapstartsize=8m" >> $1/build.prop
echo "dalvik.vm.heapsize=512m" >> $1/build.prop
echo "dalvik.vm.heaptargetutilization=0.75" >> $1/build.prop
echo "dalvik.vm.heapminfree=512k" >> $1/build.prop
echo "dalvik.vm.heapmaxfree=8m" >> $1/build.prop
# Disable vndk lite
echo "ro.vndk.lite=false" >> $1/etc/prop.default
echo "ro.vndk.lite=false" >> $1/product/build.prop
# disable RescureParty
echo "persist.sys.disable_rescue=true" >> $1/etc/prop.default
# disable privapp_permissions checking
echo "ro.control_privapp_permissions=disable" >> $1/etc/prop.default
echo "ro.control_privapp_permissions=disable" >> $1/product/build.prop
# fix vndk26 vold
sed -i "/reserved_disk/d" $1/etc/init/vold.rc
# Adb prop
sed -i "s/persist.sys.usb.config=none/persist.sys.usb.config=adb/g" $1/etc/prop.default
# Use qti Bluetooth lib if avaliable
if [ -f $1/lib64/libbluetooth_qti.so ]; then
    echo "ro.bluetooth.library_name=libbluetooth_qti.so" >> $1/build.prop
fi
# Disable adb secure
sed -i "s/ro.adb.secure=1/ro.adb.secure=0/" $1/etc/prop.default
# cleanup build prop
$thispath/../../scripts/propcleanner.sh $1/build.prop > $1/../../build.prop
cp -fpr $1/../../build.prop $1/


## Append to phh script
cat $thispath/rw-system.add.sh >> $1/bin/rw-system.sh

## Nitrogen Specific

echo 'qemu.hw.mainkeys=0' >> $1/build.prop
echo 'ro.boot.vendor.overlay.theme=me.rsyhan.notch.killer' >> $1/build.prop
echo 'ro.sf.lcd_density=380' >> $1/build.prop
echo "# OpenGL version" >> $1/build.prop
echo "ro.opengles.version=196610" >> $1/build.prop

echo "" >> $1/build.prop
echo "# System props for telephony" >> $1/build.prop
echo "# System prop to turn on CdmaLTEPhone always" >> $1/build.prop
echo "telephony.lteOnCdmaDevice=1,1" >> $1/build.prop
echo "telephony.CdmaOnGsmDevice=1,1" >> $1/build.prop
echo "#" >> $1/build.prop
echo "# Debug options" >> $1/build.prop
echo "persist.dbg.ims_volte_enable=1" >> $1/build.prop
echo "persist.dbg.volte_avail_ovr=1" >> $1/build.prop
echo "persist.dbg.vt_avail_ovr=1" >> $1/build.prop
echo "persist.dbg.wfc_avail_ovr=1" >> $1/build.prop
echo "#" >> $1/build.prop
echo "# Radio options" >> $1/build.prop
echo "persist.radio.rat_on=combine" >> $1/build.prop
echo "persist.radio.data_ltd_sys_ind=1" >> $1/build.prop
echo "persist.radio.data_cond_rprt=1" >> $1/build.prop
echo "persist.radio.call.on.ims=1" >> $1/build.prop
echo "ril.subscription.types=RUIM,RUIM" >> $1/build.prop
echo "DEVICE_PROVISIONED=1" >> $1/build.prop
echo "persist.vendor.data.mode=concurrent" >> $1/build.prop
echo "ro.config.ringtone=Orion.ogg" >> $1/product/build.prop
echo "ro.config.alarm_alert=Hassium.ogg" >> $1/product/build.prop
echo "ro.config.notification_sound=Argon.ogg" >> $1/product/build.prop

# Manufacturer and Model Edit
echo "# Dalvik fix" >> $1/build.prop
sed -i "/ro.product.system.brand/d" $1/build.prop
sed -i "/ro.product.system.device/d" $1/build.prop
sed -i "/ro.product.system.manufacturer/d" $1/build.prop
sed -i "/ro.product.system.model/d" $1/build.prop
sed -i "/ro.build.product/d" $1/build.prop
sed -i "/ro.product.system_ext.brand/d" $1/system_ext/build.prop
sed -i "/ro.product.system_ext.device/d" $1/system_ext/build.prop
sed -i "/ro.product.system_ext.manufacturer/d" $1/system_ext/build.prop
sed -i "/ro.product.system_ext.model/d" $1/system_ext/build.prop
sed -i "/ro.product.product.brand/d" $1/product/build.prop
sed -i "/ro.product.product.device/d" $1/product/build.prop
sed -i "/ro.product.product.manufacturer/d" $1/product/build.prop
sed -i "/ro.product.product.model/d" $1/product/build.prop
echo "ro.product.system.brand=xiaomi" >> $1/build.prop
echo "ro.product.system.device=nitrogen" >> $1/build.prop
echo "ro.product,system.manufacturer=xiaomi" >> $1/build.prop
echo "ro.product.system.model=Mi Max 3" >> $1/build.prop
echo "ro.build.product=nitrogen" >> $1/build.prop
echo "ro.product.system_ext.brand=xiaomi" >> $1/system_ext/build.prop
echo "ro.product.system_ext.device=nitrogen" >> $1/system_ext/build.prop
echo "ro.product.system_ext.manufacturer=nitrogen" >> $1/system_ext/build.prop
echo "ro.product.system_ext.model=Mi Max 3" >> $1/system_ext/build.prop
echo "ro.product.product.brand=xiaomi" >> $1/product/build.prop
echo "ro.product.product.device=nitrogen" >> $1/product/build.prop
echo "ro.product.product.manufacturer=xiaomi" >> $1/product/build.prop
echo "ro.product.product.model=Mi Max 3" >> $1/product/build.prop

echo 'net.tcp.buffersize.default=4096,87380,256960,4096,16384,256960' >> $1/build.prop
echo 'net.tcp.buffersize.wifi=4096,87380,256960,4096,16384,256960' >> $1/build.prop
echo 'net.tcp.buffersize.lte=524288,1048576,2097152,524288,1048576,2097152' >> $1/build.prop
echo "persist.cust.tel.eons=1" >> $1/build.prop
echo "telephony.lteOnCdmaDevice=1" >> $1/build.prop
echo "wifi.supplicant_scan_interval=180" >> $1/build.prop

#remove forced gestural so notch killer works

sed -i "/ro.boot.vendor.overlay.theme/d" $1/product/build.prop
sed -i "/persist.bluetooth.bluetooth_audio_hal.disabled/d" $1/build.prop
sed -i "/ro.treble.enabled/d" $1/build.prop
sed -i "/ro.system.build.fingerprint/d" $1/build.prop

echo "ro.system.build.fingerprint=Xiaomi/nitrogen/nitrogen:10/QKQ1.190910.002/20.9.4:user/release-keys" >> $1/build.prop
sed -i "/org.evolution.build_maintainer/d" $1/build.prop
echo "org.evolution.build_maintainer=SpyderMahn" >> $1/build.prop
sed -i "/ro.corvus.maintainer/d" $1/build.prop
echo "ro.corvus.maintainer=SpyderMahn" >> $1/build.prop
sed -i "/ro.dot.device/d" $1/build.prop
echo "ro.dot.device=nitrogen" >> $1/build.prop
sed -i "/ro.dot.maintainer/d" $1/build.prop
echo "ro.dot.maintainer=SpyderMahn" >> $1/build.prop
sed -i "/ro.crdroid.device/d" $1/build.prop
echo "ro.crdroid.device=nitrogen" >> $1/build.prop
sed -i "/ro.lineage.device/d" $1/build.prop
echo "ro.lineage.device=nitrogen" >> $1/build.prop
sed -i "/ro.derp.device/d" $1/build.prop
echo "ro.derp.device=nitrogen" >> $1/build.prop
sed -i "/ro.product.system.name/d" $1/build.prop
echo "ro.product.system.name=nitrogen" >> $1/build.prop
