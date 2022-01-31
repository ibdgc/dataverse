#!/bin/bash

if [ "${LANG}" ]; then
   # Config 
   LANG_en='{"locale":"en","title":"English"}'
   LANG_fr='{"locale":"fr","title":"Français"}'
   LANG_ca='{"locale":"ca","title":"Français"}'
   LANG_sl='{"locale":"sl","title":"Slovenian"}'
   LANG_se='{"locale":"se","title":"Swedish"}'
   LANG_es='{"locale":"es","title":"Spanish"}'
   LANG_it='{"locale":"it","title":"Italian"}'
   LANG_ua='{"locale":"ua","title":"Ukrainian"}'
   LANG_pt='{"locale":"pt","title":"Portuguese"}'
   LANG_br='{"locale":"br","title":"Brazilian Portuguese"}'
   LANG_ru='{"locale":"ru","title":"Russian"}'
   LANG_de='{"locale":"de","title":"German"}'
   LANG_at='{"locale":"at","title":"Austrian German"}'
   LANG_hu='{"locale":"hu","title":"Hungarian"}'

   language="LANG_${LANG}"
   deflanguage="LANG_en"
   echo ${!deflanguage}

   defparams="[${!language}, ${!deflanguage}]"
   params="[${!language}]"

   #apt-get update
   #apt-get install zip
   if [ "${LANG_GITHUB}" ]; then
       wget ${LANG_GITHUB} -O /tmp/languages.zip
   else
       wget https://github.com/GlobalDataverseCommunityConsortium/dataverse-language-packs/archive/refs/heads/develop.zip -O /tmp/languages.zip
   fi 

   cd /tmp
   unzip -d dataverse-language-packs languages.zip
   mkdir /tmp/languages
   for locale in dataverse-language-packs/*; do
	 for distrib in $locale;
           do
	      for lang in $distrib/*; do
		 cp "$lang"/*.properties /tmp/languages
	      done
	 done
   done

   cd /tmp/languages
   zip languages.zip *.properties
   mkdir /opt/payara/langproperties
   asadmin --user=${ADMIN_USER} --passwordfile=${PASSWORD_FILE} create-jvm-options '-Ddataverse.lang.directory=/opt/payara/langproperties'
   curl http://localhost:8080/api/admin/datasetfield/loadpropertyfiles -X POST --upload-file /tmp/languages/languages.zip -H "Content-Type: application/zip"
   sleep 1
   # Enable language and cache settings
   curl http://localhost:8080/api/admin/settings/:Languages -X PUT -d "$defparams"
   curl http://localhost:8080
   sleep 1
   curl http://localhost:8080/api/admin/settings/:Languages -X PUT -d "$params"
   echo $defparams
   echo $params
fi
