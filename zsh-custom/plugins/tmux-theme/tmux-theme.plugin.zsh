#!/usr/bin/env zsh
THEMEDIR="$HOME/.tmux-themepack"
THEMES=(
	"$THEMEDIR/default/green.tmuxtheme"
	"$THEMEDIR/default/blue.tmuxtheme"
	"$THEMEDIR/default/orange.tmuxtheme"
	"$THEMEDIR/default/red.tmuxtheme"
	"$THEMEDIR/default/magenta.tmuxtheme"
	"$THEMEDIR/default/yellow.tmuxtheme"
	"$THEMEDIR/default/cyan.tmuxtheme"
	"$THEMEDIR/default/gray.tmuxtheme"
	"$THEMEDIR/block/green.tmuxtheme"
	"$THEMEDIR/block/blue.tmuxtheme"
	"$THEMEDIR/block/orange.tmuxtheme"
	"$THEMEDIR/block/red.tmuxtheme"
	"$THEMEDIR/block/magenta.tmuxtheme"
	"$THEMEDIR/block/yellow.tmuxtheme"
	"$THEMEDIR/block/cyan.tmuxtheme"
	"$THEMEDIR/block/gray.tmuxtheme"
	"$THEMEDIR/double/green.tmuxtheme"
	"$THEMEDIR/double/blue.tmuxtheme"
	"$THEMEDIR/double/orange.tmuxtheme"
	"$THEMEDIR/double/red.tmuxtheme"
	"$THEMEDIR/double/magenta.tmuxtheme"
	"$THEMEDIR/double/yellow.tmuxtheme"
	"$THEMEDIR/double/cyan.tmuxtheme"
	"$THEMEDIR/.tmux-themepack/default.tmuxtheme"
	"$THEMEDIR/.tmux-themepack/basic.tmuxtheme"
)

function listthemes()
{
	for i in ${THEMES[@]}
	do
		awk -F/ '{ print $(NF-1), $NF }' <<< "$i" | cut -d. -f1
	done | sed '/^$/d'
}

function sourcetheme()
{
	echo "\$1 must be default/block/double"
	echo "\$2 must be green/blue/orange/red/magenta/yellow/cyan"
	if [ -f "$THEMEDIR/powerline/$1/$2.tmuxtheme" ]
	then
		echo "sourcing $THEMEDIR/$1/$2.tmuxtheme"
		tmux source-file $THEMEDIR/powerline/$1/$2.tmuxtheme
	else
		echo "not able to source $THEMEDIR/powerline/$1/$2.tmuxtheme"
	fi
}
