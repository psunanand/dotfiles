# Antidote zsh plugin manager
# See: https://antidote.sh/install

# Set zsh plugin file/directory paths
export ANTIDOTE_HOME="${ANTIDOTE_HOME:-$XDG_CACHE_HOME}"/antidote

# Clone Antidote if not found
[[ -d "${ANTIDOTE_HOME}" ]] || git clone --depth 1 --quiet https://github.com/mattmc3/antidote "${ANTIDOTE_HOME}"

# Lazy load Antidote functions
fpath=("${ANTIDOTE_HOME}"/functions "$fpath")
autoload -Uz antidote

# Generate an Antidote static file whenever .zplugins is updated.
zplugins="${ZDOTDIR}"/.zplugins
if [[ ! ${zplugins}.zsh -nt ${zplugins} ]] || [[ ! -e "$ANTIDOTE_HOME"/.lastupdated ]]; then
    antidote bundle <${zplugins} >|${zplugins}.zsh
    date +%Y-%m-%dT%H:%M:%S%z >| "$ANTIDOTE_HOME"/.lastupdated
fi

source "${zplugins}".zsh
