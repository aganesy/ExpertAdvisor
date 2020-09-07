//+------------------------------------------------------------------+
//|                                                       Define.mqh |
//|                                   Copyright 2013, SENAGA Yusuke. |
//|                                               mi081321@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, SENAGA Yusuke."
#property link      "mi081321@gmail.com"

//--- Declaration of constants
#define OP_BUY 0           //Buy 
#define OP_SELL 1          //Sell 
#define OP_BUYLIMIT 2      //Pending order of BUY LIMIT type 
#define OP_SELLLIMIT 3     //Pending order of SELL LIMIT type 
#define OP_BUYSTOP 4       //Pending order of BUY STOP type 
#define OP_SELLSTOP 5      //Pending order of SELL STOP type 
//---
#define MODE_OPEN 0
#define MODE_CLOSE 3
#define MODE_VOLUME 4 
#define MODE_REAL_VOLUME 5
#define MODE_TRADES 0
#define MODE_HISTORY 1
#define SELECT_BY_POS 0
#define SELECT_BY_TICKET 1
//---
#define DOUBLE_VALUE 0
#define FLOAT_VALUE 1
#define LONG_VALUE INT_VALUE
//---
#define CHART_BAR 0
#define CHART_CANDLE 1
//---
#define MODE_ASCEND 0
#define MODE_DESCEND 1
//---
#define MODE_LOW 1
#define MODE_HIGH 2
#define MODE_TIME 5
#define MODE_BID 9
#define MODE_ASK 10
#define MODE_POINT 11
#define MODE_DIGITS 12
#define MODE_SPREAD 13
#define MODE_STOPLEVEL 14
#define MODE_LOTSIZE 15
#define MODE_TICKVALUE 16
#define MODE_TICKSIZE 17
#define MODE_SWAPLONG 18
#define MODE_SWAPSHORT 19
#define MODE_STARTING 20
#define MODE_EXPIRATION 21
#define MODE_TRADEALLOWED 22
#define MODE_MINLOT 23
#define MODE_LOTSTEP 24
#define MODE_MAXLOT 25
#define MODE_SWAPTYPE 26
#define MODE_PROFITCALCMODE 27
#define MODE_MARGINCALCMODE 28
#define MODE_MARGININIT 29
#define MODE_MARGINMAINTENANCE 30
#define MODE_MARGINHEDGED 31
#define MODE_MARGINREQUIRED 32
#define MODE_FREEZELEVEL 33
//---
#define EMPTY -1

ENUM_TIMEFRAMES TFMigrate(int tf)
{
    switch(tf)
    {
        case 0: return(PERIOD_CURRENT);
        case 1: return(PERIOD_M1);
        case 5: return(PERIOD_M5);
        case 15: return(PERIOD_M15);
        case 30: return(PERIOD_M30);
        case 60: return(PERIOD_H1);
        case 240: return(PERIOD_H4);
        case 1440: return(PERIOD_D1);
        case 10080: return(PERIOD_W1);
        case 43200: return(PERIOD_MN1);
        
        case 2: return(PERIOD_M2);
        case 3: return(PERIOD_M3);
        case 4: return(PERIOD_M4);      
        case 6: return(PERIOD_M6);
        case 10: return(PERIOD_M10);
        case 12: return(PERIOD_M12);
        case 16385: return(PERIOD_H1);
        case 16386: return(PERIOD_H2);
        case 16387: return(PERIOD_H3);
        case 16388: return(PERIOD_H4);
        case 16390: return(PERIOD_H6);
        case 16392: return(PERIOD_H8);
        case 16396: return(PERIOD_H12);
        case 16408: return(PERIOD_D1);
        case 32769: return(PERIOD_W1);
        case 49153: return(PERIOD_MN1);      
        default: return(PERIOD_CURRENT);
    }
}

extern double Ask;
extern double Bid;

void UpdateChartInfomation()
{
    MqlTick last_tick;
    //---
    if(SymbolInfoTick(Symbol(),last_tick))
    {
        //Print(last_tick.time,": Bid = ",last_tick.Bid,
        //" Ask = ",last_tick.ask,"  Volume = ",last_tick.volume);
        Ask = last_tick.ask;
        Bid = last_tick.bid;
    }
    else {
        Print("SymbolInfoTick() failed, error = ",GetLastError());
    }
}
