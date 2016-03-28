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
		m_bIsSLRelease = false;
		m_bIsTPRelease = false;

		m_cTimeStamp = new CTimeStamp();
	}
	virtual ~CPositionInfo()
	{
	}

	// Open
	bool Open()
	{
	}

	// Close
	bool Close()
	{
	}

	// Stop Loss �Ď�
	bool OvserveStopLoss(double pips)
	{
		bool bResult = false;

		// GetOrderType ���� OrderType ���擾
		int nOrderType = GetOrderType();
		// GetTicketNumber ���� ���݉��i���擾�iBid or Ask�j
		double dNowPrice = 0;
		// ���݉��i�� SLLevel ���r
		switch (nOrderType){
		case OP_BUY:
		case OP_BUYLIMIT:
		case OP_BUYSTOP:
			nNowPrice = Bid;
			// SLLevel �����݉��i�𒴂��Ă����
			// �@�� �V���� SLLevel ���Z�b�g
			// �@�� SLLevel ���������t���O�𗧂Ă�
			if (m_dSLPrice + m_dSLLevel < dNowPrice){
				m_dSLPrice = dNowPrice - m_dSLLevel;
				m_bIsSLRelease = true;
			}
			// �t���O�������Ă��� && SLLevel �����݉��i�������Ă���
			// �@�� �����[�X���܂��傤
			else if (m_bIsSLRelease && m_dSLPrice > dNowPrice){
				// �����[�X����
				bResult = true;
			}
			break;

		case OP_SELL:
		case OP_SELLLIMIT:
		case OP_SELLSTOP:
			nNowPrice = Ask;
			// SLLevel �����݉��i�𒴂��Ă����
			// �@�� �V���� SLLevel ���Z�b�g
			// �@�� SLLevel ���������t���O�𗧂Ă�
			if (m_dSLPrice + m_dSLLevel > dNowPrice){
				m_dSLPrice = dNowPrice + m_dSLLevel;
				m_bIsSLRelease = true;
			}
			// �t���O�������Ă��� && SLLevel �����݉��i�������Ă���
			// �@�� �����[�X���܂��傤
			else if (m_bIsSLRelease && m_dSLPrice < dNowPrice){
				// �����[�X����
				bResult = true;
			}
			break;

		default:
			break;
		}

		return bResult;
	}

	// Take Profit �Ď�
	bool OvserveTakeProfit(double pips)
	{
		bool bResult = true;

		// GetTicketNumber ���� OrderType ���擾
		// GetTicketNumber ���� ���݉��i���擾�iBid or Ask�j
		// ���݉��i�� SLLevel ���r
		// TPLevel �����݉��i�𒴂��Ă����
		// �@�� �V���� TPLevel ���Z�b�g
		// �@�� TPLevel ���������t���O�𗧂Ă�
		// �t���O�������Ă��� && TPLevel �����݉��i�������Ă���
		// �@�� �����[�X���܂��傤

		return bResult;
	}

	// Stop Loss
	void SetStopLossPrice(double price)
	{
		m_nSLPrice = price;
	}
	int GetStopLossPrice()
	{
		return m_nSLPrice;
	}
	void SetStopLossLevel(double level)
	{
		m_nSLLevel = level;
	}
	int GetStopLossLevel()
	{
		return m_nSLLevel;
	}

	// Take Profit
	void SetTakeProfitPrice(double price)
	{
		m_nTPPrice = price;
	}
	int GetTakeProfitPrice()
	{
		return m_nTPPrice;
	}
	void SetTakeProfitLevel(double level)
	{
		m_nTPLevel = level;
	}
	int GetTakeProfitLevel()
	{
		return m_nTPLevel;
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

	// OpenTime
	void SetOpenTime(CTimeStamp time)
	{
		m_cTimeStamp = time;
	}
	CTimeStamp GetOpenTime()
	{
		return m_cTimeStamp;
	}

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

	CTimeStamp m_cTimeStamp;

}; //}}}

