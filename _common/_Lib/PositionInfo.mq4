//# vim:set foldmethod=marker:
//+------------------------------------------------------------------+
//|                                             PositionInfo.mqh.mq4 |
//|                                   Copyright 2015, SENAGA Yusuke. |
//|                                               mi081321@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, SENAGA Yusuke."
#property link      "mi081321@gmail.com"
#property library

#include "..\_Include\Define.mqh"

class CPositionInfoList //{{{
{
public:
	CPositionInfoList()
	{
	}
	~CPositionInfoList()
	{
	}

	bool resize(int size)
	{
	}
	void insert(int index)
	{
	}
	void delete(int index)
	{
	}
	void push_back()
	{
	}
	CPositionInfoList GetElement(int index)
	{
	}

private:
	CPositionInfoList m_list[];

}; //}}}

class CPositionInfo //{{{
{
public:
	CPositionInfo()
	{
	}
	virtual ~CPositionInfo()
	{
	}

	void SetStopLossLevel(int pips)
	{
		m_nSLPips = pips;
	}
	int GetStopLossLevel()
	{
		return m_nSLPips;
	}

	void SetTakeProfitLevel(int pips)
	{
		m_nTPPips = pips;
	}
	int GetTakeProfitLevel()
	{
		return m_nTPPips;
	}

	void SetMagicNumber(int number)
	{
		m_nMagicNumber = number;
	}
	int GetMagicNumber()
	{
		return m_nMagicNumber;
	}

	void SetTicketNumber_(int number)
	{
		m_nTicketNumber = number;
	}
	int GetTicketNumber()
	{
		return m_nTicketNumber;
	}

	void SetOrderPrice(double price)
	{
		m_dOrderPrice = price;
	}
	double GetOrderPrice()
	{
		return m_dOrderPrice;
	}

	int GetOrderType()
	{
		if (OrderSelect(GetTicketNumber(), SELECT_BY_TICKET, MODE_TRADES))
		{
			return OrderType();
		}
		return -1;
	}

private:
	int m_nMagicNumber;
	int m_nTicketNumber;
	int m_nSLPips;
	int m_nTPPips;

	double m_dOrderPrice;

}; //}}}

