//# vim:set foldmethod=marker:
// Copylith {{{
//+------------------------------------------------------------------+
//|                                             AmericanLemonade.mq4 |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property strict
// }}}

// グローバル変数{{{
int		g_nPreOrderTime				= 0;

double	g_dFirstPriceDiffBorder		= 0.0;
double	g_dPriceDiffBorder			= 0.0;
double	g_dSLSeed					= 0.0;
double	g_dTPSeed					= 0.0;

struct TIME_INFO
{
	int nYear;
	int nMonth;
	int nDay;
	int nHour;
	int nMinute;
	int nSecond;
};

struct POSITION_INFO
{
	int nOrderIndex;
	double dOpenPrice;
	double dPrePrice;
	TIME_INFO TIME;
};
POSITION_INFO g_stPositionInfoList[1000];
//}}}

int OnInit()//{{{
{
	if ( !InitializeCurrency() )
	{
		Print( "ERRER : This Currency is not supported",  Symbol() );
		return ( INIT_FAILED );
	}
	
	for ( int i = 0; i < ArrayRange(g_stPositionInfoList, 0); i++ ){
		InitializePositionInfo( i );
	}
	
	g_nPreOrderTime = Seconds();
	
	return( INIT_SUCCEEDED );
}//}}}

void OnDeinit( const int reason )//{{{
{

}//}}}

void OnTick()//{{{
{
	// 前の取引から5秒以上経ちましたか
	if ( ( Seconds() + 60 - g_nPreOrderTime ) % 60 >= 5 )
	{
		OrderJudge();
	}
	g_nPreOrderTime = Seconds();
	
	SetStopLoss();
	CompulsoryOrderStop();
}//}}}

void OrderJudge()//{{{
{
	// オーダーのトータルがXXX以下ですか
	//if ( OrdersTotal() <= 98 )	// FXDD
	//if ( OrdersTotal() <= 198 )	// PepperStone
	if ( OrdersTotal() <= 998 )	// FXPro
	{
		// 証拠金維持率が 200% 以上ですか
		if ( ( AccountFreeMargin() * 1.1 ) > AccountBalance() )
		{
			if ( OpenBuy() )
			{
				OpenSell();
			}
		}
	}
}//}}}

void SetStopLoss()//{{{
{
	for ( int i = 0; i < ArrayRange( g_stPositionInfoList, 0 ); i++ )
	{
		if ( g_stPositionInfoList[i].nOrderIndex != -1 )
		{
			if ( !OrderSelect( g_stPositionInfoList[i].nOrderIndex, SELECT_BY_POS, MODE_TRADES ) )
			{
				//Print("Faild Oder Select. Position No:", g_stPositionInfoList[i].nOrderIndex, ", Index:", i);
				InitializePositionInfo( i );
			}
			/*
			else
			{
				bool bIsFirst = false;
				if ( !( g_stPositionInfoList[i].dPrePrice > 0 ) )
				{
					bIsFirst = true;
				}
				
				double dFirstPriceDiff	= 0.0;
				double dPriceDiff		= 0.0;
				double dNewSLPrice		= 0.0;
				
				RefreshRates();
				double dPreBid = 0.0;
				double dPreAsk = 0.0;
				
				switch ( OrderType() )
				{
				case OP_BUY:
				case OP_BUYLIMIT:
				case OP_BUYSTOP:
					dPreBid = Bid;
					dFirstPriceDiff	= Bid - g_stPositionInfoList[i].dOpenPrice;
					dPriceDiff		= Bid - g_stPositionInfoList[i].dPrePrice;
					dNewSLPrice		= Bid - g_dSLSeed;
					
					break;
				
				case OP_SELL:
				case OP_SELLLIMIT:
				case OP_SELLSTOP:
					dPreAsk = Ask;
					dFirstPriceDiff	= g_stPositionInfoList[i].dOpenPrice - Ask;
					dPriceDiff		= g_stPositionInfoList[i].dPrePrice - Ask;
					dNewSLPrice		= g_dSLSeed + Ask;
					
					break;
				}
				
				bool bSLResult = false;
				if ( !bIsFirst )
				{
					if ( dPriceDiff >= g_dPriceDiffBorder )
					{
						if ( OrderStopLoss() > 0 )
						{
							bSLResult = true;
						}
					}
				}
				else if ( dFirstPriceDiff >= g_dFirstPriceDiffBorder )
				{
					bSLResult = true;
				}
				
				if ( bSLResult )
				{
					// S/L 判定時とオーダーを投げる間の刹那に値段が変わってないか予防線
					RefreshRates();
					if ( ( dPreBid != 0.0 && Bid >= dPreBid ) || ( dPreAsk != 0.0 && Ask <= dPreAsk ) )
					{
						if ( OrderModify( OrderTicket(), OrderOpenPrice(), dNewSLPrice, 0, 0, Blue ) )
						{
							g_stPositionInfoList[i].dPrePrice = ( OrderType() == OP_BUY || OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP ) ? Bid : Ask;
						}
					}
				}
			}
			*/
		}
	}
}//}}}

void CompulsoryOrderStop()//{{{
{
	for ( int i = 0; i < ArrayRange( g_stPositionInfoList, 0 ); i++ )
	{
		if ( ( Day() + 30 - g_stPositionInfoList[i].TIME.nDay ) % 30 >= 15 )
		{
			if ( OrderSelect( g_stPositionInfoList[i].nOrderIndex, SELECT_BY_POS, MODE_TRADES ) )
			{
				switch ( OrderType() )
				{
				case OP_BUY:
				case OP_BUYLIMIT:
				case OP_BUYSTOP:
					OrderClose(OrderTicket(), OrderLots(), Bid, 3, Yellow);
					break;
					
				case OP_SELL:
				case OP_SELLLIMIT:
				case OP_SELLSTOP:
					OrderClose(OrderTicket(), OrderLots(), Ask, 3, Green);
					break;
				}
				
				g_stPositionInfoList[i].nOrderIndex	= -1;
				g_stPositionInfoList[i].dOpenPrice	= -1;
				g_stPositionInfoList[i].dPrePrice	= -1;
			}
		}
	}
}//}}}

bool OpenBuy()//{{{
{
	bool bResult = false;
	
	for ( int i = 0; i < ArrayRange( g_stPositionInfoList, 0 ); i++ )
	{
		if ( g_stPositionInfoList[i].nOrderIndex == -1 )
		{
			if ( OrderSend( Symbol(), OP_BUY,  0.01, Ask, 3, 0, 0, "Buy",  i, 0, Red ) )
			{
				OrderSelect( OrdersTotal() - 1, SELECT_BY_POS, MODE_TRADES );
				OrderModify( OrderTicket(), OrderOpenPrice(), 0, OrderOpenPrice() + g_dTPSeed, 0, Blue );
				g_stPositionInfoList[i].nOrderIndex = OrdersTotal() - 1;
				g_stPositionInfoList[i].dOpenPrice = Ask;
				g_stPositionInfoList[i].dPrePrice = 0;
				
				g_stPositionInfoList[i].TIME.nSecond = Seconds();
				g_stPositionInfoList[i].TIME.nMinute = Minute();
				g_stPositionInfoList[i].TIME.nHour = Hour();
				g_stPositionInfoList[i].TIME.nDay = Day();
				g_stPositionInfoList[i].TIME.nMonth = Month();
				g_stPositionInfoList[i].TIME.nYear = Year();
				
				Print("Order Send Success! Indx:", i, ", Position No:",g_stPositionInfoList[i].nOrderIndex, ", Open Price:", g_stPositionInfoList[i].dOpenPrice);
				
				bResult = true;
			}
			
			break;
		}
	}
	
	return bResult;
}//}}}

bool OpenSell()//{{{
{
	bool bResult = false;
	
	for ( int i = 0; i < ArrayRange( g_stPositionInfoList, 0 ); i++ )
	{
		if ( g_stPositionInfoList[i].nOrderIndex == -1 )
		{
			if ( OrderSend( Symbol(), OP_SELL,  0.01, Bid, 3, 0, 0, "Sell",  i, 0, Blue ) )
			{
				OrderSelect( OrdersTotal() - 1, SELECT_BY_POS, MODE_TRADES );
				OrderModify( OrderTicket(), OrderOpenPrice(), 0, OrderOpenPrice() - g_dTPSeed, 0, Red );
				g_stPositionInfoList[i].nOrderIndex = OrdersTotal() - 1;
				g_stPositionInfoList[i].dOpenPrice = Bid;
				g_stPositionInfoList[i].dPrePrice = 0;
				
				g_stPositionInfoList[i].TIME.nSecond = Seconds();
				g_stPositionInfoList[i].TIME.nMinute = Minute();
				g_stPositionInfoList[i].TIME.nHour = Hour();
				g_stPositionInfoList[i].TIME.nDay = Day();
				g_stPositionInfoList[i].TIME.nMonth = Month();
				g_stPositionInfoList[i].TIME.nYear = Year();
				
				Print("Order Send Success! Indx:", i, ", Position No:",g_stPositionInfoList[i].nOrderIndex, ", Open Price:", g_stPositionInfoList[i].dOpenPrice);
				
				bResult = true;
			}
			
			break;
		}
	}
	
	return bResult;
}//}}}

void InitializePositionInfo( int nIndex )//{{{
{
	g_stPositionInfoList[nIndex].nOrderIndex	= -1;
	g_stPositionInfoList[nIndex].dOpenPrice		= -1;
	g_stPositionInfoList[nIndex].dPrePrice		= -1;
}//}}}

bool InitializeCurrency()//{{{
{
	bool bResult = true;
	
	if( Symbol()=="AUDJPY" )
	{
		g_dFirstPriceDiffBorder	= 0.013;
		g_dPriceDiffBorder		= 0.001;
		g_dSLSeed				= 0.010;
		g_dTPSeed				= 0.010;
	}
	else if( Symbol()=="CADJPY" )
	{
		g_dFirstPriceDiffBorder	= 0.013;
		g_dPriceDiffBorder		= 0.001;
		g_dSLSeed				= 0.010;
		g_dTPSeed				= 0.010;
	}
	else if( Symbol()=="EURJPY" )
	{
		g_dFirstPriceDiffBorder	= 0.015;
		g_dPriceDiffBorder		= 0.001;
		g_dSLSeed				= 0.013;
		g_dTPSeed				= 0.010;
	}
	else if( Symbol()=="GBPJPY" )
	{
		g_dFirstPriceDiffBorder	= 0.013;
		g_dPriceDiffBorder		= 0.001;
		g_dSLSeed				= 0.010;
		g_dTPSeed				= 0.010;
	}
	else if( Symbol()=="USDJPY" )
	{
		g_dFirstPriceDiffBorder	= 0.013;
		g_dPriceDiffBorder		= 0.001;
		g_dSLSeed				= 0.010;
		g_dTPSeed				= 0.010;
	}
	else if( Symbol()=="EURGBP" )
	{
		g_dFirstPriceDiffBorder	= 0.00032;
		g_dPriceDiffBorder		= 0.00001;
		g_dSLSeed				= 0.00030;
		g_dTPSeed				= 0.00010;
	}
	else if( Symbol()=="EURTRY" )
	{
		g_dFirstPriceDiffBorder	= 0.00013;
		g_dPriceDiffBorder		= 0.00001;
		g_dSLSeed				= 0.00010;
		g_dTPSeed				= 0.00010;
	}
	else if( Symbol()=="EURUSD" )
	{
		g_dFirstPriceDiffBorder	= 0.00013;
		g_dPriceDiffBorder		= 0.00001;
		g_dSLSeed				= 0.00010;
		g_dTPSeed				= 0.00010;
	}
	else if( Symbol()=="GBPAUD" )
	{
		g_dFirstPriceDiffBorder	= 0.00032;
		g_dPriceDiffBorder		= 0.00001;
		g_dSLSeed				= 0.00030;
		g_dTPSeed				= 0.00030;
	}
	else
	{
		bResult = false;
	}
	
	return bResult;
}//}}}

