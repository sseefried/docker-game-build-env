#!/bin/bash

THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $THIS_DIR/set-env.sh
####################################################################################################

git clone https://github.com/sseefried/helm.git
cd helm
git checkout bf80e29667bc799b048d47ff9c5bcd3406a46dd0 2>&1
