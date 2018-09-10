function translator(file)

% Creates a python file (.py) from a .FIS file
%
% Make sure your model, variable and mf names are PEP compliant
% 
% UPDATE
% - Made several aesthetical and performance modifications
% - Now works with multiple outputs
% - It now works with both AND and OR rule linking
% - Variable names are now in english 
% - An effort to comment is being made, don't ask too much
% - A precision argument is now available in the generated py file;
%   it defines que steps in the range interval in both antecedents and
%   consequents. It defaults at 0.1 and can be changed in Python
% 
% TODO
% - Implement all the membership functions
% - Implement weigthed rules
% If you find errors in python like: 
% 
% Crisp output cannot be calculated, 
% likely because the system is too sparse. Check to make sure this set of 
% input values will activate at least one connected Term in each Antecedent
% via the current set of Rules. 
% 
% It means that some rules are not activating. If no rules are activated, 
% MATLAB outputs the half of the output interval. Make sure all your rules
% activated for each input.
%
% If you find discrepancies between MATLAB's output and Python outputs, 
% from SKFuzzys github page (https://github.com/scikit-fuzzy/scikit-fuzzy):
%
% It should be noted that Matlab rounds incorrectly. The IEEE standard 
% (which is how this package behaves) requires rounding to the nearest EVEN
% number if exactly between, e.g. 1.5 --> 2; 2.5 --> 2; 3.5 --> 4; 4.5 --> 4, etc. 
% This minimizes systematic rounding error. Thus, if re-implementing 
% algorithms from Matlab code, slight inconsistencies in rounded results 
% are expected. These are not bugs, and will not be fixed.
%
%
%
% Please report any errors to:
% Author: Marco Julio Del Moral Argumedo
% México, Veracruz
% marcojulioarg@gmail.com

    % read fis file
    fis = readfis(file);
    
    % get number of input and output variables
    num_input_variables = size(fis.input, 2);
    num_output_variables = size(fis.output, 2);

    % define output file
    translated_file = fopen(strcat(fis.name,'.py'),'wt');

    % add imports to file
    fprintf(translated_file, '%s\n%s\n%s', 'import numpy as np', ...
                                   'import skfuzzy as fuzz', ..., 
                                   'from skfuzzy import control as ctrl');

    % defines control function and precision argument
    fprintf(translated_file, '\n\ndef control(precision=0.1):');

    % nested for loops that generate inputs and their membership functions
    % first loop deals with input variables
    % second loop deals with membership functions of each input variable
    for ii=1:num_input_variables
        input_name = fis.input(ii).name;
        input_range = fis.input(ii).range;
        fprintf(translated_file, '\n\t%s%s%s%s', input_name, ' = ctrl.Antecedent(np.arange(', [num2str(input_range(1)) ', ', num2str(input_range(2)) ', precision),'], [' "' input_name '")']);
        num_mf = size(fis.input(ii).mf, 2);
        for iii=1:num_mf
            index_mf_i = fis.input(ii).mf(iii);
            name_mf_input = index_mf_i.name;
            type_mf_input = index_mf_i.type;
            mf_i{ii, iii} = [input_name '[' '"' name_mf_input '"' ']'];
            switch type_mf_input
               case 'trapmf'
                params = strjoin(string(index_mf_i.params), ', ');
                d = strcat('["', name_mf_input, '"]', ' = fuzz.trapmf(', input_name, '.universe, [', params, '])');
                
               case 'trimf'
                params = strjoin(string(index_mf_i.params), ', ');
                d = strcat('["', name_mf_input, '"]', ' = fuzz.trimf(', input_name, '.universe, [', params, '])');
            end
            fprintf(translated_file, '\n\t%s%s', input_name, d);
        end    
    end

    for jj=1:num_output_variables
        name_output = fis.output(jj).name;
        range_output = fis.output(jj).range;
        fprintf(translated_file, '\n\t%s%s%s%s', name_output, ... , 
                                         ' = ctrl.Consequent(np.arange(', ... ,
                                         [num2str(range_output(1)) ', ', ... , 
                                         num2str(range_output(2)) ' , precision),'], ... , 
                                         [' "' name_output '")']);
        num_mf_o = size(fis.output(jj).mf, 2);
        for jjj=1:num_mf_o
            index_mf_o = fis.output(jj).mf(jjj);
            name_mf_output = index_mf_o.name;
            type_mf_output = index_mf_o.type;
            mf_o{jj, jjj} = [name_output '[' '"' name_mf_output '"' ']'];
            switch type_mf_output
               case 'trapmf'
                params = strjoin(string(index_mf_o.params), ', ');
                dd = strcat('["', name_mf_output, '"]', ' = fuzz.trapmf(', name_output, '.universe, [', params, '])');
               case 'trimf'
                params = strjoin(string(index_mf_o.params), ', ');
                dd = strcat('["', name_mf_output, '"]', ' = fuzz.trapmf(', name_output, '.universe, [', params, '])');
            end
            fprintf(translated_file, '\n\t%s%s', name_output, dd);
        end   
    end

    num_rules = size(fis.rule, 2);
    rules_i = zeros(num_rules, num_input_variables);
    rules_o = zeros(num_rules, num_output_variables);
    
    r_i = cell([num_rules, num_input_variables]);
    r_o = cell([num_rules, num_output_variables]);
    
    for mm=1:num_rules
        
        rules_i(mm, :) = fis.rule(mm).antecedent;
        rules_o(mm, :) = fis.rule(mm).consequent;
        
        for mmm=1:num_input_variables
            ind_i = rules_i(mm, mmm);
            try
                r_i{mm, mmm} = mf_i{mmm, ind_i};
            catch ME
                % fprintf(ME.message)
            end
        end
        
        for mmmm=1:num_output_variables
            
            ind_o = rules_o(mm, mmmm);
            
            try
                r_o{mm, mmmm} = mf_o{mmmm, ind_o};
            catch ME
                % fprintf(ME.message);
            end
        end
    end
    
    rul = cell(1, num_rules);
    
    for kk=1:num_rules
        
        if fis.rule(kk).connection == 1
            connector = ' & ';
        else
            connector = ' | ';
        end
        
        rule_num = strcat('regla', num2str(kk));
        rul{kk} = rule_num;
        row_i = strjoin(r_i(kk, :), connector);
        rr_o = r_o(kk, :);
        rr_o =  rr_o(~cellfun('isempty',r_o(kk,:)));  
        row_o = strjoin(rr_o, ', ');
        rule = strcat(rule_num, ' = ctrl.Rule(antecedent=(', row_i, '), consequent=(', row_o, '))');
        fprintf(translated_file, '\n\n\t%s%s%s%s', convertCharsToStrings(rule));
    end

    fprintf(translated_file, '\n\n\t%s%s%s', 'c_ctrl = ctrl.ControlSystem([', strjoin(rul, ', '), '])');

    fprintf(translated_file, '\n\n\treturn ctrl.ControlSystemSimulation(c_ctrl)');
end