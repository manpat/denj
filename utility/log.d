module denj.utility.log;

import denj.utility.general;
import std.stdio;
import std.file;
import std.string;

private {
	__gshared File logFile;
	__gshared bool fileLoggingEnabled = true;
}

static this(){
	logFile.open("denj.log", "w");
}

static ~this(){
	FlushLog();
	logFile.close();
}

void SetLogFile(string logFileName){
	logFile.close();
	logFile.open(logFileName, "w");
}

string GetLogFileName(){
	return logFile.name;
}

void Log()(){
	writeln();
	if(fileLoggingEnabled) logFile.writeln();
}
void Log(T...) (T t){
	writeln(t);
	if(fileLoggingEnabled) logFile.writeln(t);
}
void LogF(Fmt, T...) (Fmt fmt, T t){
	writefln(fmt, t);
	if(fileLoggingEnabled) logFile.writefln(fmt, t);
}

void EnableFileLogging(bool _fileLog = true){
	fileLoggingEnabled = _fileLog;
}

bool FileLoggingEnabled(){
	return fileLoggingEnabled;
}

void FlushLog(){
	std.stdio.stdout.flush();
	logFile.flush();
}