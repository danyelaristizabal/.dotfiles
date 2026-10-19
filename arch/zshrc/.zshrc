if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH=/usr/share/oh-my-zsh

plugins=(git)
export ZSH=/usr/share/oh-my-zsh
export ZSH_POWER_LEVEL_THEME=/usr/share/zsh-theme-powerlevel10k

source $ZSH_POWER_LEVEL_THEME/powerlevel10k.zsh-theme
source $ZSH/oh-my-zsh.sh
DISABLE_AUTO_UPDATE="true"

# User configuration
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
export PATH=$PATH:$(go env GOPATH)/bin
export EDITOR=nvim
export ANTHROPIC_API_KEY=$(pass show anthropic)
export OLLAMA_HOST="localhost:8080"
export TERMINAL="wezterm"
export OPENAI_API_KEY=$(pass show openai)


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

# wlr-randr 
# sudo powerstat -d 0 -c -z
# lspci | grep -i nvidia
# envycontrol -q


alias battery-mode='bash ~/.local/bin/battery_mode.sh'
alias ac-mode='bash ~/.local/bin/ac_mode.sh'
alias hard-battery-mode='~/.local/bin/hard_battery_mode.sh'
alias hard-ac-mode='bash ~/.local/bin/hard_ac_mode.sh'
