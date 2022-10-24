function tableout = DiagnoseRead(workbookFile,sheetName,startRow,endRow)
%IMPORTFILE ������ӱ���е�����
%   DATA = IMPORTFILE(FILE) ��ȡ��Ϊ FILE �� Microsoft Excel
%   ���ӱ���ļ��ĵ�һ�Ź������е����ݣ����Ա����ʽ���ظ����ݡ�
%
%   DATA = IMPORTFILE(FILE,SHEET) ��ָ���Ĺ������ж�ȡ��
%
%   DATA = IMPORTFILE(FILE,SHEET,STARTROW,ENDROW)
%   ����ָ�����м����ָ���������ж�ȡ�����ڲ��������м������ STARTROW �� ENDROW
%   ָ��Ϊ��Сƥ���һ�Ա�����ʸ����Ҫ��ȡ���ļ���β����Ϊ inf ָ�� ENDROW��
%
%	����ֵԪ�����滻Ϊ: NaN
%
% ʾ��:
%   Diagnose = importfile('Diagnose.xlsx','ods_sjkfds_zsj_daily_confirmed_',1,339);
%
%   ������� XLSREAD��

% �� MATLAB �Զ������� 2022/10/24 16:51:50

%% ���봦��

% ���δָ���������򽫶�ȡ��һ�Ź�����
if nargin == 1 || isempty(sheetName)
    sheetName = 1;
end

% ���δָ���е������յ㣬��ᶨ��Ĭ��ֵ��
if nargin <= 3
    startRow = 1;
    endRow = 339;
end

%% �������ݣ�����ȡ Excel �������ڸ�ʽ�ĵ��ӱ������
[~, ~, raw, dates] = xlsread(workbookFile, sheetName, sprintf('A%d:C%d',startRow(1),endRow(1)),'' , @convertSpreadsheetExcelDates);
for block=2:length(startRow)
    [~, ~, tmpRawBlock,tmpDateNumBlock] = xlsread(workbookFile, sheetName, sprintf('A%d:C%d',startRow(block),endRow(block)),'' , @convertSpreadsheetExcelDates);
    raw = [raw;tmpRawBlock]; %#ok<AGROW>
    dates = [dates;tmpDateNumBlock]; %#ok<AGROW>
end
raw(cellfun(@(x) ~isempty(x) && isnumeric(x) && isnan(x),raw)) = {''};
raw = raw(:,[2,3]);
dates = dates(:,1);

%% ������ֵԪ���滻Ϊ NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),raw); % ���ҷ���ֵԪ��
raw(R) = {NaN}; % �滻����ֵԪ��
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),dates); % ���ҷ���ֵԪ��
dates(R) = {NaN}; % ������ֵ Excel �����滻Ϊ NaN

%% �����������
I = cellfun(@(x) ischar(x), raw);
raw(I) = {NaN};
data = reshape([raw{:}],size(raw));

%% ������
tableout = table;

%% ����������������б�������
dates(~cellfun(@(x) isnumeric(x) || islogical(x), dates)) = {NaN};
tableout.Time = datetime([dates{:,1}].', 'ConvertFrom', 'Excel');
tableout.Cumulative = data(:,1);
tableout.New_confirmed = data(:,2);

% ����Ҫ����������(datenum)����������ʱ��Ĵ��룬��ȡ��ע�������У��Ա��� datenum ��ʽ���ص�������ڡ�

% tableout.Time=datenum(tableout.Time);

