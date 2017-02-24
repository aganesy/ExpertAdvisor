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

	int GetElapsedYear(datetime now)
	{
		int nElapsedYear = TimeYear(now) - TimeYear(m_dtTime);

		if (nElapsedYear < 0)
		{
			nElapsedYear = 0;
		}

		return nElapsedYear;
	}

	int GetElapsedMonth(datetime now)
	{
		int nElapsedMonth = 0;
		int nElapsedYear = 0;

		// year‚ÌŒJ‚èã‚ª‚è‚ª‚ ‚é‚Ì‚ÅŒo‰ßyear‚ðŽæ“¾‚·‚é
		nElapsedMonth += (nElapsedYear * 12);
		nElapsedMonth += (TimeMonth(now) - TimeMonth(m_dtTime));

		if (nElapsedMonth < 0)
		{
			nElapsedMonth = 0;
		}

		return nElapsedMonth;
	}

	int GetElapsedDay(datetime now)
	{
		int nElapsedDay = 0;
		int nElapsedYear = 0;

		// month‚ÌŒJ‚èã‚ª‚è‚ª‚ ‚èAmonth‚ÍŒŽ–ˆ‚Ì“ú”‚ªˆÙ‚È‚é‚Ì‚Å
		// Œo‰ßyear‚ðŽæ“¾‚µA365‚ÅŠ„‚é
		nElapsedDay += (nElapsedYear * 365);
		nElapsedDay += (TimeDayOfYear(now) - TimeDayOfYear(m_dtTime));

		if (nElapsedDay < 0)
		{
			nElapsedDay = 0;
		}

		return nElapsedDay;
	}

	int GetElapsedHour(datetime now)
	{
		int nElapsedHour = 0;
		int nElapsedDay = 0;

		// “ú‚ÌŒJ‚èã‚ª‚è‚ª‚ ‚é‚Ì‚ÅŒo‰ßday‚©‚çŽæ“¾‚·‚é
		nElapsedHour += (nElapsedDay * 24);
		nElapsedHour += (TimeHour(now) - TimeHour(m_dtTime));

		if (nElapsedHour < 0)
		{
			nElapsedHour = 0;
		}

		return nElapsedHour;
	}

	int GetElapsedMinute(datetime now)
	{
		int nElapsedMinute = 0;
		int nElapsedHour = 0;

		// hour‚ÌŒJ‚èã‚ª‚è‚ª‚ ‚é‚Ì‚ÅŒo‰ßhour‚©‚çŽæ“¾‚·‚é
		nElapsedMinute += (nElapsedHour * 60);
		nElapsedMinute += (TimeMinute(now) - TimeMinute(m_dtTime));

		if (nElapsedMinute < 0)
		{
			nElapsedMinute = 0;
		}

		return nElapsedMinute;
	}

	int GetElapsedSecond(datetime now)
	{
		int nElapsedSecond = 0;
		int nElapsedMinute = 0;

		// minute‚ÌŒJ‚èã‚ª‚è‚ª‚ ‚é‚Ì‚ÅŒo‰ßminute‚©‚çŽæ“¾‚·‚é
		nElapsedSecond += (nElapsedMinute * 60);
		nElapsedSecond += (TimeSeconds(now) - TimeSeconds(m_dtTime));

		if (nElapsedSecond < 0)
		{
			nElapsedSecond = 0;
		}

		return nElapsedSecond;
	}

private:
	datetime m_dtTime;
}; //}}}

