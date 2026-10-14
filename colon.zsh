# colon: `: question` asks Claude about the command you just ran, inline.
# Source this near the top of ~/.zshrc (see README.md).

typeset -g _COLON_BIN=${0:A:h}/bin/colon

# In a terminal, restart this shell under the colon pty so `:` can see command output.
# Near the top of .zshrc, so the shell that gets replaced has done little work.
if [[ -z $COLON_SOCK && -t 0 && -t 1 && -x $_COLON_BIN ]] && (( $+commands[python3] )); then
  exec "$_COLON_BIN" shell "${commands[zsh]:-zsh}"
fi

# The restarted shell is not the one Ghostty set up, so load Ghostty's integration by hand.
[[ -n $COLON_SOCK && -n $GHOSTTY_RESOURCES_DIR ]] &&
  builtin source "$GHOSTTY_RESOURCES_DIR/shell-integration/zsh/ghostty-integration"

typeset -g _COLON_SID= _COLON_STARTED= _COLON_CMD= _COLON_CODE=0 _COLON_RUN=0

# Mark where each command's output starts (C) and ends (D); the pty keeps only what is between.
_colon_preexec() { _COLON_CMD=$1 _COLON_RUN=1; print -n '\e]133;C\a' }
_colon_precmd() {
  local code=$?
  (( _COLON_RUN )) || return
  _COLON_RUN=0 _COLON_CODE=$code
  print -n "\e]133;D;$code\a"
}
autoload -Uz add-zsh-hook
add-zsh-hook preexec _colon_preexec
precmd_functions=(_colon_precmd $precmd_functions)  # first, so $? is still the command's

# `: question` asks; `:new` starts a fresh session. Anything else is a normal Enter.
_colon_accept_line() {
  [[ $BUFFER == ': '* || $BUFFER == ':new' ]] || { zle accept-line; return }
  local q=${BUFFER#:} fix=$(mktemp)
  print -s -- "$BUFFER"
  print
  if [[ $q == new ]]; then
    _COLON_SID= _COLON_STARTED=
    print -P '%F{8}new session%f'
  else
    [[ -n $_COLON_SID ]] || _COLON_SID=$(uuidgen | tr A-Z a-z)
    local -a args=(--session $_COLON_SID --suggest $fix)
    [[ -n $_COLON_STARTED ]] && args+=(--resume)
    [[ -n $_COLON_CMD ]] && args+=(--cmd "$_COLON_CMD" --code $_COLON_CODE)
    "$_COLON_BIN" ask $args -- "${q# }" && _COLON_STARTED=1
    _COLON_CMD=  # later questions are follow-ups until another command runs
  fi
  BUFFER=$(<$fix) CURSOR=${#BUFFER}  # a suggested fix, ready to run
  rm -f $fix
  zle -I
  zle reset-prompt
}
zle -N _colon_accept_line
bindkey '^M' _colon_accept_line
bindkey '^J' _colon_accept_line
