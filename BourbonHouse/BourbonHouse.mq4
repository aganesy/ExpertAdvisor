//# vim:set foldmethod=marker:
// Copylith {{{
//+------------------------------------------------------------------+
//|                                                 BourbonHouse.mq4 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property strict
// }}}

// グローバル変数{{{
int		g_nPreOrderTime				= 0;

double	g_dFirstPriceDiffBorder		= 0.0;
double	g_dPriceDiffBorder			= 0.0;
double	g_dSLSeed					= 0.0;

/*
int		g_nOrderIndex[300]	= {-1};
double	g_dOpenPrice[300]	= {0};
double	g_dPrePrice[300]	= {0};
*/

struct POSITION_INFO
{
	int nOrderIndex;
	double dOpenPrice;
	double dPrePrice;
};
POSITION_INFO g_stPositionInfoList[3000];
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
}//}}}

void OrderJudge()//{{{
{
	// オーダーのトータルがXXX以下ですか
	//if ( OrdersTotal() <= 98 )	// FXDD
	//if ( OrdersTotal() <= 198 )	// PepperSton
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
				//Print("Faild Oder Select. Position No:", g_stPositionInfoList[i].nOrderIndex, ", Indx:", i);
				InitializePositionInfo( i );
			}
			else
			{
				bool bIsFirst = false;
				if ( !( g_stPositionInfoList[i].dPrePrice > 0 ) )
				{
					bIsFirst = true;
				}
				
				double dFirstPriceDiff;
				double dPriceDiff;
				double dNewSLPrice;
				
				RefreshRates();
				switch ( OrderType() )
				{
				case OP_BUY:
				case OP_BUYLIMIT:
				case OP_BUYSTOP:
					dFirstPriceDiff	= Bid - g_stPositionInfoList[i].dOpenPrice;
					dPriceDiff		= Bid - g_stPositionInfoList[i].dPrePrice;
					dNewSLPrice		= Bid - g_dSLSeed;
					
					break;
				
				case OP_SELL:
				case OP_SELLLIMIT:
				case OP_SELLSTOP:
					dFirstPriceDiff	= g_stPositionInfoList[i].dOpenPrice - Ask;
					dPriceDiff		= g_stPositionInfoList[i].dPrePrice - Ask;
					dNewSLPrice		= g_dSLSeed + Ask;
					
					break;
				}
				
				if ( !bIsFirst )
				{
					if ( dPriceDiff >= g_dPriceDiffBorder )
					{
						if ( OrderStopLoss() > 0 )
						{
							if ( OrderModify( OrderTicket(), OrderOpenPrice(), dNewSLPrice, 0, 0, Blue ) )
							{
								g_stPositionInfoList[i].dPrePrice = ( OrderType() == OP_BUY || OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP ) ? Ask : Bid;
							}
						}
					}
				}
				else if ( dFirstPriceDiff >= g_dFirstPriceDiffBorder )
				{
					if ( OrderModify( OrderTicket(), OrderOpenPrice(), dNewSLPrice, 0, 0, Blue ) )
					{
						g_stPositionInfoList[i].dPrePrice = ( OrderType() == OP_BUY || OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP ) ? Ask : Bid;
					}
				}
			}
		}
	}
}//}}}

bool OpenBuy( void )//{{{
{
	bool bResult = false;
	
	for ( int i = 0; i < ArrayRange( g_stPositionInfoList, 0 ); i++ )
	{
		if ( g_stPositionInfoList[i].nOrderIndex == -1 )
		{
			if ( OrderSend( Symbol(), OP_BUY,  0.01, Ask, 3, 0, 0, "Buy",  i, 0, Blue ) )
			{
				//OrderSelect( OrdersTotal() - 1, SELECT_BY_POS, MODE_TRADES );
				//OrderModify( OrderTicket(), OrderOpenPrice(), 0, OrderOpenPrice() + g_dFirstPriceDiffBorder, 0, Blue );
				g_stPositionInfoList[i].nOrderIndex = OrdersTotal() - 1;
				g_stPositionInfoList[i].dOpenPrice = Ask;
				g_stPositionInfoList[i].dPrePrice = 0;
				
				Print("Order Send Success! Indx:", i, ", Position No:",g_stPositionInfoList[i].nOrderIndex, ", Open Price:", g_stPositionInfoList[i].dOpenPrice);
				
				bResult = true;
			}
			
			break;
		}
	}
	
	return bResult;
}//}}}

bool OpenSell( void )//{{{
{
	bool bResult = false;
	
	for ( int i = 0; i < ArrayRange( g_stPositionInfoList, 0 ); i++ )
	{
		if ( g_stPositionInfoList[i].nOrderIndex == -1 )
		{
			if ( OrderSend( Symbol(), OP_SELL,  0.01, Bid, 3, 0, 0, "Sell",  i, 0, Red ) )
			{
				//OrderSelect( OrdersTotal() - 1, SELECT_BY_POS, MODE_TRADES );
				//OrderModify( OrderTicket(), OrderOpenPrice(), 0, OrderOpenPrice() - g_dFirstPriceDiffBorder, 0, Red );
				g_stPositionInfoList[i].nOrderIndex = OrdersTotal() - 1;
				g_stPositionInfoList[i].dOpenPrice = Bid;
				g_stPositionInfoList[i].dPrePrice = 0;
				
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
	g_stPositionInfoList[nIndex].dOpenPrice		= 0.0;
	g_stPositionInfoList[nIndex].dPrePrice		= 0.0;
}//}}}

bool InitializeCurrency()//{{{
{
	bool bResult = true;
	
	if( Symbol()=="AUDJPY" )
	{
		g_dFirstPriceDiffBorder	= 0.013;
		g_dPriceDiffBorder		= 0.001;
		g_dSLSeed				= 0.010;
	}
	else if( Symbol()=="CADJPY" )
	{
		g_dFirstPriceDiffBorder	= 0.013;
		g_dPriceDiffBorder		= 0.001;
		g_dSLSeed				= 0.010;
	}
	else if( Symbol()=="EURJPY" )
	{
		g_dFirstPriceDiffBorder	= 0.015;
		g_dPriceDiffBorder		= 0.001;
		g_dSLSeed				= 0.013;
	}
	else if( Symbol()=="GBPJPY" )
	{
		g_dFirstPriceDiffBorder	= 0.013;
		g_dPriceDiffBorder		= 0.001;
		g_dSLSeed				= 0.010;
	}
	else if( Symbol()=="USDJPY" )
	{
		g_dFirstPriceDiffBorder	= 0.013;
		g_dPriceDiffBorder		= 0.001;
		g_dSLSeed				= 0.010;
	}
	else if( Symbol()=="EURGBP" )
	{
		g_dFirstPriceDiffBorder	= 0.00013;
		g_dPriceDiffBorder		= 0.00001;
		g_dSLSeed				= 0.00010;
	}
	else if( Symbol()=="EURTRY" )
	{
		g_dFirstPriceDiffBorder	= 0.00013;
		g_dPriceDiffBorder		= 0.00001;
		g_dSLSeed				= 0.00010;
	}
	else if( Symbol()=="EURUSD" )
	{
		g_dFirstPriceDiffBorder	= 0.00013;
		g_dPriceDiffBorder		= 0.00001;
		g_dSLSeed				= 0.00010;
	}
	else
	{
		bResult = false;
	}
	
	return bResult;
}//}}}

