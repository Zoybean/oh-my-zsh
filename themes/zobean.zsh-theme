# Title:        Zobean's zsh theme!
# Author:       Zoey Llewellyn "Zobean" Hewll
# Last Edited:  2016-08-19
# Features:     running clock, including date and time
#               colorised exit status indicator
#               colorised git status indicator
#               full logical path, colored for convenience
#               ssh/scp path format user@hostname:path
#               polite command prompt, with customisable title
# Notes:        Enjoy your stay!
#               Let me know of any improvements!
#               (the actual code is pretty hacky)

# Title Customisation {{{
#_PROMPT_USER_TITLE="$(id --user --name)" # same as $USER
#_PROMPT_USER_TITLE="mistress"
_PROMPT_USER_TITLE="princess"
#_PROMPT_USER_TITLE="my queen"
#_PROMPT_USER_TITLE="your highness"
# }}}
# Body {{{
setopt PROMPT_SUBST

# Update the prompt per-second
TMOUT=1
TRAPALRM() {
	zle reset-prompt
}

# Git status in prompt
ZSH_THEME_GIT_PROMPT_PREFIX="%B%F{blue}git:(%F{red}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%f%b"
ZSH_THEME_GIT_PROMPT_DIRTY="%F{yellow}*%F{blue})"
ZSH_THEME_GIT_PROMPT_CLEAN="%F{blue})"

# Keep up to the last directory in path
# Functional counterpart to zsh's '%1/' prompt expansion
pwd_path() {
	pwd | sed -E 's://+:/:g;s:[^/]+/?$::;s:^/$::'
} 
# Keep only the last directory in path
# Functional counterpart to zsh's '%1/' prompt expansion
pwd_dir() {
	pwd | sed -E 's://+:/:g;s:.*/([^/]+)/?:\1:'
} 

precmd_prompt() {
	local ERRCOL="%(?:%F{green}:%F{red})"

	# There is an easier way to do this, using sed, but I can't be bothered. Zsh expansion is convenient-ish
	# Match all zsh-style formatting strings. Not great.
	local RAW_NOG='%([BSUbfksu]|[FK]{*})' #non-greedy match - for when %F or %K is followed by {}
	local RAW_GRE='%([FK])'               #greedy match - for the other case. no following {}
	
	local DATE_STAMP="${(%%):-%D{%H:%M:%S\}}" #"}"#weird formatting. ew
	local PROMPT_LEFT0="${ERRCOL}[%F%B${DATE_STAMP}%b${ERRCOL}]%f " # finish time of last command
	local PROMPT_LEFT1="%F%B[%D{%H:%M:%S}]%b%f " # start time of this command (current time)
	local PROMPT_LEFT="${PROMPT_LEFT0}${PROMPT_LEFT1}"
	local PROMPT_RIGHT="%F%D{%Y-%m-%d}%f"
	local PROMPT_GIT="$(git_prompt_info)"
	local BARE_LEFT="${${(S)PROMPT_LEFT//$~RAW_NOG}//$~RAW_GRE}"
	local BARE_RIGHT="${${(S)PROMPT_RIGHT//$~RAW_NOG}//$~RAW_GRE}"
	local BARE_GIT="${${(S)PROMPT_GIT//$~RAW_NOG}//$~RAW_GRE}"
	
	# Calculate the padding required to right-pad the date
	local MIDDLE_WIDTH="$((${COLUMNS}-3-${#:-${(%):-$BARE_LEFT$BARE_RIGHT$BARE_GIT}}))" #must be one less, as rprompt sits one from the end of the screen
	local PROMPT_MIDDLE="$PROMPT_GIT${(r:$MIDDLE_WIDTH:: :)}"

	RPROMPT=''
	PROMPT="${PROMPT_LEFT}${PROMPT_MIDDLE}${PROMPT_RIGHT}"
	PROMPT+=$'\n%F{green}%n%f@%F{yellow}%M%f:%F{blue}$(pwd_path)%B$(pwd_dir)%b%f'
	PROMPT+=$'\n%F{magenta}yes, %B'"${_PROMPT_USER_TITLE}"'%b%F{magenta}?%f : '
}
precmd_functions+=(precmd_prompt)
# }}}
# Postamble {{{
# This is specifically to allow for cool vim folding.
# Note: 'modelines' should be at least the distance
# of the modeline from the top or bottom of the file
# Update: I have no idea how this following line works
set modeline modelines=5
# Modeline to enable marker-based folding, and ensure zsh syntax coloring
# vim:foldmethod=marker:filetype=zsh:
#  }}}
