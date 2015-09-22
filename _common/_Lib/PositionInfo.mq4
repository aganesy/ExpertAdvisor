//# vim:set foldmethod=marker:
//+------------------------------------------------------------------+
//|                                             PositionInfo.mqh.mq4 |
//|                                   Copyright 2015, Senaga YUSUKE. |
//|                                               mi081321@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Senaga YUSUKE."
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

	void SetStopLossPips(int pips)
	{
		m_nSLPips = pips;
	}
	int GetStopLossPips()
	{
		return m_nSLPips;
	}

	void SetMagicNumber(int number)
	{
		m_nMagicNumber = number;
	}
	int GetMagicNumber()
	{
		return m_nMagicNumber;
	}

private:
	int m_nMagicNumber;
	int m_nSLPips;
}; //}}}

