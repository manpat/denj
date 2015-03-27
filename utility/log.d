module denj.utility.log;

import denj.utility.general;
import std.stdio;
import std.file;
import std.string;

private {
	string logFile = "denj.log"; // Change to file handle maybe
	bool fileLoggingEnabled = true;
}

void SetLogFile(string _logFile){
	logFile = _logFile;
}

string GetLogFile(){
	return logFile;
}

void ClearLog(){
	std.file.write(logFile, "");
}

void Log(T...) (T t){
	writeln(t);
	if(fileLoggingEnabled) std.file.append(logFile, TupleToString(t) ~ "\n");
}
void LogF(Fmt, T...) (Fmt fmt, T t){
	writefln(fmt, t);
	if(fileLoggingEnabled) std.file.append(logFile, fmt.format(t) ~ "\n");
}

void EnableFileLogging(bool _fileLog = true){
	fileLoggingEnabled = _fileLog;
}

bool FileLoggingEnabled(){
	return fileLoggingEnabled;
}

void FlushLog(){
	std.stdio.stdout.flush();
	// Flush log file
}