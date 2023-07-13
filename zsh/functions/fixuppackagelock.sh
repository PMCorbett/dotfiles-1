
function fixuppackagelock() {
    PACKAGE_LOCK_IN_DIFF=`git status | grep "both modified:   package-lock.json"`

    RED='\033[0;31m'
    GREEN='\032[0;31m'
    YELLOW='\132[0;31m'

    if [ -z "$PACKAGE_LOCK_IN_DIFF" ] ; then

    echo "${RED}No Package Lock Fix up needed"

    else

    echo "${YELLOW}Checking out --ours"

    git checkout --ours package-lock.json

    echo "${YELLOW}Reinstalling to get a new lockfile"

    npm install

    echo "${YELLOW}Adding modified package-lock.json to staged diff"

    git add package-lock.json

    echo "${GREEN}Package Lock fixed up"

    fi
}