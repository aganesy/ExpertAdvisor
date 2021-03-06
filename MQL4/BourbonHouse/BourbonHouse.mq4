//# vim:set foldmethod=marker:
// Copylith {{{
//+------------------------------------------------------------------+
//|                                                 BourbonHouse.mq4 |
//|                              Copyright 2014-2015, SENAGA Yusuke. |
//|                                               mi081321@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014-2015, SENAGA Yusuke."
#property link      "mi081321@gmail.com"
#property version   "1.00"
#property strict
// }}}

// グローバル変数{{{
#define	SUCCESS					0x00000000
#define	ERROR_CLOSE_POSITIONS	0x00000001

int		LastError			= SUCCESS;
double	g_dTrapInterval		= 0.0;

struct TRAP_INFO
{
	int		nTicketNumber;
	double	dLot;
	double	dOpenPrice;
	double	dPrePrice;
};
TRAP_INFO g_stTrapInfoList[200];
//}}}

int OnInit()//{{{
{
	if (!InitializeCurrency())
	{
		Print("ERRER : This Currency is not supported : ",  Symbol());
		return (INIT_FAILED);
	}
	
	for (int i = 0; i < ArrayRange(g_stTrapInfoList, 0); i++){
		InitializePositionInfo(i);
	}
	for (int i = 0; i < ArrayRange(g_stTrapInfoList, 0); i += 2)
	{
		OpenBuy(i, g_dTrapInterval * (i / 2 + 1));
		OpenSell(i + 1, g_dTrapInterval * (i / 2 + 1));
	}
	LastError = SUCCESS;
	
	return(INIT_SUCCEEDED);
}//}}}

void OnDeinit(const int reason)//{{{
{

}//}}}

void OnTick()//{{{
{
	if (IsProfit())
	{
		if (CloseAllPositions())
		{
			for (int i = 0; i < ArrayRange(g_stTrapInfoList, 0); i += 2)
			{
				OpenBuy(i, g_dTrapInterval * (i / 2 + 1));
				OpenSell(i + 1, g_dTrapInterval * (i / 2 + 1));
			}
			LastError = SUCCESS;
		}
		else
		{
			LastError = ERROR_CLOSE_POSITIONS;
		}
	}
}//}}}

bool IsProfit()//{{{
{
	bool bResult = false;
	
	if (LastError == ERROR_CLOSE_POSITIONS)
	{
		bResult = true;
	}
	else
	{
		// ポジションをクローズしてよいか判定
		double dProfitSum	= 0.0;
		double dTPSeed		= 0.0;
		for (int i = 0; i < ArrayRange(g_stTrapInfoList, 0); i++)
		{
			if (OrderSelect(g_stTrapInfoList[i].nTicketNumber, SELECT_BY_TICKET, MODE_TRADES))
			{
				switch (OrderType())
				{
				case OP_BUY:
					dTPSeed = Bid - g_stTrapInfoList[i].dOpenPrice;
					break;
				
				case OP_SELL:
					dTPSeed = g_stTrapInfoList[i].dOpenPrice - Ask;
					break;
				
				default:
					dTPSeed = 0.0;
					break;
				}
				if (1)
				{
					dProfitSum += dTPSeed;
				}
			}
		}
		
		if (dProfitSum > g_dTrapInterval)
		{
			bResult = true;
		}
	}
	
	return bResult;
}//}}}

bool CloseAllPositions()//{{{
{
	bool bResult = true;

	// すべてのポジションをクローズする処理
	for (int i = 0; i < ArrayRange(g_stTrapInfoList, 0); i++)
	{
		if (OrderSelect(g_stTrapInfoList[i].nTicketNumber, SELECT_BY_TICKET, MODE_TRADES))
		{
			double dClosePrice = 0.0;
			bool bCloseResult = true;
			switch (OrderType())
			{
			case OP_BUY:
			//case OP_BUYLIMIT:
			//case OP_BUYSTOP:
				dClosePrice = Bid;
				bCloseResult = OrderClose(g_stTrapInfoList[i].nTicketNumber, g_stTrapInfoList[i].dLot, dClosePrice, Yellow);
				break;
			
			case OP_SELL:
			//case OP_SELLLIMIT:
			//case OP_SELLSTOP:
				dClosePrice = Ask;
				bCloseResult = OrderClose(g_stTrapInfoList[i].nTicketNumber, g_stTrapInfoList[i].dLot, dClosePrice, Green);
				break;
			
			default:
				bCloseResult = OrderDelete(g_stTrapInfoList[i].nTicketNumber, Black);
				break;
			}
			
			//if (/*ポジションのクローズに失敗したら*/)
			if (false == bCloseResult && ERR_INVALID_TICKET != GetLastError())
			{
				bResult = false;
			}
		}
	}
	
	return bResult;
}//}}}

bool OpenBuy(int nIndex, double dTrapPrice)//{{{
{
	//int nIndex = i - 1;

	bool bResult = false;
	
	if (OrderSend(Symbol(), OP_BUYSTOP,  0.01, Ask + dTrapPrice, 3, 0, 0, "Buy", nIndex, 0, Blue))
	{
		OrderSelect(OrdersTotal() - 1, SELECT_BY_POS, MODE_TRADES);
		//OrderModify(OrderTicket(), OrderOpenPrice(), 0, OrderOpenPrice() + g_dTrapInterval, 0, Blue);
		g_stTrapInfoList[nIndex].dLot = 0.01;
		g_stTrapInfoList[nIndex].nTicketNumber = OrderTicket();
		g_stTrapInfoList[nIndex].dOpenPrice = Ask + dTrapPrice;
		g_stTrapInfoList[nIndex].dPrePrice = 0;
		
		Print("Order Send Success! Index:", nIndex, ", Position No:",g_stTrapInfoList[nIndex].nTicketNumber, ", Open Price:", g_stTrapInfoList[nIndex].dOpenPrice);
		
		bResult = true;
	}
	
	
	return bResult;
}//}}}

bool OpenSell(int nIndex, double dTrapPrice)//{{{
{
	//int nIndex = i - 1;

	bool bResult = false;
	
	if (OrderSend(Symbol(), OP_SELLSTOP,  0.01, Bid - dTrapPrice, 3, 0, 0, "Sell", nIndex, 0, Red))
	{
		OrderSelect(OrdersTotal() - 1, SELECT_BY_POS, MODE_TRADES);
		//OrderModify(OrderTicket(), OrderOpenPrice(), 0, OrderOpenPrice() - g_dTrapInterval, 0, Red);
		g_stTrapInfoList[nIndex].dLot = 0.01;
		g_stTrapInfoList[nIndex].nTicketNumber = OrderTicket();
		g_stTrapInfoList[nIndex].dOpenPrice = Bid - dTrapPrice;
		g_stTrapInfoList[nIndex].dPrePrice = 0;
		
		Print("Order Send Success! Index:", nIndex, ", Position No:",g_stTrapInfoList[nIndex].nTicketNumber, ", Open Price:", g_stTrapInfoList[nIndex].dOpenPrice);
		
		bResult = true;
	}
	
	return bResult;
}//}}}

void InitializePositionInfo(int nIndex)//{{{
{
	g_stTrapInfoList[nIndex].nTicketNumber	= -1;
	g_stTrapInfoList[nIndex].dLot			= 0.0;
	g_stTrapInfoList[nIndex].dOpenPrice		= 0.0;
	g_stTrapInfoList[nIndex].dPrePrice		= 0.0;
}//}}}

bool InitializeCurrency()//{{{
{
	bool bResult = true;
	
	if(Symbol()=="AUDJPY")
	{
		g_dTrapInterval	= 0.010;
	}
	else if(Symbol()=="CADJPY")
	{
		g_dTrapInterval	= 0.010;
	}
	else if(Symbol()=="EURJPY")
	{
		g_dTrapInterval	= 0.010;
	}
	else if(Symbol()=="GBPJPY")
	{
		g_dTrapInterval	= 0.010;
	}
	else if(Symbol()=="USDJPY")
	{
		g_dTrapInterval	= 0.010;
	}
	else if(Symbol()=="EURGBP")
	{
		g_dTrapInterval	= 0.00010;
	}
	else if(Symbol()=="EURTRY")
	{
		g_dTrapInterval	= 0.00010;
	}
	else if(Symbol()=="EURUSD")
	{
		g_dTrapInterval	= 0.00010;
	}
	else
	{
		bResult = false;
	}
	
	return bResult;
}//}}}

