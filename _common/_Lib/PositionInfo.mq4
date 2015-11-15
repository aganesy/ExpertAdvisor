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

class CPositionInfo //{{{
{
public:
	CPositionInfo()
	{
	}
	virtual ~CPositionInfo()
	{
	}

	// Stop Loss �Ď�
	bool OvserveStopLoss(double pips)
	{
		bool bResult = true;

		// GetTicketNumber ���� OrderType ���擾
		// GetTicketNumber ���� ���݉��i���擾�iBid or Ask�j
		// ���݉��i�� SLLevel ���r
		// SLLevel �����݉��i�𒴂��Ă����
		// �@�� �V���� SLLevel ���Z�b�g
		// �@�� SLLevel ���������t���O�𗧂Ă�
		// �t���O�������Ă��� && SLLevel �����݉��i�������Ă���
		// �@�� �����[�X���܂��傤

		return bResult;
	}

	// Take Profit �Ď�
	bool OvserveTakeProfit(double pips)
	{
		bool bResult = true;

		return bResult;
	}

	// Stop Loss
	void SetStopLossLevel(double price)
	{
		m_nSLLebel = price;
	}
	int GetStopLossLevel()
	{
		return m_nSLPips;
	}

	// Take Profit
	void SetTakeProfitLevel(double price)
	{
		m_nTPLevel = price;
	}
	int GetTakeProfitLevel()
	{
		return m_nTPPips;
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

	// Order Type
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
	int m_nSLLevel;
	int m_nTPLevel;

	double m_dOrderPrice;

}; //}}}

