//+------------------------------------------------------------------+
//|                                             AmericanLemonade.mq4 |
//|                        Copyright 2014, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property strict


int		nPreOrderTime = 0.0;
int		nArrayOrderIndex[300] = {-1};
double		dArrayOpenPriceList[300] = {0};
double		dArrayPrePriceList[300] = {0};

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
//---
    nPreOrderTime = Seconds();
    
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
//---

}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
	OrderJudge();
	CloseTPJudge();
    
}

void OrderJudge()
{
	//--------------------------------------------- Order -> ---------------------------------------------
	// オーダーのトータルが98以下ですか
	if ( OrdersTotal() <= 98 )
	{
		// 証拠金維持率が 200% 以上ですか
		if ( ( AccountFreeMargin() * 1.1 ) > AccountBalance() )
		{
			// 前の取引から5秒以上経ちましたか
			if ( ( Seconds() + 60 - nPreOrderTime ) % 60 >= 5 )
			{
				if ( OpenBuy() )
				{
					OpenSell();
				}
			}
		}
	}
    
	nPreOrderTime = Seconds();
	//--------------------------------------------- <- Order ---------------------------------------------
}

void CloseTPJudge()
{
	for ( int i = 0; i < ArrayRange( nArrayOrderIndex, 0 ); i++ )
	{
		if ( nArrayOrderIndex[i] != -1 )
		{
			if ( !OrderSelect( nArrayOrderIndex[i], SELECT_BY_POS, MODE_TRADES ) )
			{
				nArrayOrderIndex[i] = -1;
			}
			else
			{
				RefreshRates();
				switch ( OrderType() )
				{
				case OP_BUY:
				case OP_BUYLIMIT:
				case OP_BUYSTOP:
					if ( dArrayPrePriceList[i] >= 0.1 )
					{
						if ( Bid - dArrayPrePriceList[i] >= 0.00001 )
						{
							if ( OrderStopLoss() >= 0.1 )
							{
								OrderModify( OrderTicket(), OrderOpenPrice(), Bid - 0.00010, 0, 0, Red );
								dArrayPrePriceList[i] = Bid;
							}
						}
					}
					else if ( Bid - dArrayOpenPriceList[i] >= 0.00013 )
					{
						OrderModify( OrderTicket(), OrderOpenPrice(), Bid - 0.00010, 0, 0, Red );
						dArrayPrePriceList[i] = Bid;
					}
					
		            break;
		            
				case OP_SELL:
				case OP_SELLLIMIT:
				case OP_SELLSTOP:
					if ( dArrayPrePriceList[i] >= 0.1 )
					{
			         	if ( dArrayPrePriceList[i] - Ask >= 0.00001 )
						{
							if ( OrderStopLoss() >= 0.1 )
							{
								OrderModify( OrderTicket(), OrderOpenPrice(), Ask + 0.00010, 0, 0, Blue );
								dArrayPrePriceList[i] = Ask;
							}
						}
					}
					else if ( dArrayOpenPriceList[i] - Ask >= 0.00015 )
					{
						OrderModify( OrderTicket(), OrderOpenPrice(), Ask + 0.00010, 0, 0, Blue );
						dArrayPrePriceList[i] = Ask;
					}
					
		            break;
				}
			}
		}
	}
}

bool OpenBuy( void )
{
	bool bResult = false;
	
	for ( int i = 0; i < ArrayRange( nArrayOrderIndex, 0 ); i++ )
	{
		if ( nArrayOrderIndex[i] == -1 )
		{
			if ( OrderSend( Symbol(), OP_BUY,  0.01, Ask, 3, 0, 0, "Buy",  i, 0, Blue ) )
			{
				OrderSelect( OrdersTotal() - 1, SELECT_BY_POS, MODE_TRADES );
				//OrderModify( OrderTicket(), OrderOpenPrice(), 0, OrderOpenPrice() + 0.00030, 0, Blue );
				dArrayOpenPriceList[i] = Ask;
				nArrayOrderIndex[i] = OrdersTotal() - 1;
				
				bResult = true;
			}
			
			break;
		}
	}
	
	return bResult;
}

bool OpenSell( void )
{
	bool bResult = false;
	
	for ( int i = 0; i < ArrayRange( nArrayOrderIndex, 0 ); i++ )
	{
		if ( nArrayOrderIndex[i] == -1 )
		{
			if ( OrderSend( Symbol(), OP_SELL,  0.01, Bid, 3, 0, 0, "Sell",  i, 0, Red ) )
			{
				OrderSelect( OrdersTotal() - 1, SELECT_BY_POS, MODE_TRADES );
				//OrderModify( OrderTicket(), OrderOpenPrice(), 0, OrderOpenPrice() - 0.00030, 0, Red );
				dArrayOpenPriceList[i] = Bid;
				nArrayOrderIndex[i] = OrdersTotal() - 1;
				
				bResult = true;
			}
			
			break;
		}
	}
	
	return bResult;
}

//+------------------------------------------------------------------+
