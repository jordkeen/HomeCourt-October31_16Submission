// home court analysis

clear
capture log close
set more off
set matsize 10000
ssc install estout, replace


********************************************************************
capture log close
log using "$logs\naiveRegression.log", replace
//naive regression of margin on home
cd "$data"
use allData

//beforeJan and home/away interaction variables
gen teamHomeBeforeJan = teamHome*beforeJan
gen teamAwayBeforeJan = teamAway*beforeJan

foreach year in 2014 2015 2016{
	di `year'
	regress margin teamHome teamAway if season==`year'
	regress margin teamHome teamAway teamHomeBeforeJan teamAwayBeforeJan ///
	if season==`year'
}

//all years
regress margin teamHome teamAway
regress margin teamHome teamAway teamHomeBeforeJan teamAwayBeforeJan

//regression output
eststo clear
eststo: qui regress margin teamHome teamAway if season==2014
eststo: qui regress margin teamHome teamAway if season==2015
eststo: qui regress margin teamHome teamAway if season==2016
eststo: qui regress margin teamHome teamAway
esttab using "$regs\naiveRegHomeByYear.csv", replace nogap onecell
eststo clear

log close

*****************************************************************************
capture log close
log using "$logs\withinEstimators.log", replace
//within matchup estimates
clear
cd "$data"
use allDataHH

regress matchupMarginDiff teamHome
regress matchupMarginDiff teamHome if season==2014
regress matchupMarginDiff teamHome if season==2015
regress matchupMarginDiff teamHome if season==2016

//regression output
eststo clear
eststo: qui regress matchupMarginDiff teamHome if season==2014
eststo: qui regress matchupMarginDiff teamHome if season==2015
eststo: qui regress matchupMarginDiff teamHome if season==2016
eststo: qui regress matchupMarginDiff teamHome
esttab using "$regs\withinEstimators.csv", replace nogap onecell
eststo clear

log close
****************************************************************************
capture log close
log using "$logs\fixedEffects.log", replace
//team and opponent fixed effects
clear
cd "$data"
use allData

eststo clear
eststo: regress margin teamHome teamAway i.teamFactor i.opponentFactor ///
 if season==2014
eststo: regress margin teamHome teamAway i.teamFactor i.opponentFactor ///
 if season==2015
eststo: regress margin teamHome teamAway i.teamFactor i.opponentFactor ///
 if season==2016

esttab using "$regs\fixedEffects.csv", replace wide plain se
eststo clear

log close
*****************************************************************************
log using "$logs\fixedEffectsTests.log", replace
//check FE model for heteroscedasticity and evaluate SE of predicted values

foreach year in 2014 2015 2016 {
	clear
	use "$data\allData"
	drop if season != `year'
	
	regress margin teamHome teamAway i.teamFactor i.opponentFactor
	
	predict hat
	predict res, res
	predict stdf, stdf
	gen lo = hat - 1.96*stdf
	gen hi = hat + 1.96*stdf
	
	# delimit ;
	
	//Figure 3
	qnorm res, 
		title("Normal Probability Plot")
		subtitle("Fixed Effects Model - `year' Season")
		saving("$graphs\residualsNormPlot`year'", replace);
	graph export "$graphs\PDFs\residualsNormPlot`year'.pdf", replace;
	graph export "$graphs\PNGs\residualsNormPlot`year'.png", replace;
	
	histogram res, 
		title("Residuals Distribution")
		subtitle("Fixed Effects Model - `year' Season")
		saving("$graphs\residualsDistribution`year'", replace);
	graph export "$graphs\PDFs\residualsDistribution`year'.pdf", replace;
	graph export "$graphs\PNGs\residualsDistribution`year'.png", replace;
	
	//Figure 1
	twoway 
	(scatter margin hat, msize(small) msymbol(smcircle))
	(line lo hi hat, pstyle(p2 p2) sort),
		ytitle("Scoring Margin") 
		xtitle("Predicted Scoring Margin") 
		title("Actual vs. Predicted Scoring Margin") 
		subtitle("Fixed Effects Model - `year' Season") 
		legend(label(2 "95% Confidence Interval"))
		saving("$graphs\predictedActualMargin`year'", replace);
	graph export "$graphs\PDFs\predictedActualMargin`year'.pdf", replace;
	graph export "$graphs\PNGs\predictedActualMargin`year'.png", replace;
	
	//Figure 2
	twoway (scatter res hat, msize(small) msymbol(smcircle)), 
		yscale(range(-50 50))
		ytitle("Residuals") 
		xtitle("Predicted Scoring Margin") 
		title("Residual Plot")
		subtitle("Fixed Effects Model - `year' Season") 
		saving("$graphs\residualPlotFE`year'", replace);
	graph export "$graphs\PDFs\residualPlotFE`year'.pdf", replace;
	graph export "$graphs\PNGs\residualPlotFE`year'.png", replace;
	
	# delimit cr
		
}

log close

*****************************************************************************
//create regression table in Appendix
clear
capture eststo clear

foreach year in 2014 2015 2016 {
use "$data\allData"
eststo: qui regress margin teamHome teamAway if season==`year'
clear
use "$data\allDataHH"
eststo: qui regress matchupMarginDiff teamHome if season==`year'
clear
use "$data\allData"
eststo: qui regress margin teamHome teamAway i.teamFactor i.opponentFactor ///
 if season==`year'
clear

}

use "$data\allData"
eststo: qui regress margin teamHome teamAway
clear
use "$data\allDataHH"
eststo: qui regress matchupMarginDiff teamHome

esttab using "$regs\appendixRegTable.csv", replace nostar nogaps onecell se ///
	keep(teamHome teamAway _cons) ///
	mtitles("2013-14 Naive" "2013-14 Within" "2013-14 FE"  ///
			"2014-15 Naive" "2014-15 Within" "2014-15 FE"  ///
			"2015-16 Naive" "2015-16 Within" "2015-16 FE"  ///
			"2013-2016 Naive" "2013-2016 Within")
			
			
eststo clear

*****************************************************************************
//export 2016 fixed effects data to Matlab for win probability analysis
clear
use "$data\allData"
drop if season != 2016
	
regress margin teamHome teamAway i.teamFactor i.opponentFactor
	
predict predMargin
predict res, res
predict stdf, stdf

gen predMarginNeutral = predMargin
replace predMarginNeutral = predMargin - _b[teamAway] if teamAway==1
replace predMarginNeutral = predMargin - _b[teamHome] if teamHome==1

gen teamHomeCoef = _b[teamHome]

keep predMarginNeutral stdf teamHomeCoef

export excel using "$matlab\winProbData.xlsx", firstrow(variables) sheetreplace



