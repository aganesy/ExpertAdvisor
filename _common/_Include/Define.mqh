//+------------------------------------------------------------------+
//|                                                       Define.mqh |
//|                                   Copyright 2013, SENAGA Yusuke. |
//|                                               mi081321@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, SENAGA Yusuke."
#property link      "mi081321@gmail.com"


// Analytics Result
#define GOBUY			100
#define GOSELL			-100
#define BACK			-999
#define QUO				999

// Now Trend
#define TREND_LANGE		101
#define TREND_UP		102
#define TREND_DOWN		103

// OrderType
#define NON_ORDER		0
#define BUYS			1
#define SELLS			2

// Get Position Property
#define LOTBY			10000
#define MAX_LEVERAGE	200
#define ALL				1
#define HALF			2
#define QUAT			4

// Size
#define LONG_MAX_COUNT	0xFFFFFFF

double PIPS(int n)
{
	double ret = 0.0;
	
	     if (Symbol()=="USDJPY"){ret = n * 0.001;}
	else if (Symbol()=="EURJPY"){ret = n * 0.001;}
	else if (Symbol()=="GBPJPY"){ret = n * 0.001;}
	else if (Symbol()=="CHFJPY"){ret = n * 0.001;}
	else if (Symbol()=="CADJPY"){ret = n * 0.001;}
	else if (Symbol()=="AUDJPY"){ret = n * 0.001;}
	else if (Symbol()=="NZDJPY"){ret = n * 0.001;}
	else if (Symbol()=="EURAUD"){ret = n * 0.00001;}
	else if (Symbol()=="EURCAD"){ret = n * 0.00001;}
	else if (Symbol()=="EURCHF"){ret = n * 0.00001;}
	else if (Symbol()=="EURGBP"){ret = n * 0.00001;}
	else if (Symbol()=="EURNZD"){ret = n * 0.00001;}
	else if (Symbol()=="EURTRY"){ret = n * 0.00001;}
	else if (Symbol()=="EURUSD"){ret = n * 0.00001;}
	else if (Symbol()=="AUDCAD"){ret = n * 0.00001;}
	else if (Symbol()=="AUDCHF"){ret = n * 0.00001;}
	else if (Symbol()=="AUDUSD"){ret = n * 0.00001;}
	else if (Symbol()=="AUDNZD"){ret = n * 0.00001;}
	else if (Symbol()=="USDCAD"){ret = n * 0.00001;}
	else if (Symbol()=="USDCHF"){ret = n * 0.00001;}
	else if (Symbol()=="USDTRY"){ret = n * 0.00001;}
	else if (Symbol()=="GBPCAD"){ret = n * 0.00001;}
	else if (Symbol()=="GBPCHF"){ret = n * 0.00001;}
	else if (Symbol()=="GBPUSD"){ret = n * 0.00001;}
	else if (Symbol()=="CADCHF"){ret = n * 0.00001;}
	else if (Symbol()=="NZDUSD"){ret = n * 0.00001;}
	
	return ret;
}
