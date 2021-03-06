//# vim:set foldmethod=marker:
// Copylith//{{{
//+------------------------------------------------------------------+
//|                                           test_position_list.mq4 |
//|                                   Copyright 2018, SENAGA Yusuke. |
//|                                       aganesy.personal@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, SENAGA Yusuke."
#property link      "aganesy.personal@gmail.com"
#property version   "1.00"
#property strict

// 外部参照//{{{

//Standard Library

// MyInclude
#include "..\_common\_Include\Define.mqh"

// MyLib
#include "..\_common\_Lib\PositionInfo.mq4"
#include "..\_common\_Lib\TimeStamp.mq4"
#include "..\_common\_Lib\TemplateArray.mq4"
//}}}


int OnInit()//{{{
{
	Print("OnInit");
	return(INIT_SUCCEEDED);
}//}}}

void OnDeinit(const int reason)//{{{
{
	Print("OnDeInit");
}//}}}

void OnTick()//{{{
{
	CArrayT<int> array;
	/*(
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
	*/
	OvservePosition();
	
	//CPositionInfo *position;
	CTimeStamp tm(TimeCurrent());
	if (tm.GetYear() == 2018 && tm.GetMonth() == 6 && tm.GetDay() == 20 && tm.GetHour() == 18 && tm.GetMinute() == 30 && tm.GetSesond() % 10 == 0){
		//position.Open(OP_BUY, 0.01, Ask - 0.3, Ask + 0.01);
	}
	if (tm.GetYear() == 2018 && tm.GetMonth() == 6 && tm.GetDay() == 20 && tm.GetHour() == 19 && tm.GetMinute() == 30 && tm.GetSesond() == 28){
		//position.Close();
	}
}//}}}

void OvservePosition()
{
/*
	for (int i = 0; i < plist.length(); i++){
		CPositionInfo *pBuffer = plist.GetElement(i);
		if (pBuffer != NULL){
			if (pBuffer.OvserveStopLoss()){
				pBuffer.Close();
				delete pBuffer;
				plist.erase(i);
			}
			if (pBuffer.OvserveTakeProfit()){
				pBuffer.Close();
				delete pBuffer;
				plist.erase(i);
			}
		}
	}
	*/
}