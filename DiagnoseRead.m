function tableout = importfile(workbookFile,sheetName,startRow,endRow)
%IMPORTFILE 导入电子表格中的数据
%   DATA = IMPORTFILE(FILE) 读取名为 FILE 的 Microsoft Excel
%   电子表格文件的第一张工作表中的数据，并以表的形式返回该数据。
%
%   DATA = IMPORTFILE(FILE,SHEET) 从指定的工作表中读取。
%
%   DATA = IMPORTFILE(FILE,SHEET,STARTROW,ENDROW)
%   对于指定的行间隔从指定工作表中读取。对于不连续的行间隔，将 STARTROW 和 ENDROW
%   指定为大小匹配的一对标量或矢量。要读取到文件结尾，请为 inf 指定 ENDROW。%
% 示例:
%   Diagnose = importfile('Diagnose.xlsx','ods_sjkfds_zsj_daily_confirmed_',2,79);
%
%   另请参阅 XLSREAD。

% 由 MATLAB 自动生成于 2022/11/06 16:47:28

%% 输入处理

% 如果未指定工作表，则将读取第一张工作表
if nargin == 1 || isempty(sheetName)
    sheetName = 1;
end

% 如果未指定行的起点和终点，则会定义默认值。
if nargin <= 3
    startRow = 2;
    endRow = 79;
end

%% 导入数据，并提取 Excel 序列日期格式的电子表格日期
[~, ~, raw, dates] = xlsread(workbookFile, sheetName, sprintf('A%d:C%d',startRow(1),endRow(1)),'' , @convertSpreadsheetExcelDates);
for block=2:length(startRow)
    [~, ~, tmpRawBlock,tmpDateNumBlock] = xlsread(workbookFile, sheetName, sprintf('A%d:C%d',startRow(block),endRow(block)),'' , @convertSpreadsheetExcelDates);
    raw = [raw;tmpRawBlock]; %#ok<AGROW>
    dates = [dates;tmpDateNumBlock]; %#ok<AGROW>
end
stringVectors = string(raw(:,[2,3]));
stringVectors(ismissing(stringVectors)) = '';
dates = dates(:,1);

%% 创建表
tableout = table;

%% 将导入的数组分配给列变量名称
dates(~cellfun(@(x) isnumeric(x) || islogical(x), dates)) = {NaN};
tableout.Time = datetime([dates{:,1}].', 'ConvertFrom', 'Excel');
tableout.Cumulative = stringVectors(:,1);
tableout.Cumulative=str2double(tableout.Cumulative);
tableout.New_confirmed = stringVectors(:,2);
tableout.New_confirmed=str2double(tableout.New_confirmed);

% 对于要求日期序列(datenum)而不是日期时间的代码，请取消注释以下行，以便以 datenum 形式返回导入的日期。

% tableout.Time=datenum(tableout.Time);

