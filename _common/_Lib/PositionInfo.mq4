//# vim:set foldmethod=marker:
//+------------------------------------------------------------------+
//|                                                 PositionInfo.mq4 |
//|                                   Copyright 2015, SENAGA Yusuke. |
//|                                               mi081321@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, SENAGA Yusuke."
#property link      "mi081321@gmail.com"
#property library

#include "..\_Include\Define.mqh"
#include "TimeStamp.mq4"

class CPositionInfo //{{{
{
private:
	bool m_bIsSLRelease;
	bool m_bIsTKRelease;

	int m_nMagicNumber;
	int m_nTicketNumber;

	double m_dSLLevel;
	double m_dTPLevel;

	double m_dOrderPrice;
	double m_dSLPrice;
	double m_dTPPrice;

	string m_strOrderComment;

	CTimeStamp m_cTimeStamp;

public:
	CPositionInfo()
	{
		m_bIsSLRelease		= false;
		m_bIsTPRelease		= false;

		m_nMagicNumber		= 0;
		m_nTicketNumber		= 0;

		m_dSLLevel			= 0.0;
		m_dTPLevel			= 0.0;

		m_dOrderPrice		= 0.0;
		m_dSLPrice			= 0.0;
		m_dTPPrice			= 0.0;

		m_strOrderComment	= "";

		m_cTimeStamp		= new CTimeStamp();
	}
	~CPositionInfo()
	{
	}

	// Open
	bool Open(int orderType, double lots, string& comment = "", int slippage = 3, color arrowColor = Red)
	{
		bool bResult = false;
		if (lots == 0.0)
		{
			print("Warning Lot=0.0");
		}
		else
		{
			string strVarName = "";
			for (int i = 1; i < MAX_INT_COUNT; i++) {
				strVarName = DoubleToStr(i, 0);
				int nVarValue = GlobalVariableGet(strVarName);
				if (!nVarValue)
				{
					SetMagicNumber(i);
					break;
				}
			}

			double dOrderPrice = 0;
			if (GetMagicNumber())
			{
				switch (orderType)
				{
				case OP_BUY:
				case OP_BUYLIMIT:
				case OP_BUYSTOP:
					dOrderPrice = Ask;
					if (StringLen(comment) == 0)
					{
						comment = "Buy";
					}
					break;

				case OP_SELL:
				case OP_SELLLIMIT:
				case OP_SELLSTOP:
					dOrderPrice = Bid;
					if (StringLen(comment) == 0)
					{
						comment = "Sell";
					}
					break;

				default:
					break;
				}

				SetOrderPrice(dOrderPrice);
				SetOrderComment(comment);
				bResult = OrderSend(Symbol(), orderType, lots, GetOrderPrice(), slippage, 0, 0, GetOrderComment(), GetMagicNumber(), 0, arrowColor);

				OrderSelect(OrdersTotal() - 1, SELECT_BY_POS, MODE_TRADES);
				SetTicketNumber(OrderTicket());
				GlobalVariableSet(strVarName, 1);
			}
		}

		return bResult;
	}

	// Close
	bool Close(color arrowColor = Blue)
	{
		bool bResult = false;

		bool nOrderResult = OrderSelect(GetTicketNumber(), SELECT_BY_TICKET, MODE_TRADES);
		if (!nOrderResult)
		{
			print("Error Order select failed : ", GetLastError());
		}
		else
		{
			double dClosePrice = 0.0;
			switch (OrderType())
			{
			case OP_BUY:
			case OP_BUYLIMIT:
			case OP_BUYSTOP:
				dClosePrice = Bid;
				break;

			case OP_SELL:
			case OP_SELLLIMIT:
			case OP_SELLSTOP:
				dClosePrice = Ask;
				break;

			default:
				break;
			}

			bResult = OrderClose(GetTicketNumber(), OrderLots(), dClosePrice, 3, arrowColor);
		}

		return bResult;
	}

	// Stop Loss 監視
	bool OvserveStopLoss(double pips)
	{
		bool bResult = false;

		// GetOrderType から OrderType を取得
		int nOrderType = GetOrderType();
		// GetTicketNumber から 現在価格を取得（Bid or Ask）
		double dNowPrice = 0;
		// 現在価格と SLLevel を比較
		switch (nOrderType){
		case OP_BUY:
		case OP_BUYLIMIT:
		case OP_BUYSTOP:
			nNowPrice = Bid;
			// 現在価格が SL価格 + SLレベル より高い状態なら
			// 　→ 新しい SLPrice をセット
			// 　→ SLLevel を超えたフラグを立てる
			if (dNowPrice > m_dSLPrice + m_dSLLevel){
				m_dSLPrice = dNowPrice - m_dSLLevel;
				m_bIsSLRelease = true;
			}
			// フラグが立っている && 現在価格が SL価格 を割っている
			// 　→ リリースしましょう
			else if (m_bIsSLRelease && dNowPrice < m_dSLPrice){
				// リリースする
				bResult = true;
			}
			break;

		case OP_SELL:
		case OP_SELLLIMIT:
		case OP_SELLSTOP:
			nNowPrice = Ask;
			// 現在価格が SL価格 + SLレベル より低い状態なら
			// 　→ 新しい SLPrice をセット
			// 　→ SLLevel を超えたフラグを立てる
			if (dNowPrice < m_dSLPrice - m_dSLLevel){
				m_dSLPrice = dNowPrice + m_dSLLevel;
				m_bIsSLRelease = true;
			}
			// フラグが立っている && 現在価格が SL価格 を超えている
			// 　→ リリースしましょう
			else if (m_bIsSLRelease && dNowPrice > m_dSLPrice){
				// リリースする
				bResult = true;
			}
			break;

		default:
			break;
		}

		return bResult;
	}

	// Take Profit 監視
	bool OvserveTakeProfit(double pips)
	{
		bool bResult = true;

		// GetTicketNumber から OrderType を取得
		// GetTicketNumber から 現在価格を取得（Bid or Ask）
		// 現在価格と SLLevel を比較
		// TPLevel が現在価格を超えていれば
		// 　→ 新しい TPLevel をセット
		// 　→ TPLevel が超えたフラグを立てる
		// フラグが立っている && TPLevel が現在価格を割っている
		// 　→ リリースしましょう

		return bResult;
	}

	// Stop Loss
	void SetStopLossPrice(double price)
	{
		m_dSLPrice = price;
	}
	int GetStopLossPrice()
	{
		return m_dSLPrice;
	}
	void SetStopLossLevel(double level)
	{
		m_dSLLevel = level;
	}
	int GetStopLossLevel()
	{
		return m_dSLLevel;
	}

	// Take Profit
	void SetTakeProfitPrice(double price)
	{
		m_dTPPrice = price;
	}
	int GetTakeProfitPrice()
	{
		return m_dTPPrice;
	}
	void SetTakeProfitLevel(double level)
	{
		m_dTPLevel = level;
	}
	int GetTakeProfitLevel()
	{
		return m_dTPLevel;
	}

	// Magic Number
	void SetMagicNumber(int number)
	{
		m_nMagicNumber = number;
	}
	int GetMagicNumber()
	{
		return m_nMagicNumber;
	}

	// Ticket Number
	void SetTicketNumber(int number)
	{
		m_nTicketNumber = number;
	}
	int GetTicketNumber()
	{
		return m_nTicketNumber;
	}

	// Order Price
	void SetOrderPrice(double price)
	{
		m_dOrderPrice = price;
	}
	double GetOrderPrice()
	{
		return m_dOrderPrice;
	}

	// Order Comment
	void SetOrderComment(string comment)
	{
		m_strOrderComment = comment;
	}
	string GetOrderComment()
	{
		return m_strOrderComment;
	}

	// Order Type
	int GetOrderType()
	{
		if (OrderSelect(GetTicketNumber(), SELECT_BY_TICKET, MODE_TRADES))
		{
			return OrderType();
		}
		return -1;
	}

	// OpenTime
	void SetOpenTime(CTimeStamp time)
	{
		m_cTimeStamp = time;
	}
	CTimeStamp GetOpenTime()
	{
		return m_cTimeStamp;
	}
}; //}}}

class CPositionInfoList //{{{
{
public:
	CPositionInfoList()
	{
	}
	~CPositionInfoList()
	{
	}

	int length()
	{
		return ArrayRange(m_List, 0);
	}

	bool resize(int size)
	{
		ArrayResize(m_List, size);
	}

	void insert(int index, CPositionInfo element)
	{
		ArrayResize(m_List, ArrayRange(m_List, 0) + 1);
		for (int i = ArrayRange(m_List, 0) - 1; i > index; i--){
			m_List[i] = m_List[i - 1];
		}

		m_List[index] = element;
	}

	void delete(int index)
	{
		for (int i = index; i < ArrayRange(m_List, 0) - 1; i++){
			m_List[i] = m_List[i + 1];
		}

		ArrayResize(ArrayRange(m_List, 0) - 1);
	}

	void push_back(CPositionInfo elemnt)
	{
		ArrayRisize(m_List, ArrayRange(m_List, 0) + 1);
		m_List[ArrayRange(m_List, 0) - 1] = elemnt;
	}
	CPositionInfo GetElement(int index)
	{
		return m_List[index];
	}

private:
	CPositionInfo  m_list[];

}; //}}}

