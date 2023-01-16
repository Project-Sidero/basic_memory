module sidero.base.datetime;
public import sidero.base.datetime.defs;
public import sidero.base.datetime.calendars.defs;
public import sidero.base.datetime.calendars.gregorian;
public import sidero.base.datetime.time;

///
alias GDate = GregorianDate;
///
alias GDateTime = DateTime!GregorianDate;
