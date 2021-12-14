#!/bin/bash

# Running python script to invoke webhooks
if [ "${CLARIN}" ]; then
    wget https://raw.githubusercontent.com/IQSS/dataverse-docker/master/config/schemas/cmdi-oral-history.tsv -O /tmp/cmdi.tsv
    curl http://localhost:8080/api/admin/datasetfield/load -H "Content-type: text/tab-separated-values" -X POST --upload-file /tmp/cmdi.tsv
    custommetadatablock=True
fi

if [ "${CESSDA}" ]; then
    wget https://gdcc.github.io/dataverse-external-vocab-support/scripts/skosmos.js -O /tmp/skosmos.js
    wget https://raw.githubusercontent.com/ekoi/speeltuin/master/resources/CMM_Custom_MetadataBlock.tsv -O /tmp/CMM_Custom_MetadataBlock.tsv
    wget https://raw.githubusercontent.com/IQSS/dataverse-docker/master/config/schemas/cv_voc.json -O /tmp/cv_voc.json
    curl -H "Content-Type: application/json" -X PUT \
          -d @/tmp/cv_voc.json http://localhost:8080/api/admin/settings/:CVocConf
    curl http://localhost:8080/api/admin/datasetfield/load -H "Content-type: text/tab-separated-values" -X POST --upload-file /tmp/CMM_Custom_MetadataBlock.tsv
    custommetadatablock=True
fi

if  [ -n "$custommetadatablock" ]; then
    wget https://github.com/IQSS/dataverse/releases/download/v5.8/update-fields.sh
    chmod +x update-fields.sh
    curl "http://localhost:8080/api/admin/index/solr/schema" | ./update-fields.sh schema.xml
    /bin/cp schema.xml /tmp/
    /opt/payara/dvinstall/updateSchemaMDB.sh -s solr:8983
fi
