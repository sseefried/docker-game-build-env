#!/bin/bash

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $THIS_DIR/set-env.sh
####################################################################################################

echo "Cloning hsSDL2"
git clone https://github.com/sseefried/hsSDL2.git
cd hsSDL2
git checkout 942be9e67f39c4804efcf6248284e58b675ed490  2>&1
