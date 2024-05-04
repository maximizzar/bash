latest_release_api="https://api.github.com/repos/upscayl/upscayl/releases/latest"
latest_release_tag=$(wget -qO- "${latest_release_api}" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')

# Set correct architecture based on the System
case "$(uname -m)" in
x86_64)
        arch="linux"
        ;;
esac

# Download .deb file and install localsend
file_name="upscayl-$latest_release_tag-$arch.deb"
cd /tmp && wget --no-verbose --continue --show-progress --no-dns-cache --xattr --content-disposition "https://github.com/upscayl/upscayl/releases/download/v$latest_release_tag/$file_name"
sudo dpkg --install "$file_name"
