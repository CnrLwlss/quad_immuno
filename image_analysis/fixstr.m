function y = fixstr(x)
%I have turned of TeX intepretation when the app starts up, that should
%sort out the weird text formatting stuff.
y = x;

%Fixes a string for display, so that back slashes are not interpreted as
%LaTeX commands.
%y = ['\detokenize{' x '}'];
%y = regexprep(x, '\\', '\\\\');
%y = regexprep(x, '_', '\_');