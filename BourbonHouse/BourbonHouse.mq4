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
double	g_dTrapInterval		= 0.0;

struct TRAP_INFO
{
	int		nOrderIndex;
	double	dOpenPrice;
	double	dPrePrice;
};
POSITION_INFO g_stTrapInfoListt[200];
//}}}

int OnInit()//{{{
{
	if ( !InitializeCurrency() )
	{
		Print( "ERRER : This Currency is not supported",  Symbol() );
		return ( INIT_FAILED );
	}
	
	for ( int i = 0; i < ArrayRange( g_stTrapInfoListt, 0 ); i++ ){
		InitializePositionInfo( i );
	}
	
	return( INIT_SUCCEEDED );
}//}}}

void OnDeinit( const int reason )//{{{
{

}//}}}

void OnTick()//{{{
{
	if ( IsClose() )
	{
		CloseAllPositions();
		
		for ( int i = 1; i <= ArrayRange( g_stTrapInfoListt, 0 ) / 2; i++ )
		{
			OpenBuy( g_dTrapInterval * i );
			OpenSell( g_dTrapInterval * i );
		}
	}
}//}}}

bool OpenBuy( double dTrapPrice )//{{{
{
	bool bResult = false;
	
	for ( int i = 0; i < ArrayRange( g_stTrapInfoListt, 0 ); i++ )
	{
		if ( g_stTrapInfoListt[i].nOrderIndex == -1 )
		{
			if ( OrderSend( Symbol(), OP_BUY,  0.01, Ask + dTrapPrice, 3, 0, 0, "Buy",  i, 0, Blue ) )
			{
				//OrderSelect( OrdersTotal() - 1, SELECT_BY_POS, MODE_TRADES );
				//OrderModify( OrderTicket(), OrderOpenPrice(), 0, OrderOpenPrice() + g_dTrapInterval, 0, Blue );
				g_stTrapInfoListt[i].nOrderIndex = OrdersTotal() - 1;
				g_stTrapInfoListt[i].dOpenPrice = Ask;
				g_stTrapInfoListt[i].dPrePrice = 0;
				
				Print( "Order Send Success! Indx:", i, ", Position No:",g_stTrapInfoListt[i].nOrderIndex, ", Open Price:", g_stTrapInfoListt[i].dOpenPrice );
				
				bResult = true;
			}
			
			break;
		}
	}
	
	return bResult;
}//}}}

bool OpenSell( double dTrapPrice )//{{{
{
	bool bResult = false;
	
	for ( int i = 0; i < ArrayRange( g_stTrapInfoListt, 0 ); i++ )
	{
		if ( g_stTrapInfoListt[i].nOrderIndex == -1 )
		{
			if ( OrderSend( Symbol(), OP_SELL,  0.01, Bid - dTrapPrice, 3, 0, 0, "Sell",  i, 0, Red ) )
			{
				//OrderSelect( OrdersTotal() - 1, SELECT_BY_POS, MODE_TRADES );
				//OrderModify( OrderTicket(), OrderOpenPrice(), 0, OrderOpenPrice() - g_dTrapInterval, 0, Red );
				g_stTrapInfoListt[i].nOrderIndex = OrdersTotal() - 1;
				g_stTrapInfoListt[i].dOpenPrice = Bid;
				g_stTrapInfoListt[i].dPrePrice = 0;
				
				Print( "Order Send Success! Indx:", i, ", Position No:",g_stTrapInfoListt[i].nOrderIndex, ", Open Price:", g_stTrapInfoListt[i].dOpenPrice );
				
				bResult = true;
			}
			
			break;
		}
	}
	
	return bResult;
}//}}}

void InitializePositionInfo( int nIndex )//{{{
{
	g_stTrapInfoListt[nIndex].nOrderIndex	= -1;
	g_stTrapInfoListt[nIndex].dOpenPrice	= 0.0;
	g_stTrapInfoListt[nIndex].dPrePrice		= 0.0;
}//}}}

bool InitializeCurrency()//{{{
{
	bool bResult = true;
	
	if( Symbol()=="AUDJPY" )
	{
		g_dTrapInterval	= 0.010;
	}
	else if( Symbol()=="CADJPY" )
	{
		g_dTrapInterval	= 0.010;
	}
	else if( Symbol()=="EURJPY" )
	{
		g_dTrapInterval	= 0.010;
	}
	else if( Symbol()=="GBPJPY" )
	{
		g_dTrapInterval	= 0.010;
	}
	else if( Symbol()=="USDJPY" )
	{
		g_dTrapInterval	= 0.010;
	}
	else if( Symbol()=="EURGBP" )
	{
		g_dTrapInterval	= 0.00010;
	}
	else if( Symbol()=="EURTRY" )
	{
		g_dTrapInterval	= 0.00010;
	}
	else if( Symbol()=="EURUSD" )
	{
		g_dTrapInterval	= 0.00010;
	}
	else
	{
		bResult = false;
	}
	
	return bResult;
}//}}}

