function traductor(file)

% Creates a python file (.py) from a .FIS file
% 
% Make sure your model, variable and mf names are PEP compliant
% 
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
% Author: Marco Julio Del Moral Argumedo
% México, Veracruz
% marcojulioarg@gmail.com

    fis = readfis(file);

    % Crea un archivo .py y lo nombra con el nombre del sistema difuso
    output = fopen(strcat(fis.name,'.py'),'wt');

    % Importa modulos
    fprintf(output, '%s\n%s\n%s', 'import numpy as np', ...
                                   'import skfuzzy as fuzz', ..., 
                                   'from skfuzzy import control as ctrl');

    fprintf(output, '\n\ndef control():');

    for ii=1:size(fis.input, 2)
        entrada{ii} = fis.input(ii).name;
        nombre_input = fis.input(ii).name;
        rango_input = fis.input(ii).range;
        fprintf(output, '\n\t%s%s%s%s', nombre_input, ... , 
                                         ' = ctrl.Antecedent(np.arange(', ... ,
                                         [num2str(rango_input(1)) ', ', ... , 
                                         num2str(rango_input(2)) ' ,1),'], ... , 
                                         [' "' nombre_input '")']);
        num_mf = size(fis.input(ii).mf, 2);
        for iii=1:num_mf
            gfis = getfis(fis, 'input', ii, 'mflabels', iii);
            nombre_mf_input = gfis.Name;
            nombre_mf_tipo = gfis.Type;
            mf_i{ii, iii} = [nombre_input '[' '"' nombre_mf_input '"' ']'];
            % mfi_i = mfi_i.';

            switch nombre_mf_tipo
               case 'trapmf'
                parametros = [num2str(gfis.params(1)) ', ' num2str(gfis.params(2)) ', ' num2str(gfis.params(3)) ', ' num2str(gfis.params(4))];
                d = ['["' nombre_mf_input '"]' ... 
                                            ' = fuzz.trapmf(' ... 
                                            nombre_input ... 
                                            '.universe, [' parametros '])'];
                fprintf(output, '\n\t%s%s', nombre_input, d);
               case 'trimf'
                parametros = [num2str(gfis.params(1)) ', ' num2str(gfis.params(2)) ', ' num2str(gfis.params(3))];
                d = ['["' nombre_mf_input '"]' ... 
                                            ' = fuzz.trimf(' ... 
                                            nombre_input ... 
                                            '.universe, [' parametros '])'];
                fprintf(output, '\n\t%s%s', nombre_input, d);
            end
        end    
    end
    num_mf_o = size(fis.output.mf, 2);

    for jj=1:size(fis.output, 2)
        nombre_output = fis.output(jj).name;
        rango_output = fis.output(jj).range;
        fprintf(output, '\n\t%s%s%s%s', nombre_output, ... , 
                                         ' = ctrl.Consequent(np.arange(', ... ,
                                         [num2str(rango_output(1)) ', ', ... , 
                                         num2str(rango_output(2)) ' ,1),'], ... , 
                                         [' "' nombre_output '")']);

        for jjj=1:num_mf_o
            gfis = getfis(fis, 'output', jj, 'mflabels', jjj);
            nombre_mf_output = gfis.Name;
            nombre_mf_tipo = gfis.Type;
            mf_o{jj, jjj} = [nombre_output '[' '"' nombre_mf_output '"' ']'];
            % mfi_o = mfi_o.';
            switch nombre_mf_tipo
               case 'trapmf'
                parametros = [num2str(gfis.params(1)) ', ' num2str(gfis.params(2)) ', ' num2str(gfis.params(3)) ', ' num2str(gfis.params(4))];
                dd = ['["' nombre_mf_output '"]' ... 
                                            ' = fuzz.trapmf(' ... 
                                            nombre_output ... 
                                            '.universe, [' parametros '])'];
                fprintf(output, '\n\t%s%s', nombre_output, dd);
               case 'trimf'
                parametros = [num2str(gfis.params(1)) ', ' num2str(gfis.params(2)) ', ' num2str(gfis.params(3))];
                dd = ['["' nombre_mf_output '"]' ... 
                                            ' = fuzz.trimf(' ... 
                                            nombre_output ... 
                                            '.universe, [' parametros '])'];
                fprintf(output, '\n\t%s%s', nombre_output, dd);
            end
        end   
    end

    reglas = getfis(fis, 'rulelist');
    reglas = reglas(:,1:end-2);
    reglas_i = reglas(:, 1:end-1); 


    for mm=1:size(reglas_i, 1)
        for mmm=1:size(reglas_i, 2)
            r_i{mm, mmm} = mf_i{mmm, reglas_i(mm, mmm)};
        end
    end    

    reglas_o = reglas(:, end);

    for mm=1:size(reglas_o, 1)
        for mmm=1:size(reglas_o, 2)
            r_o{mm, mmm} = mf_o{mmm, reglas_o(mm, mmm)};
        end
    end   

    r = [r_i r_o];

    for kk=1:size(fis.rule, 2)
        regla_num = ['regla' num2str(kk)];
        regla = [regla_num ' = ctrl.Rule('];
        rul{kk} = regla_num;
        renglon_i = strjoin(r(kk, 1:end-1), ' & ');
        renglon_i = [regla renglon_i];
        renglon_o = strjoin(r(kk, end));
        fprintf(output, '\n\n\t%s%s%s%s', renglon_i, ' , ',renglon_o, ')');
    end

    fprintf(output, '\n\n\t%s%s%s', 'c_ctrl = ctrl.ControlSystem([', strjoin(rul, ', '), '])');

    fprintf(output, '\n\n\treturn ctrl.ControlSystemSimulation(c_ctrl)');

end