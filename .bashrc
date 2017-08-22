. ~/.bash/uname/$(uname).sh

# aliases
alias md='mkdir -p'
alias rd='rm -rf'
alias shred='shred -n 255 -u -z'

# functions
function cdb()
{
    pushd .

    OLDCDPATH=${CDPATH}

    while [ ! -f settings.gradle -a "${PWD}" != "/" ]
    do
        cd .. >/dev/null 2>&1
    done

    if [ -f settings.gradle ]
    then
        CDPATH=${PWD}:${CDPATH}

        if [ -n "$1" ]
        then
            d=$1
        else
            d=-
        fi
    else
      d=~
    fi

    popd

    cd $d

    CDPATH=${OLDCDPATH}
}

function cdg()
{
    cd "$(git rev-parse --show-toplevel)"
}

function cdw()
{
    pushd .

    OLDCDPATH=${CDPATH}

    while [ ! -f .workspace -a "${PWD}" != "/" ]
    do
        cd .. >/dev/null 2>&1
    done

    if [ -f .workspace ]
    then
        CDPATH=${PWD}:${CDPATH}

        if [ -n "$1" ]
        then
            d=$1
        else
            d=-
        fi
    else
    	  d=~
    fi

    popd

    cd $d

    CDPATH=${OLDCDPATH}
}

create-grpc-project() {
    ~/bin/create-grpc-project "$@"

    cd "${!#}"
}

create-workspace() {
    for v in "$@"
    do
        case ${v} in
            --pr=*)
                pr=${v/--pr=/}
                ;;
            --repo=*)
                repo=${v/--repo=/}
                ;;
        esac
    done

    ~/bin/create-workspace "$@"

    case "${!#}" in
        --*=*)
            wd="${repo}.pr-${pr}"
            ;;
        *)
            wd="${!#}"
            ;;
    esac

    cd "${wd}/${repo}"
}

e()
{
    emacs -g 120x50 "$@" &
}

function export-workspace() {
    export WORKSPACE="$(cdw >/dev/null; pwd)"

    export HISTFILE="${WORKSPACE}/.bash_history"
    export GRADLE_USER_HOME="${WORKSPACE}/.gradle"
    export M2_REPO="${WORKSPACE}/.m2"
    export NEBULA_HOME="$(\ls -U {$(git rev-parse --show-toplevel 2>/dev/null),${WORKSPACE}/nebula/wrapper}/gradlew 2>/dev/null | head -n 1 | xargs dirname 2>/dev/null | sed -e 's|/$||')"

    if [ "${NPM_CONFIG_PREFIX}" != '' ]
    then
        PATH=${PATH/:${NPM_CONFIG_PREFIX}\/bin/}
    fi

    export NPM_CONFIG_PREFIX="${WORKSPACE}/.npm-packages"
    export NODE_PATH="${NPM_CONFIG_PREFIX}/lib/node_modules"

    if [ -d "${NPM_CONFIG_PREFIX}/bin" -a -r "${NPM_CONFIG_PREFIX}/bin" ]
    then
        export PATH="${PATH}:${NPM_CONFIG_PREFIX}/bin"
    fi

    npm config set prefix "${NPM_CONFIG_PREFIX}"

    if [ "$(history | tail -n 1 | awk '{ print $2 }')" = 'cd' ]
    then
        history -r ${HISTFILE}
    else
        history -a
    fi
}

function mcd() {
	md "$@" && cd "$@"
}

function rmcd() {
	rd "$@" && mcd "$@"
}

function pd()
{
    if [ $# -eq 1 ]
    then
        pushd $*
    else
        popd
    fi
}

function pp()
{
    for file in $*
    do
        \mp -landscape -onesided -subject "${file}" <${file} | \mpage -1 -o -t
    done
}

function _ps1_root() {
  echo "\u:$(id -gn)@\h:\w|$(git rev-parse --abbrev-ref HEAD 2>/dev/null)"
}

if [ "$TERM" = "screen" -o "$TERM" = "xterm" ]
then
    function prompt-command() {
        export-workspace
        export PS1="$(_ps1_root)> \[\e]0;$(_ps1_root)\a\]"
    }
else
    function prompt-command() {
        export-workspace
        export PS1="$(_ps1_root)> "
    }
fi

function sd()
{
    export DISPLAY=`who -m | sed -e 's|.*(||' -e 's|).*||'`:0.0
}

tbunzip()
{
    bunzip2 --stdout "$@" | tar xfpv -
}

tbzip()
{
    file=$1
    shift

    tar cfpv - "$@" | bzip2 > $file
}

tgunzip()
{
    gzip -cdq "$@" | tar xfpv -
}

tgzip()
{
    file=$1
    shift

    tar cfpv - "$@" | gzip -f - > $file
}

# ulimit
ulimit -c unlimited

# umask
umask 0027

export CDPATH=.:~:~/proj

export EDITOR=vi

export HISTCONTROL=ignoredups
export HISTIGNORE="&"
export HISTSIZE=256
export HISTFILESIZE=65536

export PATH=~/bin:${PATH}
export PATH=${PATH}:${JAVA_HOME}/bin

export PROMPT_COMMAND="prompt-command"
export PS2="  "

if [ -z "${DISPLAY}" ]
then
  sd
fi
