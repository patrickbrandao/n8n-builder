
# Rodar N8N no MacOS

## Copiar arquivos plist para o Launcher

```bash

rm ~/Library/LaunchAgents/com.n8n-editor.plist;
rm ~/Library/LaunchAgents/com.n8n-webhook.plist;
rm ~/Library/LaunchAgents/com.n8n-worker.plist;
rm ~/Library/LaunchAgents/com.task-runner-launcher.plist;

cp com.n8n-editor.plist            ~/Library/LaunchAgents/com.n8n-editor.plist;
cp com.n8n-webhook.plist           ~/Library/LaunchAgents/com.n8n-webhook.plist;
cp com.n8n-worker.plist            ~/Library/LaunchAgents/com.n8n-worker.plist;
cp com.task-runner-launcher.plist  ~/Library/LaunchAgents/com.task-runner-launcher.plist;

```

## Registrar o servico

```bash
#------------------------------------------- Parar
# Parar os serviços
launchctl  stop  com.n8n-editor;
launchctl  stop  com.n8n-webhook;
launchctl  stop  com.n8n-worker;
launchctl  stop  com.task-runner-launcher;

# Desregistrar (para atualizar)
launchctl  unload  ~/Library/LaunchAgents/com.n8n-editor.plist            2>/dev/null;
launchctl  unload  ~/Library/LaunchAgents/com.n8n-webhook.plist           2>/dev/null;
launchctl  unload  ~/Library/LaunchAgents/com.n8n-worker.plist            2>/dev/null;
launchctl  unload  ~/Library/LaunchAgents/com.task-runner-launcher.plist  2>/dev/null;

# Limpar logs
echo -n > /tmp/n8n-editor-error.log;
echo -n > /tmp/n8n-editor-stdout.log;
echo -n > /tmp/n8n-webhook-error.log;
echo -n > /tmp/n8n-webhook-stdout.log;
echo -n > /tmp/n8n-worker-error.log;
echo -n > /tmp/n8n-worker-stdout.log;
echo -n > /tmp/task-runner-launcher-error.log;
echo -n > /tmp/task-runner-launcher-stdout.log;

#------------------------------------------- Registrar e Iniciar
# Carregar no cadastro de serviços:
launchctl  load  ~/Library/LaunchAgents/com.n8n-editor.plist;
launchctl  load  ~/Library/LaunchAgents/com.n8n-webhook.plist;
launchctl  load  ~/Library/LaunchAgents/com.n8n-worker.plist;
launchctl  load  ~/Library/LaunchAgents/com.task-runner-launcher.plist;

```

## Verificar execucao

```bash

# Verificar status
launchctl list | egrep '(n8n|task-run)';
    # 26377   0   com.n8n-webhook
    # 26080   0   com.n8n-editor
    # 26077   1   com.n8n-worker
    # 90665   0   com.task-runner-launcher

# Ver logs
tail -n 20 /tmp/n8n* /tmp/task*;

# Acompanhar logs
tail -f /tmp/n8n* /tmp/task*;

```

## Reiniciar

```bash

# Parar os serviços
launchctl  stop   com.n8n-editor;
launchctl  stop   com.n8n-webhook;
launchctl  stop   com.n8n-worker;

# Parar os serviços
launchctl  start  com.n8n-editor;
launchctl  start  com.n8n-webhook;
launchctl  start  com.n8n-worker;

```



## Reiniciar worker e task-runner-launcher

```bash

launchctl  stop  com.n8n-worker;
launchctl  stop  com.task-runner-launcher;
launchctl  unload  ~/Library/LaunchAgents/com.n8n-worker.plist            2>/dev/null;
launchctl  unload  ~/Library/LaunchAgents/com.task-runner-launcher.plist  2>/dev/null;
launchctl  stop   com.n8n-webhook;
launchctl  stop   com.n8n-worker;

launchctl  unload  ~/Library/LaunchAgents/com.n8n-worker.plist            2>/dev/null;
launchctl  unload  ~/Library/LaunchAgents/com.task-runner-launcher.plist  2>/dev/null;

echo -n > /tmp/n8n-worker-error.log;
echo -n > /tmp/n8n-worker-stdout.log;

echo -n > /tmp/task-runner-launcher-error.log;
echo -n > /tmp/task-runner-launcher-stdout.log;

launchctl  load  ~/Library/LaunchAgents/com.n8n-worker.plist;
launchctl  load  ~/Library/LaunchAgents/com.task-runner-launcher.plist;

```


