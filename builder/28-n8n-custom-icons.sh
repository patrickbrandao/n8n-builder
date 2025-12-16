#!/bin/bash

# Personalizacao de icones e nodes

    # Incluir funcoes e variaveis
    . $(dirname $(readlink -f "$0"))/00-lib.sh;

    _echo_title "Aplicando customizacao de icones";

    # formato de arquivo backup inicial
    BCKEXT="oics";

    # detectar execucao no MAC
    SEDARG="";
    UNAMEO=$(uname -o);
    [ "$UNAMEO" = "Darwin" ] && SEDARG=".bck1";

    # Entrar no diretorio dos fontes:
    _cdfolder /opt/homebrew/n8n-current;

    # Baixar icones
    _echo_task "Baixando icones";

    ICONS_LIST="
        https://tmsoft.com.br/temp/pen.svg
        https://tmsoft.com.br/temp/llama.svg
        https://tmsoft.com.br/temp/bucket-s3.png
        https://tmsoft.com.br/temp/spiral.svg
        https://tmsoft.com.br/temp/cloud-connect.svg
        https://tmsoft.com.br/temp/pause-orange.svg
        https://tmsoft.com.br/temp/brackets-gradient.svg
        https://tmsoft.com.br/temp/planet-earth.svg
        https://tmsoft.com.br/temp/terminal.svg
        https://tmsoft.com.br/temp/brain.svg
        https://tmsoft.com.br/temp/calculator-pad-nb.svg
        https://tmsoft.com.br/temp/coding.svg
        https://tmsoft.com.br/temp/robot.svg
        https://tmsoft.com.br/temp/theater.svg
        https://tmsoft.com.br/temp/chat.svg
        https://tmsoft.com.br/temp/database.svg
        https://tmsoft.com.br/temp/link.svg
        https://tmsoft.com.br/temp/tag.svg
        https://tmsoft.com.br/temp/clock-blue.svg
        https://tmsoft.com.br/temp/clock-stop-watch.svg
        https://tmsoft.com.br/temp/workflow-exec.svg
    ";
    for url in $ICONS_LIST; do
        fname=$(basename "$url");
        _wget "$url" "$ICONS_DIR/$fname";
    done;


#--------------------------------------------------------------------- node edit (pen, caneta)

    ICON_LIST="
        ./packages/@n8n/utils/src/search/snapshots/pen.svg
        ./packages/nodes-base/nodes/Set/v1/pen.svg
        ./packages/nodes-base/nodes/Set/pen.svg
    ";
    _copy_list "pen.svg" "$ICON_LIST";

    FILE_LIST="
        ./packages/@n8n/utils/src/search/snapshots/toplevel.snapshot.json
        ./packages/nodes-base/nodes/Set/v1/SetV1.node.ts
        ./packages/nodes-base/nodes/Set/Set.node.ts
    ";
    for F in $FILE_LIST; do _backup "$F"; sed -i $SEDARG "s/fa:pen/file:pen.svg/g" $F; _sed_diff; done;




#--------------------------------------------------------------------- ollama

    ICON_LIST="
        ./packages/@n8n/nodes-langchain/nodes/embeddings/EmbeddingsOllama/ollama.svg
        ./packages/@n8n/nodes-langchain/nodes/llms/LMChatOllama/ollama.svg
        ./packages/@n8n/nodes-langchain/nodes/llms/LMOllama/ollama.svg
    ";
    _copy_list "llama.svg" "$ICON_LIST";



#--------------------------------------------------------------------- s3 bucket

    ICON_LIST="
        ./packages/nodes-base/nodes/S3/s3.png
    ";
    _copy_list "bucket-s3.png" "$ICON_LIST";



#--------------------------------------------------------------------- loop over items

    ICON_LIST="
        ./packages/@n8n/utils/src/search/snapshots/spiral.svg
        ./packages/nodes-base/nodes/SplitInBatches/v3/spiral.svg
        ./packages/nodes-base/nodes/SplitInBatches/spiral.svg
    ";
    _copy_list "spiral.svg" "$ICON_LIST";

    FILE_LIST="
        ./packages/@n8n/utils/src/search/snapshots/toplevel.snapshot.json
        ./packages/nodes-base/nodes/SplitInBatches/v3/SplitInBatchesV3.node.ts
    ";
    for F in $FILE_LIST; do _backup "$F"; sed -i $SEDARG "s/fa:sync/file:spiral.svg/g" $F; _sed_diff; done;



#--------------------------------------------------------------------- sse connect (nuvem)

    ICON_LIST="
        ./packages/@n8n/utils/src/search/snapshots/sse.svg
        ./packages/nodes-base/nodes/SseTrigger/sse.svg
    ";
    _copy_list "cloud-connect.svg" "$ICON_LIST";

    FILE_LIST="
        ./packages/@n8n/utils/src/search/snapshots/toplevel.snapshot.json
        ./packages/nodes-base/nodes/SseTrigger/SseTrigger.node.ts
    ";
    for F in $FILE_LIST; do _backup "$F"; sed -i $SEDARG "s/fa:cloud-download-alt/file:sse.svg/g" $F; _sed_diff; done



#--------------------------------------------------------------------- Wait (Pause)

    ICON_LIST="
        ./packages/@n8n/utils/src/search/snapshots/pause.svg
        ./packages/nodes-base/nodes/Wait/pause.svg
    ";
    _copy_list "pause-orange.svg" "$ICON_LIST";

    FILE_LIST="
        ./packages/@n8n/utils/src/search/snapshots/toplevel.snapshot.json
        ./packages/nodes-base/nodes/Wait/Wait.node.ts
    ";
    for F in $FILE_LIST; do _backup "$F"; sed -i $SEDARG "s/fa:pause-circle/file:pause.svg/g" $F; _sed_diff; done


#--------------------------------------------------------------------- node code

    # ICON_LIST="
    #     ./packages/nodes-base/nodes/Code/code.svg
    # ";
    # _copy_list "brackets-gradient.svg" "$ICON_LIST";



#--------------------------------------------------------------------- http request

    ICON_LIST="
        ./packages/nodes-base/nodes/HttpRequest/httprequest.dark.svg
        ./packages/@n8n/nodes-langchain/nodes/tools/ToolHttpRequest/httprequest.dark.svg
        ./packages/nodes-base/nodes/HttpRequest/httprequest.svg
        ./packages/@n8n/nodes-langchain/nodes/tools/ToolHttpRequest/httprequest.svg
    ";
    _copy_list "planet-earth.svg" "$ICON_LIST";



#--------------------------------------------------------------------- Terminal

    ICON_LIST="
        ./packages/@n8n/utils/src/search/snapshots/terminal.svg
        ./packages/nodes-base/nodes/ExecuteCommand/terminal.svg
        ./packages/nodes-base/nodes/Ssh/terminal.svg
    ";
    _copy_list "terminal.svg" "$ICON_LIST";

    FILE_LIST="
        ./packages/@n8n/utils/src/search/snapshots/toplevel.snapshot.json
        ./packages/nodes-base/nodes/ExecuteCommand/ExecuteCommand.node.ts
        ./packages/nodes-base/nodes/Ssh/Ssh.node.ts
    ";
    for F in $FILE_LIST; do _backup "$F"; sed -i $SEDARG "s/fa:terminal/file:terminal.svg/g" $F; _sed_diff; done



#--------------------------------------------------------------------- ToolThink (cerebro)

    ICON_LIST="./packages/@n8n/nodes-langchain/nodes/tools/ToolThink/brain.svg";
    _copy_list "brain.svg" "$ICON_LIST";

    F=./packages/@n8n/nodes-langchain/nodes/tools/ToolThink/ToolThink.node.ts;
    sed -i $SEDARG "s/fa:brain/file:brain.svg/g" $F; _sed_diff;



#--------------------------------------------------------------------- ToolCalculator (calculadora)

    ICON_LIST="
        ./packages/@n8n/nodes-langchain/nodes/tools/ToolCalculator/calculator.svg
    ";
    _copy_list "calculator-pad-nb.svg" "$ICON_LIST";

    FILE_LIST="
        ./packages/@n8n/nodes-langchain/nodes/tools/ToolCalculator/ToolCalculator.node.ts
    ";
    for F in $FILE_LIST; do _backup "$F"; sed -i $SEDARG "s/fa:calculator/file:calculator.svg/g" $F; _sed_diff; done


#--------------------------------------------------------------------- Code (tag)

    # Nao mudar, ficou melhor o nativo!
    if [ "1" = "2" ]; then
        ICON_LIST="
            ./packages/@n8n/nodes-langchain/nodes/output_parser/OutputParserStructured/code.svg
            ./packages/@n8n/nodes-langchain/nodes/output_parser/OutputParserStructured/coding.svg
            ./packages/@n8n/nodes-langchain/nodes/tools/ToolCode/coding.svg
            ./packages/@n8n/nodes-langchain/nodes/tools/ToolCode/code.svg
        ";
        # ./packages/@n8n/nodes-langchain/nodes/code/coding.svg
        # ./packages/@n8n/nodes-langchain/nodes/code/code.svg
        _copy_list "coding.svg" "$ICON_LIST";

        FILE_LIST="
            ./packages/@n8n/nodes-langchain/nodes/output_parser/OutputParserStructured/OutputParserStructured.node.ts
            ./packages/@n8n/nodes-langchain/nodes/tools/ToolCode/ToolCode.node.ts
            ./packages/@n8n/nodes-langchain/nodes/code/Code.node.ts
        ";
        for F in $FILE_LIST; do _backup "$F"; sed -i $SEDARG "s/fa:code/file:code.svg/g" $F; _sed_diff; done;
    fi;


#--------------------------------------------------------------------- AI-Agent (robozinho)

    ICON_LIST="
        ./packages/@n8n/utils/src/search/snapshots/robot.svg
        ./packages/@n8n/nodes-langchain/nodes/agents/Agent/robot.svg
        ./packages/@n8n/nodes-langchain/nodes/agents/Agent/robot.svg
        ./packages/@n8n/nodes-langchain/nodes/agents/OpenAiAssistant/robot.svg
    ";
    _copy_list "robot.svg" "$ICON_LIST";

    FILE_LIST="
        ./packages/@n8n/utils/src/search/snapshots/toplevel.snapshot.json
        ./packages/@n8n/nodes-langchain/nodes/agents/Agent/AgentTool.node.ts
        ./packages/@n8n/nodes-langchain/nodes/agents/Agent/Agent.node.ts
        ./packages/@n8n/nodes-langchain/nodes/agents/OpenAiAssistant/OpenAiAssistant.node.ts
    ";
    for F in $FILE_LIST; do _backup "$F"; sed -i $SEDARG "s/fa:robot/file:robot.svg/g" $F; _sed_diff; done



#--------------------------------------------------------------------- Sentiment Analysis (sentimentos)

    ICON_LIST="
        ./packages/@n8n/utils/src/search/snapshots/theater.svg
        ./packages/@n8n/nodes-langchain/nodes/chains/SentimentAnalysis/theater.svg
    ";
    _copy_list "theater.svg" "$ICON_LIST";

    FILE_LIST="
        ./packages/@n8n/utils/src/search/snapshots/toplevel.snapshot.json
        ./packages/@n8n/nodes-langchain/nodes/chains/SentimentAnalysis/SentimentAnalysis.node.ts
    ";
    for F in $FILE_LIST; do _backup "$F"; sed -i $SEDARG "s/fa:balance-scale-left/file:theater.svg/g" $F; _sed_diff; done



#--------------------------------------------------------------------- Chat Message (balaozinho)

    ICON_LIST="
        ./packages/@n8n/utils/src/search/snapshots/chat.svg
        ./packages/@n8n/nodes-langchain/nodes/trigger/ManualChatTrigger/chat.svg
        ./packages/@n8n/nodes-langchain/nodes/trigger/ChatTrigger/chat.svg
        ./packages/@n8n/nodes-langchain/nodes/trigger/ChatTrigger/chat.svg
    ";

    _copy_list "chat.svg" "$ICON_LIST";

    FILE_LIST="
        ./packages/@n8n/utils/src/search/snapshots/toplevel.snapshot.json
        ./packages/@n8n/nodes-langchain/nodes/trigger/ManualChatTrigger/ManualChatTrigger.node.ts
        ./packages/@n8n/nodes-langchain/nodes/trigger/ChatTrigger/ChatTrigger.node.ts
        ./packages/@n8n/nodes-langchain/nodes/trigger/ChatTrigger/Chat.node.ts
    ";
    for F in $FILE_LIST; do _backup "$F"; sed -i $SEDARG "s/fa:comments/file:chat.svg/g" $F; _sed_diff; done



#--------------------------------------------------------------------- Database (db)

    ICON_LIST="
        ./packages/@n8n/utils/src/search/snapshots/database.svg
        ./packages/@n8n/utils/src/search/snapshots/database.svg
        ./packages/@n8n/nodes-langchain/nodes/tools/ToolVectorStore/database.svg
        ./packages/@n8n/nodes-langchain/nodes/memory/MemoryBufferWindow/database.svg
        ./packages/@n8n/nodes-langchain/nodes/memory/MemoryChatRetriever/database.svg
        ./packages/@n8n/nodes-langchain/nodes/memory/MemoryManager/database.svg
        ./packages/@n8n/nodes-langchain/nodes/vector_store/VectorStoreInMemory/database.svg
        ./packages/@n8n/nodes-langchain/nodes/vector_store/VectorStoreInMemoryLoad/database.svg
        ./packages/@n8n/nodes-langchain/nodes/vector_store/VectorStoreInMemoryInsert/database.svg
    ";
    _copy_list "database.svg" "$ICON_LIST";

    FILE_LIST="
        ./packages/@n8n/utils/src/search/snapshots/toplevel.snapshot.json
        ./packages/@n8n/utils/src/search/snapshots/toplevel.snapshot.json
        ./packages/@n8n/nodes-langchain/nodes/tools/ToolVectorStore/ToolVectorStore.node.ts
        ./packages/@n8n/nodes-langchain/nodes/memory/MemoryBufferWindow/MemoryBufferWindow.node.ts
        ./packages/@n8n/nodes-langchain/nodes/memory/MemoryChatRetriever/MemoryChatRetriever.node.ts
        ./packages/@n8n/nodes-langchain/nodes/memory/MemoryManager/MemoryManager.node.ts
        ./packages/@n8n/nodes-langchain/nodes/vector_store/VectorStoreInMemory/VectorStoreInMemory.node.ts
        ./packages/@n8n/nodes-langchain/nodes/vector_store/VectorStoreInMemoryLoad/VectorStoreInMemoryLoad.node.ts
        ./packages/@n8n/nodes-langchain/nodes/vector_store/VectorStoreInMemoryInsert/VectorStoreInMemoryInsert.node.ts
    ";
    for F in $FILE_LIST; do _backup "$F"; sed -i $SEDARG "s/fa:database/file:database.svg/g" $F; _sed_diff; done



#--------------------------------------------------------------------- LangChain (corrente)

    ICON_LIST="
        ./packages/@n8n/utils/src/search/snapshots/link.svg
        ./packages/@n8n/nodes-langchain/nodes/chains/ChainRetrievalQA/link.svg
        ./packages/@n8n/nodes-langchain/nodes/chains/ChainSummarization/link.svg
        ./packages/@n8n/nodes-langchain/nodes/chains/ChainLLM/link.svg
    ";
    _copy_list "link.svg" "$ICON_LIST";

    FILE_LIST="
        ./packages/@n8n/utils/src/search/snapshots/toplevel.snapshot.json
        ./packages/@n8n/nodes-langchain/nodes/chains/ChainRetrievalQA/ChainRetrievalQa.node.ts
        ./packages/@n8n/nodes-langchain/nodes/chains/ChainSummarization/ChainSummarization.node.ts
        ./packages/@n8n/nodes-langchain/nodes/chains/ChainLLM/ChainLlm.node.ts
    ";
    for F in $FILE_LIST; do _backup "$F"; sed -i $SEDARG "s/fa:link/file:link.svg/g" $F; _sed_diff; done



#--------------------------------------------------------------------- LangChain Classifier (tags)

    ICON_LIST="
        ./packages/@n8n/utils/src/search/snapshots/tag.svg
        ./packages/@n8n/nodes-langchain/nodes/chains/TextClassifier/tag.svg
    ";
    _copy_list "tag.svg" "$ICON_LIST";

    FILE_LIST="
        ./packages/@n8n/utils/src/search/snapshots/toplevel.snapshot.json
        ./packages/@n8n/nodes-langchain/nodes/chains/TextClassifier/TextClassifier.node.ts
    ";
    for F in $FILE_LIST; do _backup "$F"; sed -i $SEDARG "s/fa:tags/file:tag.svg/g" $F; _sed_diff; done



#--------------------------------------------------------------------- Date/time (clock)

    ICON_LIST="
        ./packages/nodes-base/nodes/DateTime/clock.svg
        ./packages/nodes-base/nodes/DateTime/V1/clock.svg
        ./packages/@n8n/utils/src/search/snapshots/clock.svg
    ";
    _copy_list "clock-blue.svg" "$ICON_LIST";

    FILE_LIST="
        ./packages/@n8n/utils/src/search/snapshots/toplevel.snapshot.json
        ./packages/nodes-base/nodes/DateTime/DateTime.node.ts
        ./packages/nodes-base/nodes/DateTime/V1/DateTimeV1.node.ts
    ";
    for F in $FILE_LIST; do _backup "$F"; sed -i $SEDARG "s/fa:clock/file:clock.svg/g" $F; _sed_diff; done



#--------------------------------------------------------------------- Cron Trigger (clock)

    ICON_LIST="
        ./packages/nodes-base/nodes/Cron/clock-stop-watch.svg
        ./packages/nodes-base/nodes/Schedule/clock-stop-watch.svg
    ";
    _copy_list "clock-stop-watch.svg" "$ICON_LIST";

    FILE_LIST="
        ./packages/nodes-base/nodes/Cron/Cron.node.ts
        ./packages/nodes-base/nodes/Schedule/ScheduleTrigger.node.ts
    ";
    for F in $FILE_LIST; do _backup "$F"; sed -i $SEDARG "s/fa:clock/file:clock-stop-watch.svg/g" $F; _sed_diff; done



#--------------------------------------------------------------------- Tool call workflow

    ICON_LIST="
        ./packages/nodes-base/nodes/WorkflowTrigger/workflow-exec.svg
        ./packages/@n8n/nodes-langchain/nodes/tools/ToolWorkflow/workflow-exec.svg
    ";
    _copy_list "workflow-exec.svg" "$ICON_LIST";

    FILE_LIST="
        ./packages/nodes-base/nodes/WorkflowTrigger/WorkflowTrigger.node.ts
        ./packages/@n8n/nodes-langchain/nodes/tools/ToolWorkflow/ToolWorkflow.node.ts
    ";
    for F in $FILE_LIST; do _backup "$F"; sed -i $SEDARG "s/fa:network-wired/file:workflow-exec.svg/g" $F; _sed_diff; done


#--------------------------------------------------------------------- Execute Workflow

    NODEXW="./packages/nodes-base/nodes/ExecuteWorkflow/ExecuteWorkflow/ExecuteWorkflow.node.ts";
    _backup "$NODEXW";
    #- COR DO ICONE DO NODE EXECUTE WORKFLOW, trocar 'orange-red' por 'light-blue'
    sed -i $SEDARG '/iconColor/s/orange-red/light-blue/' $NODEXW;
    _sed_diff;

    echo;



exit 0



