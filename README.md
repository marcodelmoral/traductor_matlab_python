# traductor_matlab_python
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
