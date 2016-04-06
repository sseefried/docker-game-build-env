#!/bin/bash

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $THIS_DIR/set-env.sh
####################################################################################################

echo "Cloning hsSDL2"
git clone https://github.com/sseefried/hsSDL2.git
cd hsSDL2
git checkout e824a16c8374173796b607bf976a45c0f79a121e 2>&1