function success = Tester_IsNonNegativeRealNumber

if IsNonNegativeRealNumber(pi) && ...
        all(IsNonNegativeRealNumber(1:5)) && ... 
        ~IsNonNegativeRealNumber(nan) && ...
        ~any(IsNonNegativeRealNumber([nan nan -3])) && ...
        IsNonNegativeRealNumber(0)
    success = true;
else
    success = false;
end