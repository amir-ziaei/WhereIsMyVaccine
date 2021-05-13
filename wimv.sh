#!/bin/bash

# Voice notification triggers on ... ---------------------------------------------------------------
NOTIFY=1 # on-off button
: '
The list of vaccines to choose from:
	- Moderna
	- Comirnaty (Pfizer)
	- Vaxzevria (AstraZeneca)
	- Janssen
'
DesiredVaccines=('Comirnaty (Pfizer)' 'Moderna')

: '
The list of cities to choose from:
	- Kaunas
	- Vilnius
'
DesiredCities=('Kaunas' 'Vilnius')
#-------------------------------------------------------------------------------------------------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

if ! command -v jq &> /dev/null; then
  printf "${RED}jq is a required dependecy of this script. Please install it from the following link:${NC}\n"
  echo "https://stedolan.github.io/jq/download/"
  read -r
  exit
fi

if [[ "$NOTIFY" = 1 ]]; then
	if ! command -v say &> /dev/null; then
		if command -v espeak &> /dev/null; then
			alias say='espeak'
		elif [[ "$NOTIFY" = 1 ]]; then
			NOTIFY=0
			printf "${YELLOW}No text-to-speech package was detected. You will not receive voice notifications!${NC}\n"
			echo "We recommended that you install espeak from the following link:"
			echo "http://espeak.sourceforge.net/download.html"
		fi
	fi
fi

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
	  	if [[ "$NOTIFY" = 1 && "${DesiredCities[@]}" =~ "${cityName}" && "${DesiredVaccines[@]}" =~ "${vaccineName}" && vaccineCount -gt 0 ]]; then
	  		[[ vaccineCount -gt 1 ]] && pluralIndicator="s" || pluralIndicator=""
		    say "Hurry up, ${cityName} has ${vaccineCount} ${vaccineName} vaccine${pluralIndicator}"
		fi
	  done
	done
	sleep 5;
done