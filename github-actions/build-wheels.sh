#!/bin/bash
set -e -u -x

# From https://github.com/pypa/python-manylinux-demo
# Originally written by Robert T. McGibbon and published under Public Domain
# Modified by Hajime Senuma

function repair_wheel {
    wheel="$1"
    if ! auditwheel show "$wheel"; then
        echo "Skipping non-platform wheel $wheel"
    else
        auditwheel repair "$wheel" --plat "$PLAT" -w /io/wheelhouse/
    fi
}

# Compile wheels
for PYBIN in /opt/python/*/bin; do
    "${PYBIN}/pip" install numpy
    "${PYBIN}/pip" install pytest
    "${PYBIN}/pip" wheel /io/ --no-deps -w wheelhouse/
done

# Bundle external shared libraries into the wheels
for whl in wheelhouse/*.whl; do
    repair_wheel "$whl"
done

# Install packages and test
for PYBIN in /opt/python/*/bin/; do
    "${PYBIN}/pip" install mmh3 --no-index -f /io/wheelhouse
    (cd "/io"; "${PYBIN}/python" -m pytest)
done