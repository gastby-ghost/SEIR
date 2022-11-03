function Diagnose = DiagnoseRead(workbookFile, sheetName, dataLines)
%IMPORTFILE 导入电子表格中的数据
%  DIAGNOSE = IMPORTFILE(FILE) 读取名为 FILE 的 Microsoft Excel
%  电子表格文件的第一张工作表中的数据。  以表形式返回数据。
%
%  DIAGNOSE = IMPORTFILE(FILE, SHEET) 从指定的工作表中读取。
%
%  DIAGNOSE = IMPORTFILE(FILE, SHEET,
%  DATALINES)按指定的行间隔读取指定工作表中的数据。对于不连续的行间隔，请将 DATALINES 指定为正整数标量或 N×2
%  正整数标量数组。
%
%  示例:
%  Diagnose = importfile("D:\shan\桌面\SEIR\Diagnose.xlsx", "ods_sjkfds_zsj_daily_confirmed_", [2, 78]);
%
%  另请参阅 READTABLE。
%
% 由 MATLAB 于 2022-11-03 11:26:53 自动生成

%% 输入处理

% 如果未指定工作表，则将读取第一张工作表
if nargin == 1 || isempty(sheetName)
    sheetName = 1;
end

% 如果未指定行的起点和终点，则会定义默认值。
if nargin <= 2
    dataLines = [2, 78];
end

%% 设置导入选项并导入数据
opts = spreadsheetImportOptions("NumVariables", 3);

% 指定工作表和范围
opts.Sheet = sheetName;
opts.DataRange = "A" + dataLines(1, 1) + ":C" + dataLines(1, 2);

% 指定列名称和类型
opts.VariableNames = ["Time", "Cumulative", "New_confirmed"];
opts.VariableTypes = ["datetime", "double", "double"];

% 指定变量属性
opts = setvaropts(opts, "Time", "InputFormat", "");

% 导入数据
Diagnose = readtable(workbookFile, opts, "UseExcel", false);

for idx = 2:size(dataLines, 1)
    opts.DataRange = "A" + dataLines(idx, 1) + ":C" + dataLines(idx, 2);
    tb = readtable(workbookFile, opts, "UseExcel", false);
    Diagnose = [Diagnose; tb]; %#ok<AGROW>
end

end