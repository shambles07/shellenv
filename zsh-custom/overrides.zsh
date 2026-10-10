# Local tweaks to oh-my-zsh plugins.
#
# oh-my-zsh sources $ZSH_CUSTOM/*.zsh after loading plugins, so these replace
# the edits that used to be made directly inside .oh-my-zsh/plugins/*. That keeps
# the .oh-my-zsh submodule pristine and updatable.

# common-aliases: `t` is a function in ~/.zsh_functions; an alias of the same
# name would break its definition.
unalias t 2>/dev/null

# git
if (( ${plugins[(Ie)git]} )); then
  alias gsur='git submodule update --remote'
fi

# yum / debian: install without prompting
if (( ${plugins[(Ie)yum]} )); then
  alias yii='sudo yum -y install'
fi
if (( ${plugins[(Ie)debian]} )) && [[ $use_sudo -eq 1 ]]; then
  alias aii="sudo $apt_pref -y install"
fi

# tmux: keep the plugin's aliases (ta, ts, tl, ...) but run tmux directly
if (( ${plugins[(Ie)tmux]} )); then
  unalias tmux 2>/dev/null
fi

# globalias: only expand when the word left of the cursor looks like a global
# alias (all caps/digits, e.g. `H`, `RNS`, `VLA`), not on every space.
if (( ${plugins[(Ie)globalias]} )); then
  globalias() {
    if [[ $LBUFFER =~ ' [A-Z0-9]+$' ]]; then
      zle _expand_alias
      zle expand-word
    fi
    zle self-insert
  }
fi
