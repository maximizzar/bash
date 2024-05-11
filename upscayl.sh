if ! [ -n "$DISPLAY" ] || [ "$1" ]; then
  latest_release_api="https://api.github.com/repos/upscayl/upscayl-ncnn/releases/latest"
  latest_release_tag=$(wget -qO- "${latest_release_api}" | grep -oP '(?<="tag_name": ")[^"]+' | sed -E 's/.*"v([^"]+)".*/\1/')

  # Set correct architecture based on the System
  case "$(uname -m)" in
  x86_64)
          arch="linux"
          ;;
  esac

  file_name="upscayl-bin-$latest_release_tag-$arch"
  cd /tmp && wget --no-verbose --continue --show-progress --no-dns-cache --xattr --content-disposition "https://github.com/upscayl/upscayl-ncnn/releases/download/$latest_release_tag/$file_name.zip"
  unzip -qq "$file_name.zip" && cd "$file_name" || exit 1
  mv upscayl-bin /usr/local/bin/upscayl
  chmod +x /usr/local/bin/upscayl
  exit 0
fi
latest_release_api="https://api.github.com/repos/upscayl/upscayl/releases/latest"
latest_release_tag=$(wget -qO- "${latest_release_api}" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')

# Set correct architecture based on the System
case "$(uname -m)" in
x86_64)
        arch="linux"
        ;;
esac

# Download .deb file and install upscayl
file_name="upscayl-$latest_release_tag-$arch.deb"
cd /tmp && wget --no-verbose --continue --show-progress --no-dns-cache --xattr --content-disposition "https://github.com/upscayl/upscayl/releases/download/v$latest_release_tag/$file_name"
sudo dpkg --install "$file_name"
