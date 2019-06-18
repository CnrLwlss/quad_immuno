function data = get_excel_sheet_data(excel_app, filename)

workbook = excel_app.Workbooks.Open(filename); 
Sheets =workbook.Sheets;

n_sheets = Sheets.Count;

data = cell(0,3);

for i = 1:n_sheets,
    sheet = get(Sheets, 'Item', i);
    range = sheet.UsedRange;
    d = range.Value;
    if iscell(d),
        if size(d,2)<6,
            %It must be an area, just add a fake column with -1 as the
            %channel. Ok, I don't know how to do that, I'll just put in the
            %column Time instead, it will class it as channel 1
            dd = d(3:end,[1,4,5]);
            [dd{:,2}] = deal(-1);
            data  = vertcat(data, dd);
        else
            data  = vertcat(data, d(3:end,[1,4,6]));
        end
    end
end

workbook.Close;
