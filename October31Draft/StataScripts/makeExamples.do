//example datasets

clear
set more off

//data directory
global home "K:\Research\Projects\HomeCourt"
global data "$home\StataData"


//within estimator example

import excel "$home\withinDummyData.xlsx", firstrow

//regress margin difference from average margin within matchup on home
regress marginDiff teamHome


**********************************************************************

//team and opponent fixed effects example
clear
import excel "$home\fixedEffectsDummyData.xlsx", firstrow

//make team and opponent factor variables
encode team, generate(teamF)
encode opponent, generate(opponentF)

regress margin teamHome i.teamF i.opponentF
