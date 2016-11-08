//main do-file for replication of Table 2 and Figures 1-3

//Preliminaries

//set home directory
global home "K:\Research\Projects\HomeCourt"

//establish other directories
global raw "$home\rawData"
global scripts "$home\StataScripts"
global data "$home\StataData"
global graphs "$home\StataGraphs"
global logs "$home\StataLogs"
global regs "$home\StataRegressionOutput"
global matlab "$home\Matlab"

set more off
capture log close

//assemble data
do "$scripts\assembleData.do"

//replicate analysis
do "$scripts\makeAnalysis.do"

//see m-file in Matlab folder to replicate Table 3 and Figure 4
