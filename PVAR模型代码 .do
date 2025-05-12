*方法一
cd C:\Users\Administrator\Desktop\pvar                          /*----指定默认路径，一般为代码和数据存放的位置----*/
use data1.dta,clear     /*----打开指定路径下的数据文件----*/
xtset id year
xtdes
xtsum y x1 x2 x3 x4 x5 x6 x7

//单位根检验方法很多：LLC、IPS、HT、ADF、PP（每个变量要分开做，如有y x1 x2 三个变量，则需要分别将y改成x1或x2，以下方法任选三到四种）
xtunitroot llc y, trend demean 
xtunitroot ips y, trend demean 
xtunitroot ht y, trend demean 
xtunitroot fisher y, trend dfuller demean lags(1)
xtunitroot fisher y, trend pperron demean lags(1)

//一阶差分,原数据若不平稳的变量多，则可统一做一阶差分。若只是小部分不平稳，可将不平稳数据进行一阶差分处理，也可将全部变量一阶差分（推荐此做法）。正常一阶差分后数据几乎全部平稳，若一阶不平稳，考虑变量选取是否合理。考虑是否做二阶
gen dy=D.y

//二阶差分，同理，若一阶差分仍然不平稳，若不平稳的变量多，则可统一做二阶差分。若只是小部分不平稳，则将不平稳数据进行差分处理，也可全部二阶差分
gen ddy=D2.y


//一阶差分的平稳性检验（道理跟上面一样，任选三到四种，每个变量分开做）
xtunitroot llc dy, trend demean 
xtunitroot ips dy, trend demean 
xtunitroot ht dy, trend demean 
xtunitroot fisher dy, trend dfuller demean lags(1)
xtunitroot fisher dy, trend pperron demean lags(1)

//二阶差分平稳性检验
xtunitroot llc ddy, trend demean 
xtunitroot ips ddy, trend demean 
xtunitroot ht ddy, trend demean 
xtunitroot fisher ddy, trend dfuller demean lags(1)
xtunitroot fisher ddy, trend pperron demean lags(1)

**协整检验，检验是否长期平稳，主要方法有kao、westerlund、pedroni等
xtcointtest kao ddy x1 x2 x3 x4
xtcointtest westerlund ddy x1 x2,trend
xtcointtest pedroni ddy x1 x2,trend
//也可不做协整检验

**最优阶数确定，看BIC AIC QIC，值越小越好，看哪一阶的最小值最多，选哪一个
pvarsoc ddy x1 x2 ,maxlag(2)  pvaropts(instl(1/3))
//前面写4，后面就写5。同理前面写5，后面写6。一般研究期限比较短数字就不能太大

**GMM估计
pvar ddy x1 x2,lags(2)

**稳定性检验（单位根证明最优滞后阶数选择的正确性）
pvarstable,graph
graph save fig1.gph,replace

**格兰杰因
pvargranger

**脉冲响应（表示各个变量受到一个单位标准差的冲击后对pvar系统造成的影响。即自变量变动1个单位对应变量的影响
pvarirf,byopt(yrescale) title() 
graph save fig2.gph ,replace
//上下两条虚线为置信95%区间

**方差分解
pvarfevd



*方法二
*上面方法一是一套完整的， 当上面方法一的最优阶数确定、GMM估计、格兰杰因不行时可以用方法二替代
*但方法二的脉冲响应用完之后，后面的方差分解就运行不出来，最好不要用方法二的脉冲响应，方法二的方差分解我这边是运行不了的，看看你们自己能不能用。
 
*最优阶数确定*方法二
pvar2 ddy x1 x2,lag(2) soc

**GMM估计*方法二
pvar ddy x1 x2,lags(2)

**格兰杰因*方法二
pvar2 ddy x1 x2,lag(3) granger

**脉冲响应*方法二
pvar2  ddy x1 x2,lag(3) irf(10) 

*方差分解
pvar2 x1 x2,lag(3) decomp(10)
