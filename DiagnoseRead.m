function tableout = importfile(workbookFile,sheetName,startRow,endRow)
%IMPORTFILE ������ӱ���е�����
%   DATA = IMPORTFILE(FILE) ��ȡ��Ϊ FILE �� Microsoft Excel
%   ���ӱ���ļ��ĵ�һ�Ź������е����ݣ����Ա����ʽ���ظ����ݡ�
%
%   DATA = IMPORTFILE(FILE,SHEET) ��ָ���Ĺ������ж�ȡ��
%
%   DATA = IMPORTFILE(FILE,SHEET,STARTROW,ENDROW)
%   ����ָ�����м����ָ���������ж�ȡ�����ڲ��������м������ STARTROW �� ENDROW
%   ָ��Ϊ��Сƥ���һ�Ա�����ʸ����Ҫ��ȡ���ļ���β����Ϊ inf ָ�� ENDROW��%
% ʾ��:
%   Diagnose = importfile('Diagnose.xlsx','ods_sjkfds_zsj_daily_confirmed_',2,79);
%
%   ������� XLSREAD��

% �� MATLAB �Զ������� 2022/11/06 16:47:28

%% ���봦��

% ���δָ���������򽫶�ȡ��һ�Ź�����
if nargin == 1 || isempty(sheetName)
    sheetName = 1;
end

% ���δָ���е������յ㣬��ᶨ��Ĭ��ֵ��
if nargin <= 3
    startRow = 2;
    endRow = 79;
end

%% �������ݣ�����ȡ Excel �������ڸ�ʽ�ĵ��ӱ������
[~, ~, raw, dates] = xlsread(workbookFile, sheetName, sprintf('A%d:C%d',startRow(1),endRow(1)),'' , @convertSpreadsheetExcelDates);
for block=2:length(startRow)
    [~, ~, tmpRawBlock,tmpDateNumBlock] = xlsread(workbookFile, sheetName, sprintf('A%d:C%d',startRow(block),endRow(block)),'' , @convertSpreadsheetExcelDates);
    raw = [raw;tmpRawBlock]; %#ok<AGROW>
    dates = [dates;tmpDateNumBlock]; %#ok<AGROW>
end
stringVectors = string(raw(:,[2,3]));
stringVectors(ismissing(stringVectors)) = '';
dates = dates(:,1);

%% ������
tableout = table;

%% ����������������б�������
dates(~cellfun(@(x) isnumeric(x) || islogical(x), dates)) = {NaN};
tableout.Time = datetime([dates{:,1}].', 'ConvertFrom', 'Excel');
tableout.Cumulative = stringVectors(:,1);
tableout.Cumulative=str2double(tableout.Cumulative);
tableout.New_confirmed = stringVectors(:,2);
tableout.New_confirmed=str2double(tableout.New_confirmed);

% ����Ҫ����������(datenum)����������ʱ��Ĵ��룬��ȡ��ע�������У��Ա��� datenum ��ʽ���ص�������ڡ�

% tableout.Time=datenum(tableout.Time);

