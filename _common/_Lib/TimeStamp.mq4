//# vim:set foldmethod=marker:
//+------------------------------------------------------------------+
//|                                                    TimeStamp.mq4 |
//|                                   Copyright 2016, SENAGA Yusuke. |
//|                                               mi081321@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, SENAGA Yusuke."
#property link      "mi081321@gmail.com"
#property library

#include "..\_Include\Define.mqh"

class CTimeStamp //{{{
{
public:
	CTimeStamp()
	{
		m_dtTime = 0;
	}
	virtual ~CTimeStamp()
	{
	}

	void SetTime(datetime time)
	{
		m_dtTime = time;
	}
	datetime GetTime()
	{
		return m_dtTime;
	}

	int GetYear()
	{
		return TimeYear(m_dtTime);
	}
	int GetMonth()
	{
		return TimeMonth(m_dtTime);
	}
	int GetDay()
	{
		return TimeDay(m_dtTime);
	}
	int GetHour()
	{
		return TimeHour(m_dtTime);
	}
	int GetMinute()
	{
		return TimeMinute(m_dtTime);
	}
	int GetSesond()
	{
		return TimeSeconds(m_dtTime);
	}
	int GetWeek()
	{
		return TimeDayOfWeek(m_dtTime);
	}
	int GetDayOfYear()
	{
		return TimeDayOfYear(m_dtTime);
	}

	int GetElapsedYear()
	{
		int nElapsedYear = TimeYear(TimeCurrent()) - TimeYear(m_dtTime);
		if (nElapsedYear < 0)
		{
			nElapsedYear = 0;
		}

		return nElapsedYear;
	}

	int GetElapsedMonth()
	{
		int nElapsedMonth = TimeMonth(TimeCurrent()) - TimeMonth(m_dtTime);
		if (nElapsedMonth < 0)
		{
			nElapsedMonth = 0;
		}

		return nElapsedMonth;
	}

	int GetElapsedDay()
	{
		int nElapsedDay = TimeDay(TimeCurrent()) - TimeDay(m_dtTime);
		if (nElapsedDay < 0)
		{
			nElapsedDay = 0;
		}

		return nElapsedDay;
	}

	int GetElapsedHour()
	{
		int nElapsedHour = TimeHour(TimeCurrent()) - TimeHour(m_dtTime);
		if (nElapsedHour < 0)
		{
			nElapsedHour = 0;
		}

		return nElapsedHour;
	}

	int GetElapsedMinute()
	{
		int nElapsedMinute = TimeMinute(TimeCurrent()) - TimeMinute(m_dtTime);
		if (nElapsedMinute < 0)
		{
			nElapsedMinute = 0;
		}

		return nElapsedMinute;
	}

	int GetElapsedSecond()
	{
		int nElapsedSecond = TimeSeconds(TimeCurrent()) - TimeSeconds(m_dtTime);
		if (nElapsedSecond < 0)
		{
			nElapsedSecond = 0;
		}

		return nElapsedSecond;
	}

private:
	datetime m_dtTime;
}; //}}}

