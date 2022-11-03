function Diagnose = DiagnoseRead(workbookFile, sheetName, dataLines)
%IMPORTFILE ������ӱ���е�����
%  DIAGNOSE = IMPORTFILE(FILE) ��ȡ��Ϊ FILE �� Microsoft Excel
%  ���ӱ���ļ��ĵ�һ�Ź������е����ݡ�  �Ա���ʽ�������ݡ�
%
%  DIAGNOSE = IMPORTFILE(FILE, SHEET) ��ָ���Ĺ������ж�ȡ��
%
%  DIAGNOSE = IMPORTFILE(FILE, SHEET,
%  DATALINES)��ָ�����м����ȡָ���������е����ݡ����ڲ��������м�����뽫 DATALINES ָ��Ϊ������������ N��2
%  �������������顣
%
%  ʾ��:
%  Diagnose = importfile("D:\shan\����\SEIR\Diagnose.xlsx", "ods_sjkfds_zsj_daily_confirmed_", [2, 78]);
%
%  ������� READTABLE��
%
% �� MATLAB �� 2022-11-03 11:26:53 �Զ�����

%% ���봦��

% ���δָ���������򽫶�ȡ��һ�Ź�����
if nargin == 1 || isempty(sheetName)
    sheetName = 1;
end

% ���δָ���е������յ㣬��ᶨ��Ĭ��ֵ��
if nargin <= 2
    dataLines = [2, 78];
end

%% ���õ���ѡ���������
opts = spreadsheetImportOptions("NumVariables", 3);

% ָ��������ͷ�Χ
opts.Sheet = sheetName;
opts.DataRange = "A" + dataLines(1, 1) + ":C" + dataLines(1, 2);

% ָ�������ƺ�����
opts.VariableNames = ["Time", "Cumulative", "New_confirmed"];
opts.VariableTypes = ["datetime", "double", "double"];

% ָ����������
opts = setvaropts(opts, "Time", "InputFormat", "");

% ��������
Diagnose = readtable(workbookFile, opts, "UseExcel", false);

for idx = 2:size(dataLines, 1)
    opts.DataRange = "A" + dataLines(idx, 1) + ":C" + dataLines(idx, 2);
    tb = readtable(workbookFile, opts, "UseExcel", false);
    Diagnose = [Diagnose; tb]; %#ok<AGROW>
end

end