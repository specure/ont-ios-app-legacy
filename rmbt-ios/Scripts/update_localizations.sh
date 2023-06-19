#!/bin/bash

[[ -z "${SRCROOT}" ]] && SRCROOT='.'

API_KEY=example
BaseLanguage=en

curl --user api:$API_KEY -X -L -F file=@Resources/$BaseLanguage.lproj/Localizable.strings -X PUT https://www.transifex.com/api/2/project/nettest/resource/localizablestrings/content/

declare -a local_language_array=("en" "de" "sl" "sr-Latn" "sr" "cs" "sk" "nb" "fr" "is" "ja" "pl" "ru" "sv" "zh-Hans" "hr" "es" "cs-CZ" "hu" "bg" "it" "Base")
declare -a language_array=("en" "de" "sl" "sr-Latn" "sr" "cs" "sk" "nb" "fr" "is" "ja" "pl" "ru" "sv" "zh-Hans" "hr" "es" "cs-CZ" "hu" "bg" "it" "en")

curl -L --user api:$API_KEY -X GET https://www.transifex.com/api/2/project/nettest/resource/localizablestrings/translation/sq/?file=strings -o ./Localizable.strings

#for i in "${!local_language_array[@]}"
#do
#curl -L --user api:$API_KEY -X GET https://www.transifex.com/api/2/project/nettest/resource/localizablestrings/translation/"${language_array[i]}"/?file=strings -o ${SRCROOT}/Resources/"${local_language_array[i]}".lproj/Localizable.strings
#done
