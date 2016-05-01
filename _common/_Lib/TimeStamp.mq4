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
	int GetDayOfYear(datetime time)
	{
		return TimeDayOfYear(m_dtTime);
	}

	int GetElapsedYear()
	{
		int nElapsedYear = TimeYear(time) - TimeYear(m_dtTime);

		if (nElapsedYear < 0)
		{
			nElapsedYear = 0;
		}

		return nElapsedYear;
	}

	int GetElapsedMonth(datetime time)
	{
		int nElapsedMonth = 0;
		nElapsedMonth += (GetElapsedYear(time) * 12);
		nElapsedMonth += (TimeMonth(time) - TimeMonth(m_dtTime));

		if (nElapsedMonth < 0)
		{
			nElapsedMonth = 0;
		}

		return nElapsedMonth;
	}

	int GetElapsedDay(datetime time)
	{
		int nElapsedDay = 0;
		nElapsedDay += (GetElapsedYear(time) * 365);
		nElapsedDay += (TimeDayOfYear(time) - TimeDayOfYear(m_dtTime));

		if (nElapsedDay < 0)
		{
			nElapsedDay = 0;
		}

		return nElapsedDay;
	}

	int GetElapsedHour(datetime time)
	{
		int nElapsedHour = 0;
		nElapsedHour += (GetElapsedDay(time) * 24);
		nElapsedHour += (TimeHour(time) - TimeHour(m_dtTime));

		if (nElapsedHour < 0)
		{
			nElapsedHour = 0;
		}

		return nElapsedHour;
	}

	int GetElapsedMinute(datetime time)
	{
		int nElapsedMinute = 0;
		nElapsedMinute += (GetElapsedHour(time) * 60);
		nElapsedMinute += (TimeMinute(time) - TimeMinute(m_dtTime));

		if (nElapsedMinute < 0)
		{
			nElapsedMinute = 0;
		}

		return nElapsedMinute;
	}

	int GetElapsedSecond(datetime time)
	{
		int nElapsedSecond = 0;
		nElapsedSecond += (GetElapsedMinute(time) * 60);
		nElapsedSecond += (TimeSeconds(time) - TimeSeconds(m_dtTime));

		if (nElapsedSecond < 0)
		{
			nElapsedSecond = 0;
		}

		return nElapsedSecond;
	}

private:
	datetime m_dtTime;
}; //}}}

