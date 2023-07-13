
function fixupyarnlock() {
    YARN_LOCK_IN_DIFF=`git status | grep "both modified:   yarn.lock"`

    RED='\033[0;31m'
    GREEN='\032[0;31m'
    YELLOW='\132[0;31m'

    if [ -z "$YARN_LOCK_IN_DIFF" ] ; then

    echo "${RED}No Yarn Lock Fix up needed"

    else

    echo "${YELLOW}Checking out --ours"

    git checkout --ours yarn.lock

    echo "${YELLOW}Reinstalling to get a new lockfile"

    yarn

    echo "${YELLOW}Adding modified yarn.lock to staged diff"

    git add yarn.lock

    echo "${GREEN}Yarn Lock fixed up"

    fi
}