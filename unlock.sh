#!/bin/bash

clear

echo -e "欢迎使用Miku Cloud脚本配置DNS解锁！"
echo -e ""

# Check if user is root
if [ "$(id -u)" -ne 0 ]; then
  echo "请使用root用户运行此脚本"
  exit 1
fi

# Check which OS the user is running
if [ -f /etc/debian_version ]; then
  OS="Debian"
elif [ -f /etc/centos-release ]; then
  OS="CentOS"
elif [ -f /etc/redhat-release ]; then
  OS="Red Hat"
else
  echo "不支持的系统，请您联系脚本作者"
  exit 1
fi

# Ask user if they want to enable DNS unlock
read -p "请问您是否启用DNS解锁? (y/n) " enable_dns
echo -e ""
if [ "$enable_dns" != "y" ] && [ "$enable_dns" != "Y" ]; then
  echo "脚本已退出，DNS解锁未被应用"
  exit 0
fi

# Ask user which region they want to unlock
echo -e "请问您想要解锁哪个地区？\n"
echo -e "| 地区 | 可解锁的流媒体 |\n|------|---------------|\n| 台湾 | Netflix, Dazn, Spotify, KKTV, LiTV, MyVideo, 4GTV.TV, LineTV.TW, Hami-Video, CatchPlay+, HBO GO Asia, Bahamut Anime |\n| 香港 | Dazn, Disney+, Netflix, Youtube, Viu.TV, MyTVSuper, HBO Go Asia, Bilibili |\n"
read -p "(请输入t或h) " dns_location
echo -e ""
if [ "$dns_location" != "t" ] && [ "$dns_location" != "T" ] && [ "$dns_location" != "h" ] && [ "$dns_location" != "H" ]; then
  echo "输入错误，脚本已退出，DNS解锁未被应用"
  exit 0
fi

# Backup resolv.conf file
cp /etc/resolv.conf /etc/resolv.conf.bak

# Remove dynamic resolv.conf file if it exists
if [ -f /etc/resolvconf/resolv.conf.d/original ]; then
  if [ "$OS" = "Debian" ] || [ "$OS" = "Ubuntu" ]; then
    apt-get remove --purge resolvconf -y
    # Do not delete /etc/resolv.conf file directly
    # Instead, delete the symbolic link and create a new one that points to the resolved.conf file created by systemd-resolved
    rm /etc/resolv.conf
    ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
  elif [ "$OS" = "CentOS" ] || [ "$OS" = "Red Hat" ]; then
    # Do not delete /etc/resolv.conf file directly
    # Instead, restore the backup file
    cp /etc/resolv.conf.bak /etc/resolv.conf
    rm /etc/resolvconf/resolv.conf.d/original
  fi
fi

# Change DNS servers based on user input
if [ "$dns_location" = "t" ] || [ "$dns_location" = "T" ]; then
  echo "nameserver 38.150.15.2" > /etc/resolv.conf
elif [ "$dns_location" = "h" ] || [ "$dns_location" = "H" ]; then
  echo "nameserver 10.10.10.10" > /etc/resolv.conf
fi

# Ask user if they want to undo the changes made by this script
read -p "您是否想要撤回DNS解锁操作? (y/n) " undo_changes
echo -e ""
if [ "$undo_changes" = "y" ] || [ "$undo_changes" = "Y" ]; then
  cp /etc/resolv.conf.bak /etc/resolv.conf
  echo "已撤回DNS解锁操作，脚本退出"
  exit 0
fi

echo "DNS解锁已更改至地区 $dns_location。 现在，您可以观看您选择的DNS本地的流媒体了！"
