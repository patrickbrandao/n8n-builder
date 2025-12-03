#!/bin/sh

# Fixar pacotes do task-runner javascript
    node -e "const pkg = require('./package.json'); \
        Object.keys(pkg.dependencies || {}).forEach(k => { \
            const val = pkg.dependencies[k]; \
            if (val === 'catalog:' || val.startsWith('catalog:') || val.startsWith('workspace:')) \
                delete pkg.dependencies[k]; \
        }); \
        Object.keys(pkg.devDependencies || {}).forEach(k => { \
            const val = pkg.devDependencies[k]; \
            if (val === 'catalog:' || val.startsWith('catalog:') || val.startsWith('workspace:')) \
                delete pkg.devDependencies[k]; \
        }); \
        delete pkg.devDependencies; \
        require('fs').writeFileSync('./package.json', JSON.stringify(pkg, null, 2));"

exit $?;
