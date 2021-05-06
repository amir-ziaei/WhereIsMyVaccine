#!/usr/local/bin/bash

# Voice notification triggers on ------------------------------------------------------------------
: '
The list of vaccines to choose from:
	- Moderna
	- Comirnaty (Pfizer)
	- Vaxzevria (AstraZeneca)
	- Janssen
'
DesiredVaccines=('Comirnaty (Pfizer)')

: '
The list of cities to choose from:
	- Kaunas
	- Vilnius
'
DesiredCities=('Kaunas' 'Vilnius')
#-------------------------------------------------------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

CityNames=('Kaunas' 'Vilnius')
CitySources=('https://vac.myhybridlab.com/selfregister/vaccine' 'https://vilnius-vac.myhybridlab.com/selfregister/vaccine')

while true; do
	for i in "${!CityNames[@]}"; do
	  fetch=$(curl -sS ${CitySources[$i]} | grep vaccine-rooms=)
	  filter="${fetch/:vaccine-rooms=/}"
	  filter=$(echo "$filter" | sed "s/'//g")
	  countOfTypes=$(echo "$filter" | jq length)
	  printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
	  cityName=${CityNames[$i]}
	  echo "$cityName"
	  for ((i = 0 ; i < $countOfTypes ; i++)); do
	  	vaccineName=$(echo "$filter" | jq ".[${i}].name" | sed 's/"//g')
	  	vaccineCount=$(echo "$filter" | jq ".[${i}].free_total" | sed 's/"//g')
	  	[[ vaccineCount -gt 0 ]] && color="$GREEN" || color="$RED"
	  	printf "${color}${vaccineName}${NC} ${vaccineCount} \n"
	  	if [[ "${DesiredCities[@]}" =~ "${cityName}" && "${DesiredVaccines[@]}" =~ "${vaccineName}" && vaccineCount -gt 0 ]]; then
	  		[[ vaccineCount -gt 1 ]] && pluralIndicator="s" || pluralIndicator=""
		    say "Hurry up, ${cityName} has ${vaccineCount} ${vaccineName} vaccine${pluralIndicator}"
		fi
	  done
	done
	sleep 5;
done