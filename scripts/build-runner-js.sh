#!/bin/sh


# Script para compilar task-runner javascript

    # Compilar task-runner javascript (produz: /app/dist/task-runner-javascript/)
    cd /app || exit 11;
    pnpm build --filter=@n8n/task-runner || exit 21;

    # Mover para pasta fora do /app
    cp -rav ./dist/task-runner-javascript /tmp/task-runner-javascript || exit 22;
    cd  /tmp/task-runner-javascript || exit 23;
    corepack enable pnpm || exit 24;

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

    # instalar moment
    rm -f node_modules/.modules.yaml 2>/dev/null;
    pnpm add moment@2.30.1 --prod --no-lockfile || exit 25;

    # colocar na pasta de runners
    cp -ra /tmp/task-runner-javascript /app/runners/;


exit 0;

