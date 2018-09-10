# traductor_matlab_python
  Creates a python file (.py) from a .FIS file
 
  Make sure your model, variable and mf names are PEP compliant
  
  UPDATE
  - Made several aesthetical and performance modifications
  - Now works with multiple outputs
  - It now works with both AND and OR rule linking
  - Variable names are now in english 
  - An effort to comment is being made, don't ask too much
  - A precision argument is now available in the generated py file;
    it defines que steps in the range interval in both antecedents and
    consequents. It defaults at 0.1 and can be changed in Python
  
  TODO
  - Implement all the membership functions
  - Implement weigthed rules
  If you find errors in python like: 
  
  Crisp output cannot be calculated, 
  likely because the system is too sparse. Check to make sure this set of 
  input values will activate at least one connected Term in each Antecedent
  via the current set of Rules. 
  
  It means that some rules are not activating. If no rules are activated, 
  MATLAB outputs the half of the output interval. Make sure all your rules
  activated for each input.
 
  If you find discrepancies between MATLAB's output and Python outputs, 
  from SKFuzzys github page (https://github.com/scikit-fuzzy/scikit-fuzzy):
 
  It should be noted that Matlab rounds incorrectly. The IEEE standard 
  (which is how this package behaves) requires rounding to the nearest EVEN
  number if exactly between, e.g. 1.5 --> 2; 2.5 --> 2; 3.5 --> 4; 4.5 --> 4, etc. 
  This minimizes systematic rounding error. Thus, if re-implementing 
  algorithms from Matlab code, slight inconsistencies in rounded results 
  are expected. These are not bugs, and will not be fixed.
 
  Please report any errors to:
  Author: Marco Julio Del Moral Argumedo
  México, Veracruz
  Consejo Nacional de Ciencia y Tecnología
  Tecnológico Nacional de México/Instituto Tecnológico de Orizaba
  marcojulioarg@gmail.com
