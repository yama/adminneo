#!/bin/bash
#
# AdminNeo Installer Script (theme color variants enabled)
# ===========================================================================
#
# This script installs AdminNeo or EditorNeo - database management interfaces.
#
# Download and run in one step:
#
#    $ wget -O - https://www.adminneo.org/get-adminneo.sh | bash
#
# The script will guide you through the following options:
#  - Project selection (AdminNeo or EditorNeo)
#  - Version selection
#  - Database driver selection
#  - Language preferences
#  - Theme selection
#  - Output filename
#
# Press Ctrl+C at any time to exit the script.
#
# ===========================================================================

set -e

# パイプ経由でも対話入力できるようにするための設定
exec < /dev/tty

# Color definitions
YELLOW='\033[0;33m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Function to print separator
print_separator() {
  echo -e "${YELLOW}-----------------------------------------------${NC}"
}

print_separator
echo -e "${BOLD}=== Select Project ===${NC}"
echo -e "1) AdminNeo [default]"
echo -e "2) EditorNeo"
read -p "Type 1 or 2 and press Enter [1]: " project_num
project_num=${project_num:-1}
if [ "$project_num" = "2" ]; then project="EditorNeo"; else project="AdminNeo"; fi

print_separator
echo -e "${BOLD}=== Version ===${NC}"
read -p "Enter version (leave blank for latest): " version
version=${version:-latest}

print_separator
echo -e "${BOLD}=== Select Database Drivers ===${NC}"
echo -e "1) mysql [default]"
echo -e "2) pgsql"
echo -e "3) mssql"
echo -e "4) sqlite"
echo -e "5) oracle"
echo -e "6) simpledb"
echo -e "7) elasticsearch"
echo -e "8) mongodb"
echo -e "9) clickhouse"
echo -e "0) all drivers"
read -p "Type numbers (comma-separated, e.g. 1,3) [1]: " drivers_num
drivers_num=${drivers_num:-1}
driver_names=("mysql" "pgsql" "mssql" "sqlite" "oracle" "simpledb" "elasticsearch" "mongodb" "clickhouse")
driver_path=""

# すべてのドライバーを選択する場合
if [[ $drivers_num == "0" ]]; then
  driver_path="" # 空文字列にしてURLから省略
else
  # 特定のドライバーを選択する場合
  IFS=',' read -ra dnums <<< "$drivers_num"
  for d in "${dnums[@]}"; do
    idx=$((d-1))
    if [ $idx -ge 0 ] && [ $idx -lt 9 ]; then
      driver_path+="${driver_names[$idx]},"
    fi
  done
  driver_path=${driver_path%,}
fi

print_separator
echo -e "${BOLD}=== Language selection mode ===${NC}"
echo -e "1) all [default]"
echo -e "2) custom"
read -p "Type 1 or 2 and press Enter [1]: " lang_mode_num
lang_mode_num=${lang_mode_num:-1}
if [ "$lang_mode_num" = "2" ]; then
  read -p "Enter languages (comma-separated, e.g. en,ja,fr): " lang
  lang=${lang:-en}
else
  lang="all"
fi

print_separator
echo -e "${BOLD}=== Theme selection ===${NC}"
echo -e "Note: Most installations should use 'default' (includes all colors)."
echo -e "Specifying a color (e.g., 'default-blue') may result in a 404 error if not available on the server."
echo
echo -e "  1) default [recommended, all colors included]"
echo -e "  2) default-blue"
echo -e "  3) default-green"
echo -e "  4) default-red"
read -p "Type 1-4 and press Enter [1]: " theme_num
theme_num=${theme_num:-1}
theme_names=("default" "default-blue" "default-green" "default-red")
theme=${theme_names[$((theme_num-1))]}

default_filename_option=1
print_separator
echo -e "${BOLD}=== Select output filename ===${NC}"
echo -e "1) adminneo.php [default]"
echo -e "2) adminer.php"
echo -e "3) Custom filename"
read -p "Type 1-3 and press Enter [1]: " filename_option
filename_option=${filename_option:-$default_filename_option}
if [ "$filename_option" = "2" ]; then
  outfilename="adminer.php"
elif [ "$filename_option" = "3" ]; then
  read -p "Enter output filename (e.g. mydb.php): " outfilename
  outfilename=${outfilename:-adminneo.php}
else
  outfilename="adminneo.php"
fi

filename="${project,,}-${version}.php"

# 特殊なケースの URL パス構築
if [ -z "$driver_path" ]; then
  # すべてのドライバーの場合
  if [ "$lang" = "all" ] && [ "$theme" = "default" ]; then
    # すべてのドライバー、すべての言語、デフォルトテーマ
    url="https://www.adminneo.org/files/$version/__/$filename"
  elif [ "$lang" = "all" ]; then
    # すべてのドライバー、すべての言語、特定のテーマ
    url="https://www.adminneo.org/files/$version/_${lang}_${theme}/$filename"
  elif [ "$theme" = "default" ]; then
    # すべてのドライバー、特定の言語、デフォルトテーマ
    url="https://www.adminneo.org/files/$version/_${lang}_/$filename"
  else
    # すべてのドライバー、特定の言語、特定のテーマ
    url="https://www.adminneo.org/files/$version/_${lang}_${theme}/$filename"
  fi
else
  # 特定のドライバーの場合
  if [ "$lang" = "all" ] && [ "$theme" = "default" ]; then
    # 特定のドライバー、すべての言語、デフォルトテーマ
    url="https://www.adminneo.org/files/$version/${driver_path}__/$filename"
  elif [ "$lang" = "all" ]; then
    # 特定のドライバー、すべての言語、特定のテーマ
    url="https://www.adminneo.org/files/$version/${driver_path}_${lang}_${theme}/$filename"
  elif [ "$theme" = "default" ]; then
    # 特定のドライバー、特定の言語、デフォルトテーマ
    url="https://www.adminneo.org/files/$version/${driver_path}_${lang}_/$filename"
  else
    # 特定のドライバー、特定の言語、特定のテーマ
    url="https://www.adminneo.org/files/$version/${driver_path}_${lang}_${theme}/$filename"
  fi
fi

echo

print_separator
echo -e "${BOLD}--- Summary ---${NC}"
echo -e "Project:         $project"
echo -e "Version:         $version"
echo -e "Drivers:         $driver_path"
echo -e "Languages:       $lang"
echo -e "Theme:           $theme"
echo -e "Download URL:    $url"
echo -e "Output filename: $outfilename"
print_separator
echo
read -p "Proceed to download? [Y/n]: " confirm
yesno=${confirm:-Y}
if [[ $yesno =~ ^[Yy]$ ]]; then
  wget -O "$outfilename" "$url"
  if [ $? -eq 0 ]; then
    echo -e "Download complete: $outfilename"
  else
    echo -e "Download failed. Please check the URL or your network."
    echo -e "Error URL: $url"
    echo -e "Note: If you're using 'all' languages or 'default' theme and getting 404 errors,"
    echo -e "      try a specific language (e.g., 'en') or theme option."
  fi
else
  echo -e "Download canceled."
fi
