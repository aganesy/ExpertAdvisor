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

// Note //{{{
/*
リリース判定用Stop Loss（Release Priceとでも呼ぶか）と、リスクヘッジ用のStop Lossを用意しておく
利確後、利益を伸ばすための反転判定はリリース判定用Stop Lossを利用
従来のStop Lossの役目はリスクヘッジ用のそれ

Take Profitは従来のやつのみ

*/

//}}}

class CPositionInfo //{{{
{
private:
	bool m_bIsRelease;

	int m_nMagicNumber;
	int m_nTicketNumber;

	double m_dOrderPrice;
	double m_dSLPrice;
	double m_dTPPrice;
	double m_dReleasePrice;

	double m_dReleaseBorderPips;

	string m_strOrderComment;

	CTimeStamp m_cTimeStamp;

public:
	CPositionInfo()
	{
		m_bIsRelease = false;

		m_nMagicNumber		= 0;
		m_nTicketNumber		= 0;

		m_dReleaseBorderPips	= 0.0;

		m_dOrderPrice		= 0.0;
		m_dSLPrice			= 0.0;
		m_dTPPrice			= 0.0;
		m_dReleasePrice		= 0.0;

		m_strOrderComment	= "";

		m_cTimeStamp		= new CTimeStamp();
	}
	~CPositionInfo()
	{
		EraseStopLossLine();
		EraseTakeProfitLine();
	}

	// Open
	bool Open(int orderType, double lots, double stopLoss = 0.0, double takeProfit = 0.0, string& comment = "", int slippage = 3, color arrowColor = Red)
	{
		bool bResult = false;
		if (lots <= 0.0){
			print("Warning Lot=0.0");
		}
		else {
			string strVarName = "";
			for (int i = 1; i < MAX_INT_COUNT; i++) {
				strVarName = DoubleToStr(i, 0);
				int nVarValue = GlobalVariableGet(strVarName);
				if (!nVarValue){
					SetMagicNumber(i);
					break;
				}
			}

			double dOrderPrice = 0;
			if (GetMagicNumber()){
				switch (orderType){
				case OP_BUY:
				case OP_BUYLIMIT:
				case OP_BUYSTOP:
					dOrderPrice = Ask;
					if (StringLen(comment) == 0){
						comment = "Buy";
					}
					break;

				case OP_SELL:
				case OP_SELLLIMIT:
				case OP_SELLSTOP:
					dOrderPrice = Bid;
					if (StringLen(comment) == 0){
						comment = "Sell";
					}
					break;

				default:
					break;
				}

				bResult = OrderSend(Symbol(), orderType, lots, GetOrderPrice(), slippage, 0, 0, GetOrderComment(), GetMagicNumber(), 0, arrowColor);

				if (bResult){
					OrderSelect(OrdersTotal() - 1, SELECT_BY_POS, MODE_TRADES);
					SetOrderPrice(dOrderPrice);
					SetOrderComment(comment);
					SetTicketNumber(OrderTicket());
					GlobalVariableSet(DoubleToStr(GetMagicNumber()), GetMagicNumber());

					if (stopLoss > 0.0){
						SetStopLossPrice(stopLoss);
					}
					if (takeProfit > 0.0){
						SetTakeProfitPrice(takeProfit);
					}
				}
			}
		}

		return bResult;
	}

	// Close
	bool Close(color arrowColor = Blue)
	{
		bool bResult = false;

		bool nOrderResult = OrderSelect(GetTicketNumber(), SELECT_BY_TICKET, MODE_TRADES);
		if (!nOrderResult){
			print("Error Order select failed : ", GetLastError());
		}
		else {
			double dClosePrice = 0.0;
			switch (OrderType()){
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
			if (bResult){
				GlobalVariableDel(DoubleToStr(GetMagicNumber()));
			}
		}

		return bResult;
	}

	// Release Price 監視
	bool OvserveReleasePrice()
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
			// 現在価格が リリース判定価格 + 更新幅pips より高い状態なら
			// 　→ 新しい Release Price をセット
			if (dNowPrice > m_dReleasePrice + m_dReleaseBorderPips){
				m_dReleasePrice = dNowPrice - m_dReleaseBorderPips;
			}
			// 現在価格が リリース判定価格より高い状態なら
			// 　→ リリースしても良いフラグを立てる
			if (dNowPrice > m_dReleasePrice){
				m_bIsRelease = true;
			}
			// フラグが立っている && 現在価格が リリース判定価格 を割っている
			// 　→ リリースしましょう
			if (m_bIsRelease && dNowPrice < m_dReleasePrice){
				// リリースする
				bResult = true;
			}
			break;

		case OP_SELL:
		case OP_SELLLIMIT:
		case OP_SELLSTOP:
			nNowPrice = Ask;
			// 現在価格が リリース判定価格 + 更新幅pips より低い状態なら
			// 　→ 新しい Release Price をセット
			if (dNowPrice < m_dReleasePrice - m_dReleaseBorderPips){
				m_dReleasePrice = dNowPrice + m_dReleaseBorderPips;
			}
			// 現在価格が リリース判定価格より低い状態なら
			// 　→ リリースしても良いフラグを立てる
			if (dNowPrice < m_dReleasePrice){
				m_bIsRelease = true;
			}
			// フラグが立っている && 現在価格が リリース判定価格 を超えている
			// 　→ リリースしましょう
			else if (m_bIsRelease && dNowPrice > m_dReleasePrice){
				// リリースする
				bResult = true;
			}
			break;

		default:
			break;
		}

		return bResult;
	}

	// Stop Loss 監視
	bool OvserveStopLoss()
	{
		bool bResult = false;

		if (m_dSLPrice > 0.0){
			switch (nOrderType){
			case OP_BUY:
			case OP_BUYLIMIT:
			case OP_BUYSTOP:
				if (m_dSLPrice > Bid){
					bResult = true;
				}
				break;
			case OP_SELL:
			case OP_SELLLIMIT:
			case OP_SELLSTOP:
				if (m_dSLPrice < Ask){
					bResult = true;
				}
				break;
			}
		}

		return bResult;
	}

	// Take Profit 監視
	bool OvserveTakeProfit()
	{
		bool bResult = true;

		if (m_dTPPrice > 0.0){
			switch (nOrderType){
			case OP_BUY:
			case OP_BUYLIMIT:
			case OP_BUYSTOP:
				if (m_dTPPrice < Bid){
					bResult = true;
				}
				break;
			case OP_SELL:
			case OP_SELLLIMIT:
			case OP_SELLSTOP:
				if (m_dTPPrice > Ask){
					bResult = true;
				}
				break;
			}
		}

		return bResult;
	}

	// Stop Loss 価格
	void SetStopLossPrice(double price)
	{
		m_dSLPrice = price;
		DrawStopLossLine(price);
	}
	int GetStopLossPrice()
	{
		return m_dSLPrice;
	}
	void DrawStopLossLine(double price)
	{
		// マジックナンバーがユニークな値なのでそのままオブジェクト名として利用
		string strObjectName = DoubleToStr(GetMagicNumber());
		ObjectCreate(strObjectName,OBJ_HLINE, 0, 1, price);
		ObjectSet(strObjectName, OBJPROP_COLOR, Blue);
		ObjectSet(strObjectName, OBJPROP_STYLE, STYLE_DOT);
	}
	void EraseStopLossLine()
	{
		string strObjectName = DoubleToStr(GetMagicNumber());
		ObjectDelete(strObjectName);
	}

	// Take Profit 価格
	void SetTakeProfitPrice(double price)
	{
		m_dTPPrice = price;
		DrawTakeProfitLine(price);
	}
	int GetTakeProfitPrice()
	{
		return m_dTPPrice;
	}
	void DrawTakeProfitLine(double price)
	{
		// マジックナンバーがユニークな値なのでそのままオブジェクト名として利用
		string strObjectName = DoubleToStr(GetMagicNumber());
		ObjectCreate(strObjectName,OBJ_HLINE, 0, 1, price);
		ObjectSet(strObjectName, OBJPROP_COLOR, Red);
		ObjectSet(strObjectName, OBJPROP_STYLE, STYLE_DOT);
	}
	void EraseTakeProfitLine()
	{
		string strObjectName = DoubleToStr(GetMagicNumber());
		ObjectDelete(strObjectName);
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
		if (OrderSelect(GetTicketNumber(), SELECT_BY_TICKET, MODE_TRADES)){
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

