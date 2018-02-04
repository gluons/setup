YELLOW='\033[1;33m'
GREEN='\033[1;32m'
NC='\033[0m'

# My dotfiles
echo "${YELLOW}Installing my dotfiles...${NC}"
mkdir -p "$HOME/my-projects"
git clone https://github.com/gluons/dotfiles.git "$HOME/my-projects/dotfiles"
echo "source ~/my-projects/dotfiles/.profile" >> ~/.zprofile
# Dot files on home
ln -sf "$HOME/my-projects/dotfiles/.editorconfig" "$HOME/.editorconfig"
ln -sf "$HOME/my-projects/dotfiles/.eslintrc.json" "$HOME/.eslintrc.json"
## Owner
CURRENT_USER=$(who | awk '{print $1}') # Real current user while using sudo. See https://unix.stackexchange.com/a/304761/221509
sudo chown -R $CURRENT_USER: "$HOME/my-projects/dotfiles"
sudo chown $CURRENT_USER: "$HOME/.zprofile"
sudo chown -h $CURRENT_USER: "$HOME/.editorconfig"
sudo chown -h $CURRENT_USER: "$HOME/.eslintrc.json"
## Permission
sudo find "$HOME/my-projects/dotfiles" -type f -exec chmod 664 {} +
sudo find "$HOME/my-projects/dotfiles" -type d -exec chmod 775 {} +
sudo chmod 664 "$HOME/.zprofile"
## Change repo remote url
dotfiles_url='git@github.com:gluons/dotfiles.git'
su - $CURRENT_USER -c "cd \"$HOME/my-projects/dotfiles\" && git remote set-url origin $dotfiles_url" # Perform as real current user
cd

# Oh My Zsh
echo "\n${YELLOW}Installing Oh My Zsh...${NC}"
sudo apt-get install zsh -y -qq --show-progress
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# zsh-syntax-highlighting
echo "\n${YELLOW}Installing zsh-syntax-highlighting...${NC}"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# zsh-autosuggestions
echo "\n${YELLOW}Installing zsh-autosuggestions...${NC}"
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# nvm
echo "\n${YELLOW}Installing nvm...${NC}"
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.8/install.sh | bash

# rbenv
echo "\n${YELLOW}Installing rbenv...${NC}"
sudo apt-get install gcc -y -qq
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
cd ~/.rbenv && src/configure && make -C src || true
cd
echo '' >> ~/.zshrc
echo '# rbenv' >> ~/.zshrc
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(rbenv init -)"' >> ~/.zshrc
## rbenv ruby-build
mkdir -p "$(~/.rbenv/bin/rbenv root)"/plugins
git clone https://github.com/rbenv/ruby-build.git "$(~/.rbenv/bin/rbenv root)"/plugins/ruby-build
PATH="$HOME/.rbenv/bin:$PATH" # Temporary set path for rbenv-doctor
eval "$(rbenv init -)" # Load rbenv shims
echo "\n${YELLOW}Running rbenv-doctor...${NC}"
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-doctor | bash # Verify rbenv

# Fonts
if [ ! -d "$HOME/.local/share/fonts" ]; then
	mkdir -p ~/.local/share/fonts
fi
## Fira Mono
echo "\n${YELLOW}Installing Fira Mono font...${NC}"
for type in Bold Medium Regular; do
	wget -q --show-progress --progress=bar -O ~/.local/share/fonts/FiraMono-${type}.ttf \
	"https://github.com/mozilla/Fira/blob/master/otf/FiraMono-${type}.otf?raw=true";
done
## Fira Code
echo "\n${YELLOW}Installing Fira Code font...${NC}"
for type in Bold Light Medium Regular Retina; do
	wget -q --show-progress --progress=bar -O ~/.local/share/fonts/FiraCode-${type}.ttf \
	"https://github.com/tonsky/FiraCode/blob/master/distr/ttf/FiraCode-${type}.ttf?raw=true";
done
## Powerline fonts
echo "\n${YELLOW}Installing Powerline fonts...${NC}"
git clone https://github.com/powerline/fonts.git "powerline-fonts" --depth=1
cd powerline-fonts
./install.sh
cd .. && rm -rf powerline-fonts
fc-cache -f # Clean & rebuild font cache

# VS Code
echo "\n${YELLOW}Installing VS Code...${NC}"
curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt-get update && sudo apt-get install code -y -q --show-progress

# Ensure downloads directory exists
if [ ! -d "$HOME/Downloads" ]; then
	mkdir -p "$HOME/Downloads"
fi

# Discord
echo "\n${YELLOW}Installing Discord...${NC}"
curl -fL# "https://discordapp.com/api/download?platform=linux&format=deb" -o ~/Downloads/discord.deb
sudo dpkg -i ~/Downloads/discord.deb
rm ~/Downloads/discord.deb # Clean up

# Hyper
echo "\n${YELLOW}Installing Hyper...${NC}"
curl -fL# "https://releases.hyper.is/download/deb" -o ~/Downloads/hyper.deb
sudo dpkg -i ~/Downloads/hyper.deb
rm ~/Downloads/hyper.deb # Clean up

# Spotify
echo "\n${YELLOW}Installing Spotify...${NC}"
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0DF731E45CE24F27EEEB1450EFDC8610341D9410
echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list
sudo apt-get update && sudo apt-get install spotify-client -y -q --show-progress

echo "\n${GREEN}Done.${NC}"
