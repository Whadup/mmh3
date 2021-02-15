#!/bin/bash
set -e -u -x

# From https://github.com/pypa/python-manylinux-demo
# Originally written by Robert T. McGibbon and published under Public Domain
# Modified by Hajime Senuma

supported_python_versions=(cp36-cp36m cp37-cp37m cp38-cp38 cp39-cp39)

function repair_wheel {
    wheel="$1"
    if ! auditwheel show "$wheel"; then
        echo "Skipping non-platform wheel $wheel"
    else
        auditwheel repair "$wheel" --plat "$PLAT" -w /io/wheelhouse/
    fi
}

# Compile wheels
for PYBIN in "${supported_python_versions[@]}"; do
    "/opt/python/${PYBIN}/bin/pip" wheel /io/ --no-deps -w wheelhouse/
done

# Bundle external shared libraries into the wheels
for whl in wheelhouse/*.whl; do
    repair_wheel "$whl"
done

# Install packages and test
for PYBIN in "${supported_python_versions[@]}"; do
    "/opt/python/${PYBIN}/bin/pip" install numpy
    "/opt/python/${PYBIN}/bin/pip" install pytest
    "/opt/python/${PYBIN}/bin/pip" install mmh3 --no-index -f /io/wheelhouse
    (cd "/io"; "/opt/python/${PYBIN}/bin/python" -m pytest)
done