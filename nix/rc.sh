#export ZMK_BUILD_DIR=$PWD/.build
# ZMK_LIB_PREFIX
ZEPHYR_BASE=$(west config 'zephyr.base')

if [[ -n $ZEPHYR_BASE ]]
then
    echo "found ZEPHYR_BASE: $ZEPHYR_BASE"

    Zephyr_DIR=$ZEPHYR_BASE/share/zephyr-package/cmake/

    ZMK_SRC_DIR=${LIB_BASE_DIR}/zmk/app
    LIB_BASE_DIR="$(dirname "$ZEPHYR_BASE")"

    export LIB_BASE_DIR
    export ZMK_SRC_DIR
    export Zephyr_DIR
else
    echo "found ZEPHYR_BASE not found: $ZEPHYR_BASE"

fi

