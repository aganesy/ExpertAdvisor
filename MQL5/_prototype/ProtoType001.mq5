//# vim:set foldmethod=marker:
// Copylith//{{{
//+------------------------------------------------------------------+
//|                                                 ProtoType001.mq5 |
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

CPositionInfo *g_cPosition;
//CTimeStamp *tm;

extern double Ask;
extern double Bid;


uint   g_unStoplossPips = 70;
uint   g_unReleasePips = 20;
uint   g_unBorderPips = 20;


// 構造体定義 //{{{
struct ChartInfomation
{
	double open;
	double close;
	double high;
	double low;
	double moving; // 終値 - 始値（ローソクの縦幅のこと）
};
//}}}

int OnInit()//{{{
{
	Print("OnInit");
	g_cPosition = new CPositionInfo();
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
	if (g_cPosition != NULL)
	{
		uint unCloseCode = 0;
		if (g_cPosition.OvserveStopLoss())
		{
			unCloseCode = 1;
		}
		else if (g_cPosition.OvserveReleasePrice())
		{
			unCloseCode = 2;
		}
		else if (g_cPosition.OvserveTakeProfit())
		{
			unCloseCode = 3;
		}
		
		if (unCloseCode > 0)
		{
			// まずはクローズ
			ulong ulCloseType = g_cPosition.GetOrderType();
			g_cPosition.Close();
			delete g_cPosition;
			g_cPosition = NULL;
			
			// すぐに次のオープン準備
			g_cPosition = new CPositionInfo();
			bool   bIsOpen = false;
			ulong  ulOpenType = 0;
			double dOpenPrice = 0.0;
			double dSlPrice = 0.0;
			double dReleasePrice = 0.0;
			
			// TPやリリースでクローズしたときには、反転のポジションをオープンする
			// 案1)SLでクローズしたときには、同じ向きのポジションをオープンする ←これが未実装 ←2020/09/08実装
			// 案2)SLを小さく設定しておき、これでクローズしたら逆向きのポジションをオープンする ←2020/09/08実装
			switch (ENUM_ORDER_TYPE(ulCloseType))
			{
				case ORDER_TYPE_BUY:
				switch (unCloseCode)
				{
					case 1:
					//ulOpenType = ORDER_TYPE_BUY; // 案1
					ulOpenType = ORDER_TYPE_SELL; // 案2
					break;
					
					case 2:
					case 3:
					ulOpenType = ORDER_TYPE_SELL;
				}
				break;
					
				case ORDER_TYPE_SELL:
				switch (unCloseCode)
				{
					case 1:
					//ulOpenType = ORDER_TYPE_SELL; // 案1
					ulOpenType = ORDER_TYPE_BUY; // 案2
					break;
					
					case 2:
					case 3:
					ulOpenType = ORDER_TYPE_BUY;
				}
				break;
			}
			
			switch (ENUM_ORDER_TYPE(ulOpenType))
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
			
			bIsOpen = g_cPosition.Open(ENUM_ORDER_TYPE(ulOpenType), 0.01, dOpenPrice, dSlPrice, 0);
			if (bIsOpen)
			{
				g_cPosition.SetReleasePrice(dReleasePrice);
				g_cPosition.SetReleaseBorderPips(g_unBorderPips);
			}
		}
	}
}//}}}

void ObserveOpen()//{{{
{
	OpenTest();
	//OpenTrello();
	//OpenTrap();
}//}}}

void OpenTest()//{{{
{
	CTimeStamp tm(TimeCurrent());
	if (tm.GetSesond() % 30 == 0)
	{
		if (g_cPosition == NULL)
		{
			g_cPosition = new CPositionInfo();
		}
		//g_cPosition.Open(OP_BUY, 0.01, Ask, Ask - PIPS(300), Ask + PIPS(10));
		//g_cPosition.Open(OP_BUY, 0.01, Ask, 0, Ask + PIPS(5));
		//g_cPosition.Open(OP_SELL, 0.01, Bid, Bid + PIPS(100), 0.0);
		
		bool bIsOpen = g_cPosition.Open(OP_BUY, 0.01, Ask, Ask - PIPS(g_unStoplossPips), 0);
		if (bIsOpen)
		{
			g_cPosition.SetReleasePrice(Ask + PIPS(g_unReleasePips));
			g_cPosition.SetReleaseBorderPips(g_unBorderPips);
		}
	}
	/*
	if (g_cPosition != NULL)
	{
		if (g_cPosition.GetReleasePrice() <= 0.0 || g_cPosition.GetReleaseBorderPips() <= 0.0)
		{
			double dOrderPrice = g_cPosition.GetOrderPrice();
			// 現在価格が、BUYのオープン価格よりも20pips上回った場合、リリースの監視を開始。
			if (Bid > dOrderPrice + PIPS(20))
			{
				g_cPosition.SetReleasePrice(Bid - PIPS(5));
				g_cPosition.SetReleaseBorderPips(5);
				g_cPosition.DrawStopLossLine(Bid - PIPS(5));
			}
		}
	}
	*/
}//}}}

void OpenTrello()//{{{
{
	// 直近5本のローソクの値を取得しておく。
	ChartInfomation stChartFive[5];
	for (int i = 0; i < 5; i++){
		stChartFive[i].open = iOpen(Symbol(), Period(), i);
		stChartFive[i].close = iClose(Symbol(), Period(), i);
		stChartFive[i].high = iHigh(Symbol(), Period(), i);
		stChartFive[i].low = iLow(Symbol(), Period(), i);
		stChartFive[i].moving = stChartFive[i].close - stChartFive[i].open;
	}
	
	// Trelloのメモより
	// 直近5本の計算結果の合算が0に近いとき、折返しが近いと判定することも可能と推測。
	double moving_sum = 0.0;
	for (int i = 0; i < 5; i++){
		moving_sum += stChartFive[i].moving;
	}
	
	// ToDo
	// 現在、どちらの向きでチャートが推移しているのか判定し、状態を変数に持っておく。
	// 折返し判定でtrueとなった場合には、チャートの反転（or停滞）を状態変数に保持する。
	// 同時に、ポジションをOpenする。（これはObserveOpenにて実装する。）
	// 同時に、ポジションをCloseする。（これはObserveCloseにて実装する。）
	
}//}}}

void OpenTrap()//{{{
{
	
}//}}}
