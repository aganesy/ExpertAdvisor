//# vim:set foldmethod=marker:
// Copylith//{{{
//+------------------------------------------------------------------+
//|                                                 ProtoTypeA003.mq5|
//|                                   Copyright 2020, SENAGA Yusuke. |
//|                                       aganesy.personal@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, SENAGA Yusuke."
#property link	  "aganesy.personal@gmail.com"
#property version   "1.00"
#property strict

// 外部参照//{{{
// MyInclude
#include "..\_common\_Include\Define.mqh"
#include "..\_common\_Include\initMQL4.mqh"

// MyLib
#include "..\_common\_Include\PositionInfo.mqh"
#include "..\_common\_Include\TimeStamp.mqh"
//}}}

#define CLOSED_STOP_LOSS    1
#define CLOSED_TAKE_PROFIT  2
#define CLOSED_RELEASE      3

#define TRAP_NONE               1
#define TRAP_SET                2
#define TRAP_CAUGHT             3
#define TRAP_RELEASE_WAITING    4

CPositionInfo *g_cPosition = NULL;
CPositionInfo *g_cTrapPositionLong = NULL;
CPositionInfo *g_cTrapPositionShort = NULL;
//CTimeStamp *tm;

extern double Ask;
extern double Bid;


uint    g_unStoplossPips    = 200;
uint    g_unReleasePips     = 50;
uint    g_unBorderPips      = 40;

uint    g_unTrapStatus      = TRAP_NONE;
ulong   g_ulOpenType = 0;
        
int OnInit()//{{{
{
	Print("OnInit");
	g_cPosition = new CPositionInfo();
	g_cTrapPositionLong = new CPositionInfo();
	g_cTrapPositionShort = new CPositionInfo();
	//tm = new CTimeStamp();
	return(INIT_SUCCEEDED);
}//}}}

void OnDeinit(const int reason)//{{{
{
	Print("OnDeInit");
	delete g_cPosition;
	//delete tm;
}//}}}

void OnTick()//{{{
{
	UpdateChartInfomation();
	ObserveClose();
	ObserveOpen();
	
}//}}}

void ObserveClose()//{{{
{
    if (g_unTrapStatus == TRAP_RELEASE_WAITING)
    {
    	if (g_cPosition != NULL)
    	{
    		uint unCloseCode = 0;
    		if (g_cPosition.OvserveStopLoss())
    		{
    			unCloseCode = CLOSED_STOP_LOSS;
    		}
    		else if (g_cPosition.OvserveReleasePrice())
    		{
    			unCloseCode = CLOSED_RELEASE;
    		}
    		else if (g_cPosition.OvserveTakeProfit())
    		{
    			unCloseCode = CLOSED_TAKE_PROFIT;
    		}
    		
    		if (unCloseCode > 0)
    		{
    			ulong ulCloseType = g_cPosition.GetOrderType();
    			if (g_cPosition.Close())
    			{
        			delete g_cPosition;
        			g_cPosition = NULL;
    			
        			g_unTrapStatus = TRAP_NONE;
        		}
    		}
    	}
	}
}//}}}

void ObserveOpen()//{{{
{
	CTimeStamp tm(TimeCurrent());
	
    // 以下の変数が必要
    // トラップの状態（グローバル、int）
    // 買いトラップの価格（double）
    // 売りトラップの価格（double）
	if (g_unTrapStatus == TRAP_NONE)
	{
	    // トラップを仕掛ける
	    uint unTrapBorderPips  = 100;
	    double dTrapLongPrice  = Bid - PIPS(50);
	    double dTrapShortPrice = Ask + PIPS(50);
	    
	    if (g_cTrapPositionLong == NULL)
	    {
	        g_cTrapPositionLong = new CPositionInfo();
	    }
	    if (g_cTrapPositionShort == NULL)
	    {
	        g_cTrapPositionShort = new CPositionInfo();
	    }
	    
        g_cTrapPositionLong.SetMagicNumber(9998);
	    g_cTrapPositionLong.SetFirstHurdlePrice(dTrapLongPrice);
    	g_cTrapPositionLong.SetReleaseBorderPips(unTrapBorderPips);
    	
        g_cTrapPositionShort.SetMagicNumber(9999);
	    g_cTrapPositionShort.SetFirstHurdlePrice(dTrapShortPrice);
    	g_cTrapPositionShort.SetReleaseBorderPips(unTrapBorderPips);
	    
	    // トラップの価格に線を描いておきましょう。
	    
	    g_unTrapStatus = TRAP_SET;
	}
	
	if (g_unTrapStatus == TRAP_SET)
	{
        	
	    // トラップに引っかかっているか判定する
	    if (g_cTrapPositionShort.OvserveReleasePrice())
	    {
		    g_ulOpenType = ORDER_TYPE_SELL;
	        g_unTrapStatus = TRAP_CAUGHT;
	    }
	    else if (g_cTrapPositionLong.OvserveReleasePrice())
	    {
		    g_ulOpenType = ORDER_TYPE_BUY;
	        g_unTrapStatus = TRAP_CAUGHT;
	    }
	}
	
	if (g_unTrapStatus == TRAP_CAUGHT)
	{
		delete g_cTrapPositionLong;
		g_cTrapPositionLong = NULL;
		delete g_cTrapPositionShort;
		g_cTrapPositionShort = NULL;
		
    	if (g_cPosition == NULL)
    	{
    	    g_cPosition = new CPositionInfo();
    	}
    	bool   bIsOpen = false;
    	double dOpenPrice = 0.0;
    	double dSlPrice = 0.0;
    	double dReleasePrice = 0.0;

		switch (ENUM_ORDER_TYPE(g_ulOpenType))
		{
			case ORDER_TYPE_BUY:
			dOpenPrice = Ask;
			dSlPrice = Ask - PIPS(g_unStoplossPips);
			dReleasePrice = Ask + PIPS(g_unReleasePips);
			break;
			
			case ORDER_TYPE_SELL:
			dOpenPrice = Bid;
			dSlPrice = Bid + PIPS(g_unStoplossPips);
	   		dReleasePrice = Bid - PIPS(g_unReleasePips);
			break;
		}
		
		bIsOpen = g_cPosition.Open(ENUM_ORDER_TYPE(g_ulOpenType), 0.01, dOpenPrice, dSlPrice, 0);
		if (bIsOpen)
		{
			g_cPosition.SetFirstHurdlePrice(dReleasePrice);
			g_cPosition.SetReleaseBorderPips(g_unBorderPips);
			
			g_unTrapStatus = TRAP_RELEASE_WAITING;
		}
		else{
    		delete g_cPosition;
		    g_unTrapStatus = TRAP_NONE;
		}
	}
}//}}}
