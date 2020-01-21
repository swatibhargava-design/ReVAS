function params = ValidateField(params,default,validate,callerStr)
% params = ValidateField(params,default,validate,callerStr)
%
%    Helper function to validate input arguments in various functions.
%

% get all field names
fields = fieldnames(default);

% go over fields and make sure all required fields exist. if not, create
% the needed field and populate with default values.
for i=1:length(fields)

    if ~isfield(params, fields{i})
        params.(fields{i}) = default.(fields{i});
        
        % every case except for fields with cell type can be handled using
        % num2str. So we need a special handling of cell fields.
        thisFieldContents = params.(fields{i});
        str = [];
        if iscell(thisFieldContents)
            for j=1:length(thisFieldContents)
                str = [str ' -> ' num2str(thisFieldContents{j})]; %#ok<AGROW>
            end
        else
            str = num2str(thisFieldContents);
        end
        
        % inform the user about using default values and show the default
        % values as well.
        RevasWarning([callerStr ' is using default parameter for ' fields{i} ': ' str], params);
    end

end

% go over the params structure and validate each field
for i=1:length(fields)
    if ~validate.(fields{i})(params.(fields{i}))
        error([callerStr ': ' fields{i} ' must satisfy ' func2str(validate.(fields{i}))]);
    end
end