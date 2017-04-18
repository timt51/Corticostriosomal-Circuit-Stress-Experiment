% Help for file Mat2NlxEV.dll
%
% Mat2NlxEV.dll is a matlab mex file compilation of matlab and C++ source code.
% C++ source code is used to access matlab arrays or matrices from the matlab environment, 
% process them, and write them out in the form of a Neuralnx Event data file.
%
% Mat2NlxEV.dll accepts either 7 or 9 parameters.
% 
% The 7 required parameters are as follows:
% Parameter 1 - Filename - this is the file name string for which we will write to.  
%     The full or local path must be present depending on the users current working directory or location preference.
% Parameter 2 - Timestamps - A double array of Timestamps data.
% Parameter 3 - EventIDs - A double array of EventIDs data.
% Parameter 4 - Nttls - A double array of Nttls data.
% Parameter 5 - Extras - A double array of Extras data.
% Parameter 6 - EventStrings - A cell array of EventStrings data.
% Parameter 7 - NumRecs - A scalar variable that represents the max number of records to be written to a file,
%     regardless of weather or not the optional paramters have been set.
% 
% Mat2NlxEV.dll also accepts two optional parameters. These parameters represent TimeStamp values.
% Parameter 8 is a lower TimeStamp bound and parameter 9 is an upper TimeStamp bound.  
% If these parameters are specified, Mat2NlxEV.dll will write records to a file that only have Timestamp
% values between the 2 specified bounds.  The two optional parameters must be positive and
% Paramter 8 must be less than Parameter 9.
% 
% Mat2NlxEV does not output any values.
%
% Note: Mat2NlxEV.dll writes a Neuralynx header to every file it writes to.
%
% A typical call to Mat2NlxEV.dll:
% Mat2NlxEV('c:\path\filename', TimeStamps, EventIDs, Nttls, Extras, EventStrings, NumRecs);
%
% A typical call to Mat2NlxEV.dll using the optional parameter:
% Mat2NlxEV('c:\path\filename', TimeStamps, EventIDs, Nttls, Extras, EventStrings, NumRecs, MinTsBound, MaxTsBound);
%
% Note: The value for NumRecs cannot ever be larger than its corresponding dimension for a variable.
%   For Example, if we have the following values in our matlab environment after doing a 'whos' command:
%       
% >> whos
%    Name                     Size         Bytes  Class
%
%  ChannelNumbers           1x101          808  double array
%  NlxHeader               17x1           2366  cell array
%  NumberValidSamples       1x101          808  double array
%  SampleFrequencies        1x101          808  double array
%  Samples                512x101       413696  double array
%  TimeStamps               1x101          808  double array
%
% Grand total is 52535 elements using 419302 bytes
%
%     We cannot specify the NumRecs variable to be larger than 101.  The value must be <= to the max amount of records for each variable.
%     
%     