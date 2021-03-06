//# vim:set foldmethod=marker:
// Copylith//{{{
//+------------------------------------------------------------------+
//|                                                test_position.mq4 |
//|                                   Copyright 2018, SENAGA Yusuke. |
//|                                       aganesy.personal@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, SENAGA Yusuke."
#property link      "aganesy.personal@gmail.com"
#property version   "1.00"
#property strict

// 外部参照//{{{
// MyInclude
#include "..\_common\_Include\Define.mqh"
#include "..\_common\_Include\PositionInfo.mqh"
#include "..\_common\_Include\TimeStamp.mqh"
//}}}

CPositionInfo *position;
//CTimeStamp *tm;
	
int OnInit()//{{{
{
	Print("OnInit");
	position = new CPositionInfo();
	//tm = new CTimeStamp();
	return(INIT_SUCCEEDED);
}//}}}

void OnDeinit(const int reason)//{{{
{
	Print("OnDeInit");
	delete position;
	//delete tm;
}//}}}

void OnTick()//{{{
{
	if (position != NULL){
		if (position.OvserveStopLoss()){
			position.Close();
			delete position;
		}
		if (position.OvserveTakeProfit()){
			position.Close();
			delete position;
		}
	}
	
	CTimeStamp tm(TimeCurrent());
	if (tm.GetYear() == 2020 && tm.GetMonth() == 6 && tm.GetDay() == 20 && tm.GetHour() == 18 && tm.GetMinute() == 30 && tm.GetSesond() == 28){
		position.Open(OP_BUY, 0.01, Ask - 0.1, Ask + 0.01);
	}
	if (tm.GetYear() == 2020 && tm.GetMonth() == 6 && tm.GetDay() == 20 && tm.GetHour() == 19 && tm.GetMinute() == 30 && tm.GetSesond() == 28){
		//position.Close();
	}
}//}}}

