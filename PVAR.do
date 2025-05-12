clear all
import excel "C:\Users\Frank\Desktop\dt1.xlsx", sheet("Sheet1") firstrow
egen id=group(Country)
xtset id Time
/*单位根检验*/
global pos_var lnCRI GPRC V_WTI V_BNG
foreach i in $pos_var {
xtunitroot llc `i',trend demean
xtunitroot ips `i',trend demean
xtunitroot ht `i',trend demean
xtunitroot fisher `i',trend pperron demean lags(1)
xtunitroot fisher `i',trend dfuller demean lags(1)
}


/*协整性检验*/
xtcointtest westerlund lnCRI GPRC V_WTI V_BNG,trend
xtcointtest pedroni lnCRI GPRC V_WTI V_BNG,trend
xtcointtest kao lnCRI GPRC V_WTI V_BNG

/*最优阶数确定*/
pvarsoc lnCRI GPRC V_WTI V_BNG,maxlag(4) pvaropts(instl(1/5))

/*GMM回归*/
pvar lnCRI GPRC V_WTI V_BNG,lag(1) fd overid instlags(1/3) gmmstyle vce(r)
estimate store gmm
esttab gmm using 回归结果1.rtf, r2 ar2 se replace nogap mtitles("gmm") b(%9.2f) star(* 0.1 ** 0.05 *** 0.01)

/*格兰因果与稳健性*/
pvargranger
pvarstable
pvarstable,graph
graph save "Graph" "C:\Users\Frank\Desktop\Graph.gph", replace
/*脉冲响应*/
qui pvar lnCRI GPRC V_WTI V_BNG,lag(1) fd overid instlags(1/3) gmmstyle vce(r)
pvarirf,step(8) mc(500) byoption(yrescale) yline(0, lcolor(black) lpattern("-"))
graph save "Graph" "C:\Users\Frank\Desktop\Graph.gph", replace
/*方差分解*/
pvarfevd
