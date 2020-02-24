function ChangeParametersInElastixTransformFile(file_path, old_string, replace_with_string)

parameters_file = fopen(file_path,'rt') ;
file_contents = fread(parameters_file) ;
fclose(parameters_file);
file_contents = char(file_contents.') ;
% replace string S1 with string S2
new_text = strrep(file_contents, old_string, replace_with_string) ;
parameters_file = fopen(file_path,'wt') ;
fwrite(parameters_file,new_text) ;
fclose(parameters_file);
end